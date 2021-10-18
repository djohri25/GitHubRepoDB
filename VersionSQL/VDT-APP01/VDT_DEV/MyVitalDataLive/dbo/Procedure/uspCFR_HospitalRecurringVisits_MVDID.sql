/****** Object:  Procedure [dbo].[uspCFR_HospitalRecurringVisits_MVDID]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[uspCFR_HospitalRecurringVisits_MVDID] 
AS
/*
    CustID:  16
    RuleID:  208
 ProductID:  2
OwnerGroup:  168

Changes
WHO		WHEN		WHAT
Scott	2020-10-2	ALTERd by refactor of original to call uspCFR_Merge
Scott	2020-11-21	Updated from changes to original
Scott	2021-05-20	Modify to CTE and add Universal Exclusion
Scott	2021-08-03	Add new exclusion code
Scott	2021-09-07	Add query hints for Computed Care Queue

EXEC uspCFR_HospitalRecurringVisits_MVDID  --(0/1:46)(0/1:47)

EXEC uspCFR_Merge @MVDProcedureName = 'uspCFR_HospitalRecurringVisits_MVDID', @CustID = 16, @RuleID = 208, @ProductID = 2, @OwnerGroup= 168

EXEC uspCFR_MapRuleExclusion @RuleID = 208, @Action='Display'

*/
BEGIN
	SET NOCOUNT ON;
	DECLARE @RuleID int = 208

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

	--****** Multiple admit CFR ************//
	--****** refine bill types
	--****** exclude BH claims; find Dx codes to use
	--****** execution time at night < 2 minutes

	DROP TABLE IF EXISTS #HospitalAdmits
	
	SELECT DISTINCT FM.MemberID, FM.MVDID, FM.MemberFirstName, FM.MemberLastName, AdmissionDate, COUNT(FC.RecordID) AS SameDayCount
	  INTO #HospitalAdmits
	  FROM FinalMember FM
	  JOIN ComputedCareQueue (READUNCOMMITTED) CCQ on CCQ.mvdid=FM.mvdid -- should be only active members...
	  JOIN FinalClaimsHeader (READUNCOMMITTED) FC on FC.MVDID = FM.MVDID
	 WHERE ISNULL(FM.CompanyKey,'0000') != '1338'
	   AND DATEDIFF(DAY,AdmissionDate, GetDate()) <= 365
	   AND (ISNULL(FC.BillType,'000') LIKE '11%'	-- accute / hospital admission
			OR ISNULL(FC.BillType,'000') like '12%'	-- LTCH admission
			OR ISNULL(FC.BillType,'000') like '14%'	-- Rehab admission
			OR ISNULL(FC.BillType,'000') like '2%'	-- SNF admission
			OR ISNULL(FC.BillType,'000') like '3%'	-- Home Health admission
			OR ISNULL(FC.BillType,'000') like '81%'	-- Hospice non-hospital admission
			OR ISNULL(FC.BillType,'000') like '82%'	-- Hospice hospital admission
		   )
	   AND FC.MVDID IN 
		   (SELECT MVDID
		  	  FROM FinalClaimsHeader FC
			 WHERE DATEDIFF(DAY,AdmissionDate, GetDate()) <= 365
			   AND	(ISNULL(FC.BillType,'000') LIKE '11%'		-- accute / hospital admission
					 OR ISNULL(FC.BillType,'000') like '12%'	-- LTCH admission
					 OR ISNULL(FC.BillType,'000') like '14%'	-- Rehab admission
					 OR ISNULL(FC.BillType,'000') like '2%'		-- SNF admission
					 OR ISNULL(FC.BillType,'000') like '3%'		-- Home Health admission
					 OR ISNULL(FC.BillType,'000') like '81%'	-- Hospice non-hospital admission
					 OR ISNULL(FC.BillType,'000') like '82%'	-- Hospice hospital admission
					)
			  GROUP BY MVDID
			 HAVING COUNT(RecordID) > 1
			)
	  GROUP BY FM.MemberID, FM.MVDID, FM.MemberFirstName, FM.MemberLastName, AdmissionDate
	  ORDER BY FM.MemberID, FM.MVDID, FM.MemberFirstName, FM.MemberLastName, AdmissionDate

		SELECT DISTINCT a.MVDID 
		  FROM #HospitalAdmits a
		 WHERE DATEDIFF(day,AdmissionDate, GETDATE()) <= 30
		   AND NOT EXISTS (SELECT 1 FROM #ExcludedMVDID WHERE MVDID = a.MVDID)
		 GROUP BY MVDID
		HAVING COUNT(AdmissionDate) > 1

END