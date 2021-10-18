/****** Object:  Procedure [dbo].[uspCFR_Covid19_MVDID]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[uspCFR_Covid19_MVDID] 
AS
/*
    CustID:  16
    RuleID:  211
 ProductID:  2
OwnerGroup:  159

Changes
WHO		WHEN		WHAT
Scott	2020-10-2	ALTERd by refactor of original to call uspCFR_Merge
Scott	2021-04-19	Reformat to CTE and Add Universal Exclusion (company codes and hourly benefit)
Scott	2021-0803	Add new exclusion method
Scott	2021-09-07	Add query hints for Computed Care Queue

EXEC uspCFR_Covid19_MVDID  

EXEC uspCFR_Merge @MVDProcedureName = 'uspCFR_Covid19_MVDID', @CustID = 16, @RuleID = 211, @ProductID = 2, @OwnerGroup= 159

EXEC uspCFR_MapRuleExclusion @RuleID = '211', @Action = 'DISPLAY'

*/
BEGIN
SET NOCOUNT ON;

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

-- Covid-19 Careflow Rule
DROP TABLE IF EXISTS #CovidCode
DROP TABLE IF EXISTS #Contact1

	;WITH CovidCode AS
		(-- collect the first and last diagnosis date for each member
			SELECT MVDID, 
				   MIN(StatementFromDate) AS FirstDxDate, 
				   MAX(StatementFromDate) AS LastDxDate 
			  FROM (SELECT C.MVDID, CodeType, CodeValue, C.ClaimNumber, H.StatementFromDate
					  FROM FinalClaimsHeaderCode C
					  JOIN FinalClaimsHeader H ON H.ClaimNumber = C.ClaimNumber
					  JOIN FinalMember FM ON FM.MVDID = H.MVDID
					 WHERE CodeType='DIAG' AND CodeValue IN ('U071')
					   AND FM.GrpInitvCd != 'GRD' -- exclude members associated to Grand Rounds
					   AND ISNULL(FM.CompanyKey,'0000') != '1338'
					   AND ISNULL(FM.COBCD,'U') IN ('S','N','U')
					 UNION
					SELECT C.MVDID, CodeType, CodeValue, C.ClaimNumber , H.StatementFromDate
					  FROM FinalClaimsDetailCode C
					  JOIN FinalClaimsHeader H ON H.ClaimNumber = C.ClaimNumber
					  JOIN FinalMember FM ON FM.MVDID = H.MVDID
					 WHERE CodeType='DIAG' AND CodeValue in ('U071')
					   AND FM.GrpInitvCd != 'GRD' -- exclude members associated to Grand Rounds
					   AND ISNULL(FM.CompanyKey,'0000') != '1338'
					   AND ISNULL(FM.COBCD,'U') in ('S','N','U')
				   ) a
			 GROUP BY MVDID
		),
		ContactForms AS
		(-- collect the contact forms for identified members
			SELECT DISTINCT CF.MVDID, C.FirstDxDate, C.LastDxDate, CF.FormDate  
			  FROM CovidCode C
			  JOIN ARBCBS_Contact_Form CF ON CF.MVDID = C.MVDID AND CF.FormDate >= C.FirstDxDate
			 UNION
		    SELECT MMF.MVDID, C.FirstDxDate, C.LastDxDate, MMF.FormDate
              FROM CovidCode C
              JOIN ABCBS_MemberManagement_Form MMF on MMF.MVDID = C.MVDID and MMF.FormDate >= C.FirstDxDate
		)
		SELECT DISTINCT MVDID 
		  FROM CovidCode cc 
		 WHERE NOT EXISTS (SELECT 1 FROM ContactForms WHERE MVDID = cc.MVDID) 
		   AND NOT EXISTS (SELECT 1 FROM ComputedCareQueue (READUNCOMMITTED) WHERE ISNULL(CaseID,-1) > 0 AND MVDID = cc.MVDID)
		   AND NOT EXISTS (SELECT 1 FROM #ExcludedMVDID WHERE MVDID = cc.MVDID)
		   AND cc.MVDID IS NOT NULL

END