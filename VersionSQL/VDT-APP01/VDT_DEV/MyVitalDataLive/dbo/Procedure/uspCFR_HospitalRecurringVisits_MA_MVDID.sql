/****** Object:  Procedure [dbo].[uspCFR_HospitalRecurringVisits_MA_MVDID]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[uspCFR_HospitalRecurringVisits_MA_MVDID] 
AS
/*
    CustID:  16
    RuleID:  254
 ProductID:  2
OwnerGroup:  171

Changes
WHO		WHEN		WHAT
Scott	2020-10-2	ALTERd by refactor of original to call uspCFR_Merge
Scott	2021-05-20	Modified to CTE and add UniversalExclusion
Scott	2021-07-30	Added new eclusion code.
Scott	2021-09-07	Add query hints for Computed Care Queue

EXEC uspCFR_HospitalRecurringVisits_MA_MVDID (0/:07)

EXEC uspCFR_Merge @MVDProcedureName = 'uspCFR_HospitalRecurringVisits_MA_MVDID', @CustID = 16, @RuleID = 254, @ProductID = 2, @OwnerGroup= 171

EXEC uspCFR_MapRuleExclusion @RuleID = '254', @Action='DISPLAY'

*/
BEGIN
	SET NOCOUNT ON;
	DECLARE @RuleID int = 254
	DECLARE @OwnerGroup int = 171

	--New Exclusion Code
	DROP TABLE IF EXISTS #ExcludedMVDID
	CREATE TABLE #ExcludedMVDID (MVDID varchar(30))

	INSERT INTO #ExcludedMVDID (MVDID)
	SELECT DISTINCT em.MVDID
	  FROM CFR_Rule_Exclusion re
	  JOIN HPWorkFlowRule wfr ON wfr.Rule_ID = re.RuleID
	  JOIN CFR_ExcludedMVDID em ON em.ExclusionID = re.ExclusionID
	  JOIN CFR_Exclusion e ON em.ExclusionID = e.ID
	 WHERE wfr.Body = OBJECT_NAME(@@PROCID)

	CREATE INDEX IX_ExcludedMVDID ON #ExcludedMVDID (MVDID)

	DROP TABLE IF EXISTS #HospitalAdmits
	
	  SELECT FM.MemberID, 
			 FM.MVDID, 
			 FM.MemberFirstName, 
			 FM.MemberLastName, 
			 AdmissionDate, 
			 COUNT(FC.RecordID) AS SameDayCount
		INTO #HospitalAdmits
		FROM FinalMember (READUNCOMMITTED) FM
		JOIN ComputedCareQueue (READUNCOMMITTED) CCQ ON CCQ.mvdid=FM.mvdid -- should be only active members...
		JOIN FinalClaimsHeader (READUNCOMMITTED) FC ON FC.MVDID = FM.MVDID
		JOIN FinalEligibility (READUNCOMMITTED) FE ON FE.MVDID = FM.MVDID 
		 AND FE.MemberEffectiveDate <= GETDATE() 
		 AND ISNULL(FE.MemberTerminationDate,'9999-12-31') >= GETDATE() 
		 AND ISNULL(FE.FakeSpanInd,'N') = 'N' 
		 AND ISNULL(FE.SpanVoidInd,'N') = 'N'
	   WHERE ISNULL(FM.CompanyKey,'0000') != '1338'
		 AND FE.PlanIdentifier != 'H4213'
		 AND CCQ.LOB = 'MA'
		 AND DATEDIFF(DAY,AdmissionDate, GetDate()) <= 365
		 AND (
				ISNULL(FC.BillType,'000') LIKE '11%'	-- accute / hospital admission
				OR ISNULL(FC.BillType,'000') LIKE '12%'	-- LTCH admission
				OR ISNULL(FC.BillType,'000') LIKE '14%'	-- Rehab admission
				OR ISNULL(FC.BillType,'000') LIKE '2%'	-- SNF admission
				OR ISNULL(FC.BillType,'000') LIKE '3%'	-- Home Health admission
				OR ISNULL(FC.BillType,'000') LIKE '81%'	-- Hospice non-hospital admission
				OR ISNULL(FC.BillType,'000') LIKE '82%'	-- Hospice hospital admission
			 )
		 AND FC.MVDID IN 
			 (
				SELECT MVDID
				  FROM FinalClaimsHeader FC
				 WHERE DATEDIFF(DAY,AdmissionDate, GetDate()) <= 365
				   AND (
						ISNULL(FC.BillType,'000') like '11%'	-- accute / hospital admission
						OR ISNULL(FC.BillType,'000') like '12%'	-- LTCH admission
						OR ISNULL(FC.BillType,'000') like '14%'	-- Rehab admission
						OR ISNULL(FC.BillType,'000') like '2%'	-- SNF admission
						OR ISNULL(FC.BillType,'000') like '3%'	-- Home Health admission
						OR ISNULL(FC.BillType,'000') like '81%'	-- Hospice non-hospital admission
						OR ISNULL(FC.BillType,'000') like '82%'	-- Hospice hospital admission
						)
				  GROUP BY MVDID
				 HAVING COUNT(RecordID) > 1
			  )
	    GROUP BY FM.MemberID, FM.MVDID, FM.MemberFirstName, FM.MemberLastName, AdmissionDate,FE.MemberEffectiveDate, FE.MemberTerminationDate
	    ORDER BY FM.MemberID, FM.MVDID, FM.MemberFirstName, FM.MemberLastName, AdmissionDate

			SELECT DISTINCT a.MVDID 
			  FROM #HospitalAdmits a 
			 WHERE DATEDIFF(day,AdmissionDate, GETDATE()) <= 30
			   AND NOT EXISTS (SELECT 1 FROM #ExcludedMVDID WHERE MVDID = a.MVDID)
			 GROUP BY MVDID
			HAVING COUNT(AdmissionDate) > 1

END