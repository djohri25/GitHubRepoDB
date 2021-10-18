/****** Object:  Procedure [dbo].[uspCFR_Covid19_Lab_MVDID]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[uspCFR_Covid19_Lab_MVDID] 
AS
/*
    CustID:  16
    RuleID:  242
 ProductID:  2
OwnerGroup:  159

Changes
WHO		WHEN		WHAT
Scott	2020-10-2	CREATEd by refactor of original to call uspCFR_Merge
Scott	2020-11-21	Applied changes from original
Scott	2021-06-04  Add UniversalExclusion for hourly and no benefit
Scott	2021-08-03	Add new exclusion code
Scott	2021-09-07	Add query hints for Computed Care Queue

EXEC uspCFR_Covid19_Lab_MVDID    --(1229/1:11 )

EXEC uspCFR_Merge @MVDProcedureName = 'uspCFR_Covid19_10Day_MVDID', @CustID = 16, @RuleID = 242, @ProductID = 2, @OwnerGroup= 159

EXEC uspCFR_MapRuleExclusion @RuleID = '242', @Action = 'DISPLAY'

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
	  
	        -- member is active (a) has no case manager (b) [removed per request 6/11/2020] no personal harm (i) high cost per group (AC2)
			SELECT CCQ.MVDID
			  FROM ComputedCareQueue (READUNCOMMITTED) CCQ
		 LEFT JOIN ComputedMemberAlert (READUNCOMMITTED) CA ON CA.MVDID = CCQ.MVDID
			  JOIN FinalMember (READUNCOMMITTED) FM ON FM.MVDID = CCQ.MVDID
			  JOIN FinalLab (READUNCOMMITTED) FL ON FL.MVDID = CCQ.MVDID
			 WHERE CCQ.IsActive = 1 
			   AND ISNULL(FM.COBCD,'U') IN ('S','N','U')
			   AND ISNULL(FM.CompanyKey,'0000') != '1338'
			   AND ISNULL(CCQ.CaseOwner,'--') = '--'
			   AND ISNULL(CA.PersonalHarm,0) = 0
			   --AND FM.GrpInitvCd != 'GRD' -- exclude members associated to Grand Rounds
			   AND ((FL.TestCode IN ('943092','945006','945634') OR OrderCode IN ('86769','87635')) AND TestResult NOT IN ('NEGATIVE','NOT DETECTED','NOT GIVEN','INCONCLUSIVE','U'))
			   AND NOT EXISTS (SELECT 1 FROM #ExcludedMVDID WHERE MVDID = CCQ.MVDID)

	
END