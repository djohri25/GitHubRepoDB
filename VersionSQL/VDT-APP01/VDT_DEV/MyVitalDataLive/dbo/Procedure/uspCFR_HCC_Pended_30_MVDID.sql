/****** Object:  Procedure [dbo].[uspCFR_HCC_Pended_30_MVDID]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[uspCFR_HCC_Pended_30_MVDID] 
AS
/*
			***Depends on CFR 220

	CustID:			16
	RuleID:			278
	ProductID:		2
	OwnerGroup:		168

Modifications:
WHO			WHEN		WHAT
Scott		2020-11-18	Refactored to use new merge process: return only the MVDIDs.

EXEC uspCFR_HCC_Pended_30_MVDID --(3/:00)(3/:00)

This procedure may be called using the Merge procedure:

exec uspCFR_Merge @MVDProcedureName ='uspCFR_HCC_Pended_30_MVDID', @CustID=16, @RuleID = 278, @ProductID=2, @OwnerGroup = 168

*/
BEGIN
	SET NOCOUNT ON;

	DECLARE @MaxRolling12 varchar(6)
	DECLARE @RuleId int = 278
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

		SELECT CF.MVDID 
		  FROM CareFlowTask CF
		  JOIN ComputedCareQueue CCQ on CCQ.MVDID = CF.MVDID
		  JOIN ComputedMemberTotalPendedClaimsRollling12 CCR on CCR.MVDID = CF.MVDID and MonthID = @MaxRolling12
		 WHERE CF.RuleId = 220
		   AND CCR.TotalPaidAmount BETWEEN 30000 AND 49999
		   AND CCQ.CmOrGRegion NOT IN ('WALMART','TYSON','WINDSTREAN')
		   AND NOT EXISTS (SELECT 1 FROM #ExcludedMVDID WHERE MVDID = CF.MVDID)

END