/****** Object:  Procedure [dbo].[uspCFR_Depression2_MVDID]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[uspCFR_Depression2_MVDID]
AS
/*
    CustID:  16
    RuleID:  280
 ProductID:  2
OwnerGroup:  168

Changes
WHO		WHEN		WHAT
Mike G	2021-01-08	Created by to implement automated referal to Nurse Q - Change Request STRY0025483
Scott	2021-05-13  Add Universal Exclusion for hourly and no benefit.
Scott	2021-09-07	Create Index for #ExcludedMVDID

EXEC uspCFR_Depression2_MVDID  --( / )

EXEC uspCFR_Merge @MVDProcedureName = 'uspCFR_Depression2_MVDID', @CustID = 16, @RuleID = 280, @ProductID = 2, @OwnerGroup= 168

EXEC uspCFR_MapRuleExclusion @pRuleID = '280', @pAction = 'DISPLAY'

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
	  FROM CareFlowTask CF
	  JOIN FinalMember FM ON FM.MVDID=CF.MVDID
	 WHERE RuleID=213 
	   AND ISNULL(NewDirSvcCd,'None') NOT LIKE '%CM%'
	   AND ISNULL(NewDirSvcCd,'None') != 'UM'
	   AND NOT EXISTS (SELECT 1 FROM #ExcludedMVDID WHERE MVDID = CF.MVDID)

END