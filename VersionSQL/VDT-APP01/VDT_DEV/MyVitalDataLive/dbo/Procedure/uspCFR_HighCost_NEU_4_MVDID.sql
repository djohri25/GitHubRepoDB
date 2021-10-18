/****** Object:  Procedure [dbo].[uspCFR_HighCost_NEU_4_MVDID]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[uspCFR_HighCost_NEU_4_MVDID] 
AS
/*

    CustID:  16
    RuleID:  239
 ProductID:  2
OwnerGroup:  168 Rules Review

Changes
WHO		WHEN		WHAT
Scott	20201102	Modifiy to use Merge
Scott	2020-11-21	Applied changes from original
Scott	2021-03-25	Refactor to improve performance and clarity
Scott	2021-05-03	Add Universal Exclusions for no benefit and hourly.
Scott	2021-09-07	Add query hints for Computed Care Queue

EXEC uspCFR_HighCost_NEU_4_MVDID  --(2488/:23)(2488/:06) 

EXEC uspCFR_Merge @MVDProcedureName = 'uspCFR_HighCost_NEU_4X_MVDID', @CustID = 16, @RuleID = 239, @ProductID = 2, @OwnerGroup = 168

EXEC uspCFR_MapRuleExclusion @RuleID = '239', @Action = 'DISPLAY'

*/
BEGIN
	SET NOCOUNT ON;

	DECLARE @RuleID int = 238
	DECLARE @Grp int = 9  -- 1= CHF, 10=COPD, 7 = Hypertension, 12 = Diabetes, 19 = Cancer, 9 = Chronic Neurolical condition

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
			 --left join [VD-RPT02].[Datalogy].[ds].[tags_for_high_risk_members] CP on CP.PartyKey = FM.PartyKey /*Removed*/
		  LEFT JOIN [tags_for_high_risk_members] (READUNCOMMITTED) CP on CP.PartyKey = FM.PartyKey /*Added*/
			   JOIN ElixMemberRisk ex on ex.mvdid = fm.mvdid
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