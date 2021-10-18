/****** Object:  Procedure [dbo].[uspCFR_SUDandDepression2_MVDID]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[uspCFR_SUDandDepression2_MVDID]
AS
/*
    CustID:  16
    RuleID:  282
 ProductID:  2
OwnerGroup:  168

Changes
WHO		WHEN		WHAT
Mike G	2021-01-08	ALTERd by to implement automated referal to Nurse Q - Change Request STRY0025483
Scott	2021-05-24	Refactor to CTE and add Universal Exclusion for no benifit, hourly.
Scott	2021-09-07	Add query hints for Computed Care Queue

EXEC uspCFR_SUDandDepression2_MVDID   --(7/:00)(7/:01)

EXEC uspCFR_Merge @MVDProcedureName = 'uspCFR_SUDandDepression2_MVDID', @CustID = 16, @RuleID = 282, @ProductID = 2, @OwnerGroup= 168

EXEC uspCFR_MapRuleExclusion @RuleID = '282', @Action = 'DISPLAY'

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

	CREATE INDEX IX_ExcludedMVDID ON #ExcludedMVDID (MVDID)

		SELECT DISTINCT CF.MVDID
          FROM CareFlowTask (READUNCOMMITTED) CF
          JOIN FinalMember (READUNCOMMITTED) FM on FM.MVDID=CF.MVDID
         WHERE RuleID=214 
           AND ISNULL(NewDirSvcCd,'None') NOT LIKE '%CM%'
           AND ISNULL(NewDirSvcCd,'None') != 'UM'
		   AND NOT EXISTS (SELECT 1 FROM #ExcludedMVDID WHERE MVDID = CF.MVDID)

END