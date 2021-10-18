/****** Object:  Procedure [dbo].[uspCFR_HighCost_HTN_4X_MVDID]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[uspCFR_HighCost_HTN_4X_MVDID] 
AS
/*

    CustID:  16
    RuleID:  285
 ProductID:  2
OwnerGroup:  156 Clinical Support

Changes
WHO		WHEN		WHAT
Scott	20201102	Modifiy to use Merge
Scott   2021-03-25	Refactor to CTE for performance and clarity.
Scott	2021-03-25	Add Company Exclusions and rename to uspCFR_HighCost_HTN_4X_MVDID
Scott	2021-05-25	Add Universal Exclusion for hourly and no benefit.
Scott	2021-09-07	Add query hints for Computed Care Queue

EXEC uspCFR_HighCost_HTN_4X_MVDID  --(1746/.10)(1746/.07)

EXEC uspCFR_Merge @MVDProcedureName = 'uspCFR_HighCost_HTN_4X_MVDID', @CustID = 16, @RuleID = 285, @ProductID = 2, @OwnerGroup = 156

EXEC uspCFR_MapRuleExclusion @RuleID = '285', @Action = 'DISPLAY'

*/

BEGIN
	SET NOCOUNT ON;

	DECLARE @RuleID int = 285
	DECLARE @Grp int = 7  -- 1= CHF, 10=COPD, 7 = Hypertension, 12 = Diabetes, 19 = Cancer, 9 = Chronic Neurolical condition

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
		 LEFT JOIN ComputedMemberAlert (READUNCOMMITTED) CA ON CA.MVDID = CCQ.MVDID
		 LEFT JOIN FinalMember (READUNCOMMITTED) FM ON FM.MVDID = CCQ.MVDID
		 LEFT JOIN ComputedMemberTotalPaidClaimsRollling12 (READUNCOMMITTED) PR ON PR.MVDID = CCQ.MVDID and MonthID = @MaxMI
		 LEFT JOIN tags_for_high_risk_members (READUNCOMMITTED) CP ON CP.PartyKey = FM.PartyKey
			  JOIN ElixMemberRisk (READUNCOMMITTED) ex ON ex.mvdid = fm.mvdid
			 WHERE CCQ.IsActive = 1 
			   AND ISNULL(FM.CompanyKey,'0000') != '1338'
			   AND ISNULL(CCQ.CaseOwner,'--') = '--'
			   AND ISNULL(CA.PersonalHarm,0) = 0
			   AND ISNULL(CP.Is_Top10pct_predicted,0) = 1 -- in top 10% of predicted cost
			   AND (ISNULL([RX_PaidAmt_Prev360d],0) / (ISNULL(Med_PaidAmt_Prev360d,0) + ISNULL([RX_PaidAmt_Prev360d],0) + 1) < .75) -- less than 75% of cost coming from Rx
			   AND ISNULL(PR.[HighDollarClaim],0) = 0  -- include only if emergent high cost
			   AND ex.groupid=@Grp
			   AND CCQ.RiskGroupID BETWEEN 4 AND 6
			   AND NOT EXISTS (SELECT 1 FROM #ExcludedMVDID WHERE MVDID = CCQ.MVDID)
END