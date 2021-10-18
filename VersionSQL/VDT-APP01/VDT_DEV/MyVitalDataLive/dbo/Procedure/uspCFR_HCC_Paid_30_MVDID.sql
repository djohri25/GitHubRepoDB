/****** Object:  Procedure [dbo].[uspCFR_HCC_Paid_30_MVDID]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[uspCFR_HCC_Paid_30_MVDID] 
AS
/*
	CustID:			16
	RuleID:			261
	ProductID:		2
	OwnerGroup:		169

Modifications:
WHO			WHEN		WHAT
Scott		2020-11-18	Refactored to use new merge process
Scott		2020-11-21	Applied changes from original
Scott		2021-05-24	Refactor to CTE and add Universal Exclusion for no benifit, hourly.

EXEC uspCFR_HCC_Paid_30_MVDID  --(5195/:04 )(5195/:02)

This procedure may be called using the Merge procedure:

EXEC uspCFR_Merge @MVDProcedureName ='uspCFR_HCC_Paid_30_MVDID', @CustID=16, @RuleID = 261, @ProductID=2,@OwnerGroup = 169

EXEC uspCFR_MapRuleExclusion @pRuleID = '261', @pAction='DISPLAY'

*/
BEGIN
	SET NOCOUNT ON;

	DECLARE @MaxRolling12 varchar(6)
	DECLARE @RuleId int = 261
	DECLARE @OwnerGroup int = 159 -- review group -- ultimately 159

	-- Capture most recent rolling 12 computed
	SELECT @MaxRolling12 = MAX(MonthID) FROM ComputedMemberTotalPaidClaimsRollling12

	DROP TABLE IF EXISTS #ExcludedMVDID
	CREATE TABLE #ExcludedMVDID (MVDID varchar(30))

	INSERT INTO #ExcludedMVDID (MVDID)
	SELECT DISTINCT em.MVDID
	  FROM CFR_Rule_Exclusion re
	  JOIN HPWorkFlowRule wfr ON wfr.Rule_ID = re.RuleID
	  JOIN CFR_ExcludedMVDID em ON em.ExclusionID = re.ExclusionID
	  JOIN CFR_Exclusion e ON em.ExclusionID = e.ID
	 WHERE wfr.Body = OBJECT_NAME(@@PROCID)

		SELECT CF.MVDID 
		  FROM CareFlowTask CF
		  JOIN ComputedCareQueue CCQ ON CCQ.MVDID = CF.MVDID
		  JOIN ComputedMemberTotalPaidClaimsRollling12 CCR ON CCR.MVDID = CF.MVDID and MonthID = @MaxRolling12
		 WHERE CF.RuleId = 219
		   AND CCR.TotalPaidAmount BETWEEN 30000 AND 49999
		   AND CCQ.CmOrGRegion NOT IN ('WALMART','TYSON','WINDSTREAN')
		   AND NOT EXISTS (SELECT 1 FROM #ExcludedMVDID WHERE MVDID = CF.MVDID)

END