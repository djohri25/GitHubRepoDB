/****** Object:  Procedure [dbo].[uspCFR_HCC_Paid_50_MVDID]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[uspCFR_HCC_Paid_50_MVDID] 
AS
/*
						***Depends on CFR 219

	CustID:			16
	RuleID:			260
	ProductID:		2
	OwnerGroup:		159

Modifications:
WHO			WHEN		WHAT
Scott		2020-11-18	Refactored to use new merge process
Scott		2021-05-24	Refactor to CTE and add Universal Exclusion for no benifit, hourly.
Scott		2021-07-30	Add new exclusion method
Scott		2021-09-07	Add query hints for Computed Care Queue

EXEC uspCFR_HCC_Paid_50_MVDID  --(4075\:01)(4075\:03)

This procedure may be called using the Merge procedure:

exec uspCFR_Merge @MVDProcedureName ='uspCFR_HCC_Paid_50_MVDID', @CustID=16, @RuleID = 260, @ProductID=2, @OwnerGroup = 159

EXEC uspCFR_MapRuleExclusion @pRuleID = '260', @pAction='DISPLAY'

*/
BEGIN
	SET NOCOUNT ON;

	DECLARE @MaxRolling12 varchar(6)
	DECLARE @RuleId int = 260
	DECLARE @OwnerGroup int = 159 -- review group -- ultimately 161

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

	CREATE INDEX IX_ExcludedMVDID ON #ExcludedMVDID (MVDID)
 
	;WITH UniversalExclusion AS
		(
			SELECT DISTINCT fm.MVDID
			  FROM FinalMember fm
			  JOIN Final.dbo.LookupGRP_CareFlowRule ue ON fm.CompanyKey = ue.Company_Key
			 WHERE (ue.Bill_Hourly_Ind = 'Y' OR ue.Exclude_Careflow_Ind = 'Y') 
		)
		SELECT CF.MVDID 
		  FROM CareFlowTask (READUNCOMMITTED) CF
		  JOIN ComputedCareQueue (READUNCOMMITTED) CCQ ON CCQ.MVDID = CF.MVDID
		  JOIN ComputedMemberTotalPaidClaimsRollling12 (READUNCOMMITTED) CCR ON CCR.MVDID = CF.MVDID and MonthID = @MaxRolling12
		 WHERE CF.RuleId = 219
		   AND CCR.TotalPaidAmount BETWEEN 50000 AND 99999
		   AND CCQ.CmOrGRegion NOT IN ('WALMART','TYSON','WINDSTREAN')
		   AND NOT EXISTS (SELECT 1 FROM #ExcludedMVDID WHERE MVDID = CF.MVDID)

END