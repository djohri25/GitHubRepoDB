/****** Object:  Procedure [dbo].[uspCFR_SUDandDepression1_MVDID]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[uspCFR_SUDandDepression1_MVDID]
AS
/*
    CustID:  16
    RuleID:  281
 ProductID:  2
OwnerGroup:  168

Changes
WHO		WHEN		WHAT
Mike G	2021-01-08	Created by to implement automated referal to NDBH - Change Request STRY0025483
Scott	2021-05-24	Refactor to CTE and add Universal Exclusion for no benifit, hourly.

EXEC uspCFR_SUDandDepression1_MVDID  --(845/:00)(845/:01)

EXEC uspCFR_Merge @MVDProcedureName = 'uspCFR_SUDandDepression1_MVDID', @CustID = 16, @RuleID = 281, @ProductID = 2, @OwnerGroup= 168

EXEC uspCFR_MapRuleExclusion @pRuleID = '281', @pAction = 'DISPLAY'

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
	
		SELECT DISTINCT CF.MVDID
		  FROM CareFlowTask CF
		  JOIN FinalMember FM ON FM.MVDID=CF.MVDID
		 WHERE RuleID=214 
		   AND ISNULL(NewDirSvcCd,'None') LIKE '%CM%'
		   AND NOT EXISTS (SELECT 1 FROM #ExcludedMVDID WHERE MVDID = CF.MVDID)

END