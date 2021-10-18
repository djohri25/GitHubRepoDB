/****** Object:  Procedure [dbo].[uspCFR_HighCost_CAN_4_MVDID]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[uspCFR_HighCost_CAN_4_MVDID] 
AS
/*

    CustID:  16
    RuleID:  236
 ProductID:  2
OwnerGroup:  168 Rules Review

Changes
WHO		WHEN		WHAT
Scott	2020-11-02	Modifiy to use Merge
Scott	2020-11-21	Applied changes from original
Scott	2021-03-24	Refactor to use CTE for performance and clarity
Scott	2021-08-02	Add new exclusion code
Scott	2021-09-07	Add query hints for Computed Care Queue

EXEC uspCFR_HighCost_CAN_4_MVDID --(1008/:22) (1007/:03)

EXEC uspCFR_Merge @MVDProcedureName = 'uspCFR_HighCost_CAN_4_MVDID', @CustID = 16, @RuleID = 236, @ProductID = 2, @OwnerGroup = 168

EXEC uspCFR_MapRuleExclusion @RuleID = '236', @Action = 'DISPLAY'

*/
BEGIN
	SET NOCOUNT ON;

	DECLARE @RuleID int = 236
	DECLARE @Grp int = 19  -- 1= CHF, 10=COPD, 7 = Hypertension, 12 = Diabetes, 19 = Cancer, 9 = Chronic Neurolical condition

	DECLARE @MaxMI varchar(6)
	SELECT TOP 1  @MaxMI = monthid FROM [MyVitalDataLive].[dbo].[ComputedMemberTotalPaidClaimsRollling12] ORDER BY ID DESC

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


			SELECT DISTINCT CCQ.MVDID
		      FROM ComputedCareQueue (READUNCOMMITTED) CCQ
	     LEFT JOIN ComputedMemberAlert (READUNCOMMITTED) CA on CA.MVDID = CCQ.MVDID
		 LEFT JOIN FinalMember (READUNCOMMITTED) FM on FM.MVDID = CCQ.MVDID
		 LEFT JOIN ComputedMemberTotalPaidClaimsRollling12 (READUNCOMMITTED) PR on PR.MVDID = CCQ.MVDID and MonthID = @MaxMI
		 LEFT JOIN tags_for_high_risk_members CP on CP.PartyKey = FM.PartyKey
		      JOIN ElixMemberRisk ex on ex.mvdid = fm.mvdid
	    WHERE CCQ.IsActive = 1 
		  AND IsNull(FM.CompanyKey,'0000') != '1338'
		  AND IsNull(CCQ.CaseOwner,'--') = '--'
		  AND IsNull(CA.PersonalHarm,0) = 0
		  AND IsNull(CP.Is_Top10pct_predicted,0) = 1 -- in top 10% of predicted cost
		  AND (IsNull([RX_PaidAmt_Prev360d],0) / (IsNull(Med_PaidAmt_Prev360d,0) + IsNull([RX_PaidAmt_Prev360d],0) + 1) < .75) -- less than 75% of cost coming from Rx
		  AND IsNull(PR.[HighDollarClaim],0) = 0  -- include only if emergent high cost
		  AND ex.groupid=@Grp
		  --AND IsNull(FM.COBCD,'U') in ('S','N','U')
		  --AND FM.GrpInitvCd != 'GRD' -- exclude members associated to Grand Rounds
		  AND CCQ.RiskGroupID between 4 and 6
		  AND NOT EXISTS (SELECT 1 FROM #ExcludedMVDID WHERE MVDID = CCQ.MVDID)

END