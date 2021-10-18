/****** Object:  Procedure [dbo].[uspCFR_HCC_Pended_100_MVDID]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[uspCFR_HCC_Pended_100_MVDID] 
AS
/*
			***Depends on CFR 220

	CustID:			16
	RuleID:			276
	ProductID:		2
	OwnerGroup:		168

Modifications:
WHO			WHEN		WHAT
Scott		2020-11-18	Refactored to use new merge process: return only the MVDIDs.
Scott		2021-05-24	Refactor to CTE and add Universal Exclusion for no benifit, hourly.
Scott		2021-07-30	Add new exclusion method
Scott		2021-09-07	Add query hints for Computed Care Queue

EXEC uspCFR_HCC_Pended_100_MVDID --(2/:00)(2/:00)

This procedure may be called using the Merge procedure:

exec uspCFR_Merge @MVDProcedureName ='uspCFR_HCC_Pended_100_MVDID', @CustID=16, @RuleID = 276, @ProductID=2, @OwnerGroup = 168

EXEC uspCFR_MapRuleExclusion @pRuleID = '276', @pAction='DISPLAY'

*/
BEGIN
	SET NOCOUNT ON;

	DECLARE @MaxRolling12 varchar(6)
	DECLARE @RuleId int = 276
	DECLARE @OwnerGroup int = 168 -- review group -- ultimately 159

	-- Capture most recent rolling 12 computed
	select @MaxRolling12 = Max(MonthID) from ComputedMemberTotalPendedClaimsRollling12
	
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
			  JOIN ComputedCareQueue (READUNCOMMITTED) CCQ on CCQ.MVDID = CF.MVDID
			  JOIN ComputedMemberTotalPendedClaimsRollling12 (READUNCOMMITTED) CCR on CCR.MVDID = CF.MVDID and MonthID = @MaxRolling12
			 WHERE CF.RuleId = 220
			   AND CCR.TotalPaidAmount BETWEEN 100000 AND 249999
			   AND CCQ.CmOrGRegion NOT IN ('WALMART','TYSON','WINDSTREAN')
			   AND NOT EXISTS (SELECT 1 FROM #ExcludedMVDID WHERE MVDID = CCQ.MVDID)

END