/****** Object:  Procedure [dbo].[uspCFR_HiAmt_Paid_MA_MVDID]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[uspCFR_HiAmt_Paid_MA_MVDID] 
AS
/*

	CustID:			16
	RuleID:			256
	ProductID:		2
	OwnerGroup:		171

Modifications:
WHO			WHEN		WHAT
Scott		2020-11-18	Refactored to use new merge process: return only the MVDIDs.
Scott		2021-05-24	Refactor to CTE and add Universal Exclusion for no benifit, hourly.
Scott		2021-07-08	Add query hints to prevent deadlock.

EXEC uspCFR_HiAmt_Paid_MA_MVDID  --(85/0:09)(85/0:05)

This procedure may be called using the Merge procedure:

exec uspCFR_Merge @MVDProcedureName ='uspCFR_HiAmt_Paid_MA_MVDID', @CustID=16, @RuleID = 256, @ProductID=2, @OwnerGroup = 171

EXEC uspCFR_MapRuleExclusion @pRuleID = '256', @pAction='DISLAY'

*/
BEGIN

	SET NOCOUNT ON;

DECLARE @MaxRolling12 varchar(6)

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

		-- member is active (a) has no case manager (b) no personal harm (i) high cost per group (AC2) 
		SELECT DISTINCT CCQ.MVDID
		  FROM ComputedCareQueue CCQ WITH (READUNCOMMITTED)
		  JOIN FinalMember FM  WITH (READUNCOMMITTED) ON FM.MVDID = CCQ.MVDID
		  JOIN FinalEligibility FE  WITH (READUNCOMMITTED) ON FE.MVDID = FM.MVDID and FE.MemberEffectiveDate <= GETDATE() AND ISNULL(FE.MemberTerminationDate,'9999-12-31') >= GETDATE() and IsNull(FE.FakeSpanInd,'N') = 'N' and IsNull(FE.SpanVoidInd,'N') = 'N'
	 LEFT JOIN ComputedMemberAlert CA  WITH (READUNCOMMITTED) ON CA.MVDID = CCQ.MVDID
	 LEFT JOIN ComputedMemberTotalPaidClaimsRollling12 CP WITH (READUNCOMMITTED) ON CP.MVDID = CCQ.MVDID
		 WHERE CCQ.IsActive = 1 
		   AND ISNULL(FM.CompanyKey,'0000') != '1338'
		   AND FE.PlanIdentifier != 'H4213'
		   AND ISNULL(CCQ.CaseOwner,'--') = '--'
		   AND ISNULL(CA.PersonalHarm,0) = 0
		   AND ISNULL(CP.HighDollarClaim,0) = 1
		   AND CP.MonthID = @MaxRolling12
		   AND CCQ.LOB='MA'
		   AND ISNULL(FM.COBCD,'U') IN ('S','N','U')
		   AND ISNULL(FM.GrpInitvCd,'n/a') != 'GRD'
		   AND NOT EXISTS (SELECT 1 FROM #ExcludedMVDID WHERE MVDID = CCQ.MVDID)

END