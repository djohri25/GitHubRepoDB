/****** Object:  Procedure [dbo].[uspCFR_HCC_Paid_750_MVDID]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[uspCFR_HCC_Paid_750_MVDID] 
AS
/*
			***Depends on CFR 219

	CustID:			16
	RuleID:			257
	ProductID:		2
	OwnerGroup:		159

Modifications:
WHO			WHEN		WHAT
Scott		2020-11-18	Refactored to use new merge process: return only the MVDIDs.
Scott		2021-05-24	Refactor to CTE and add Universal Exclusion for no benifit, hourly.
Scott		2021-09-07	Add query hints for Computed Care Queue

EXEC uspCFR_HCC_Paid_750_MVDID   --(14\:01)(14\:01)

This procedure may be called using the Merge procedure:

EXEC uspCFR_Merge @MVDProcedureName ='uspCFR_HCC_Paid_750_MVDID', @CustID=16, @RuleID = 257, @ProductID=2, @OwnerGroup = 159

EXEC uspCFR_MapRuleExclusion @RuleID = '257', @Action = 'DISPLAY'

*/
BEGIN
	SET NOCOUNT ON;

	DECLARE @MaxRolling12 varchar(6)
	DECLARE @RuleId int = 257
	DECLARE @OwnerGroup int = 159 -- review group -- ultimately 145
	
	-- Capture most recent rolling 12 computed
	select @MaxRolling12 = Max(MonthID) from ComputedMemberTotalPaidClaimsRollling12

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
		  FROM CareFlowTask (READUNCOMMITTED) CF
		  JOIN ComputedMemberTotalPaidClaimsRollling12 (READUNCOMMITTED) CCR ON CCR.MVDID = CF.MVDID and MonthID = @MaxRolling12
		 WHERE CF.RuleId = 219
		   AND CCR.TotalPaidAmount >= 750000
		   AND NOT EXISTS (SELECT 1 FROM #ExcludedMVDID WHERE MVDID = CF.MVDID)

END