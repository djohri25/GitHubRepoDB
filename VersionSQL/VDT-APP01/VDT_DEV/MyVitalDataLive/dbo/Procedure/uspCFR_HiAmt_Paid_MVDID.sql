/****** Object:  Procedure [dbo].[uspCFR_HiAmt_Paid_MVDID]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[uspCFR_HiAmt_Paid_MVDID] 
AS
/*
    CustID:  16
    RuleID:  219
 ProductID:  2
OwnerGroup:  159

Changes
WHO		WHEN		WHAT
Scott	2020-10-2	ALTERd by refactor of original to call uspCFR_Merge
Scott	2020-11-21	Applied changes made to original
Scott   2021-04-20  Reformat to CTE form and add Universal Exclusion for no benefit, hourly.
Scott	2021-09-07	Add query hints for Computed Care Queue

EXEC uspCFR_HiAmt_Paid_MVDID   --(22,137 /0:14)(22,137 /0:11)

EXEC uspCFR_Merge @MVDProcedureName = 'uspCFR_HiAmt_Paid_MVDID', @CustID = 16, @RuleID = 219, @ProductID = 2, @OwnerGroup= 159

EXEC uspCFR_MapRuleExclusion @pRuleID = '219', @pAction='DISLAY'

*/

BEGIN
	SET NOCOUNT ON;

DECLARE @MaxRolling12 varchar(6)
DECLARE @RuleID int = 219

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

			-- member is active (a), has no case manager (b), no personal harm (i), high cost per group (AC2)
			SELECT DISTINCT CCQ.MVDID
			  FROM ComputedCareQueue CCQ
			  JOIN FinalMember FM on FM.MVDID = CCQ.MVDID
		 LEFT JOIN ComputedMemberAlert (READUNCOMMITTED) CA on CA.MVDID = CCQ.MVDID
		 LEFT JOIN ComputedMemberTotalPaidClaimsRollling12 (READUNCOMMITTED) CP on CP.MVDID = CCQ.MVDID
			 WHERE CCQ.IsActive = 1 
		       AND ISNULL(FM.COBCD,'U') in ('S','N','U')
			   AND ISNULL(FM.CompanyKey,'0000') != '1338'
			   AND ISNULL(CCQ.CaseOwner,'--') = '--'
			   AND ISNULL(CA.PersonalHarm,0) = 0
			   AND ISNULL(CP.HighDollarClaim,0) = 1
			   AND CP.MonthID = @MaxRolling12
			   AND FM.GrpInitvCd != 'GRD'
			   AND NOT EXISTS (SELECT 1 FROM #ExcludedMVDID WHERE MVDID = CCQ.MVDID)

END