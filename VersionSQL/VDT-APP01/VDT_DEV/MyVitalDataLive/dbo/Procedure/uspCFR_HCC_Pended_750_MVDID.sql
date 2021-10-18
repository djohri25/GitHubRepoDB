/****** Object:  Procedure [dbo].[uspCFR_HCC_Pended_750_MVDID]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[uspCFR_HCC_Pended_750_MVDID] 
AS
/*
			***Depends on CFR 220

	CustID:			16
	RuleID:			274
	ProductID:		2
	OwnerGroup:		168

Modifications:
WHO			WHEN		WHAT
Scott		2020-11-18	Refactored to use new merge process: return only the MVDIDs.
Scott		2021-07-30	Add new exclusion method
Scott		2021-09-07	Add query hints for Computed Care Queue

exec uspCFR_HCC_Pended_750_MVDID --(0\:00)(0\:00)

This procedure may be called using the Merge procedure:

exec uspCFR_Merge @MVDProcedureName ='uspCFR_HCC_Pended_750_MVDID', @CustID=16, @RuleID = 274, @ProductID=2, @OwnerGroup = 168

EXEC uspCFR_MapRuleExclusion @pRuleID = '274', @pAction='DISPLAY'


*/
BEGIN
	SET NOCOUNT ON;

	DECLARE @MaxRolling12 varchar(6)
	DECLARE @RuleId int = 274
	DECLARE @OwnerGroup int = 168 -- review group -- ultimately 145

	-- Capture most recent rolling 12 computed
	SELECT @MaxRolling12 = MAX(MonthID) FROM ComputedMemberTotalPendedClaimsRollling12

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

		SELECT CF.MVDID 
		  FROM CareFlowTask CF
		  JOIN ComputedMemberTotalPendedClaimsRollling12  (READUNCOMMITTED) CCR on CCR.MVDID = CF.MVDID AND MonthID = @MaxRolling12
		 WHERE CF.RuleId = 220
		   AND CCR.TotalPaidAmount >= 750000
		   AND NOT EXISTS (SELECT 1 FROM #ExcludedMVDID WHERE MVDID = CF.MVDID)

END