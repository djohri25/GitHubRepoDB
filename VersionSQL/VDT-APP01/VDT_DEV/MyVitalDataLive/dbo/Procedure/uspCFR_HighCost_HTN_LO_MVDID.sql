/****** Object:  Procedure [dbo].[uspCFR_HighCost_HTN_LO_MVDID]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[uspCFR_HighCost_HTN_LO_MVDID] 
AS
/*

    CustID:  16
    RuleID:  231
 ProductID:  2
OwnerGroup:  168

Changes
WHO		WHEN		WHAT
Scott	20201102	Modifiy to use Merge
Scott	20210429	Add Universal Exclusion for no benefit and hourly.  Reformate to CTE.
Scott	20210802	Add new exclusion code
Scott	2021-09-07	Add query hints for Computed Care Queue

EXEC uspCFR_HighCost_HTN_LO_MVDID	--(7567/16)(7567/12)

EXEC uspCFR_Merge @MVDProcedureName = 'uspCFR_HighCost_HTN_LO_MVDID', @CustID = 16, @RuleID = 231, @ProductID = 2, @OwnerGroup = 168

EXEC uspCFR_MapRuleExclusion @RuleID = '231', @Action = 'DISPLAY'

*/
BEGIN
	SET NOCOUNT ON;

	DECLARE @RuleID int = 231
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

			-- member is active (a) has no case manager (b) no personal harm (i) high prediction for top 10% hi ratio of Rx to Med
			 SELECT DISTINCT CCQ.MVDID
			   FROM ComputedCareQueue (READUNCOMMITTED) CCQ
  		  LEFT JOIN ComputedMemberAlert (READUNCOMMITTED) CA on CA.MVDID = CCQ.MVDID
	      LEFT JOIN FinalMember (READUNCOMMITTED) FM on FM.MVDID = CCQ.MVDID
		  LEFT JOIN ComputedMemberTotalPaidClaimsRollling12 (READUNCOMMITTED) PR on PR.MVDID = CCQ.MVDID and MonthID = @MaxMI
		  LEFT JOIN tags_for_high_risk_members (READUNCOMMITTED) CP on CP.PartyKey = FM.PartyKey
			   JOIN ElixMemberRisk (READUNCOMMITTED) ex on ex.mvdid = fm.mvdid
			  WHERE CCQ.IsActive = 1 
			    AND ISNULL(FM.CompanyKey,'0000') != '1338'
			    AND ISNULL(CCQ.CaseOwner,'--') = '--'
			    AND ISNULL(CA.PersonalHarm,0) = 0
			    AND ISNULL(CP.Is_Top10pct_predicted,0) = 1 -- in top 10% of predicted cost
			    AND (ISNULL([RX_PaidAmt_Prev360d],0) / (ISNULL(Med_PaidAmt_Prev360d,0) + ISNULL([RX_PaidAmt_Prev360d],0) + 1) < .75) -- less than 75% of cost coming from Rx
			    AND ISNULL(PR.[HighDollarClaim],0) = 0  -- include only if emergent high cost
			    AND ex.groupid=@Grp
			    AND CCQ.RiskGroupID < 4
				AND NOT EXISTS (SELECT 1 FROM #ExcludedMVDID WHERE MVDID = CCQ.MVDID)

END