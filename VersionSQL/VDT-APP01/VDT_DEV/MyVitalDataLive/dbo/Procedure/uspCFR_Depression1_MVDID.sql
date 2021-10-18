/****** Object:  Procedure [dbo].[uspCFR_Depression1_MVDID]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[uspCFR_Depression1_MVDID]
AS
/*
    CustID:  16
    RuleID:  279
 ProductID:  2
OwnerGroup:  168

Changes
WHO		WHEN		WHAT
Mike G	2021-01-08	CREATEd by to implement automated referal to NDBH - Change Request STRY0025483
Scott	2021-05-13  Added Universal Exclusion for no benefits and hourly.
Scott	2021-08-03  Add new exclusion code
Scott	2021-09-07	Add index to #ExcludedMVDID

EXEC uspCFR_Depression1_MVDID

EXEC uspCFR_Merge @MVDProcedureName = 'uspCFR_Depression1_MVDID', @CustID = 16, @RuleID = 279, @ProductID = 2, @OwnerGroup= 168

EXEC uspCFR_MapRuleExclusion @RuleID = '279', @Action = 'DISPLAY'

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
		  FROM CareFlowTask cf
		  JOIN FinalMember fm on FM.MVDID=CF.MVDID
		 WHERE RuleID=213 AND ISNULL(fm.NewDirSvcCd,'None') LIKE '%CM%'
		   AND NOT EXISTS (SELECT 1 FROM #ExcludedMVDID WHERE MVDID = cf.MVDID)

END