/****** Object:  Procedure [dbo].[uspCFR_top10HiRxMedRatio_MVDID]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[uspCFR_top10HiRxMedRatio_MVDID]
AS
/*
    CustID:  16
    RuleID:  221
 ProductID:  2
OwnerGroup:  153

Changes
WHO		WHEN		WHAT
Scott	2020-10-2	ALTERd by refactor of original to call uspCFR_Merge
Scott	2021-04-20	Refactor to CTE form and add Universal Exclusion for no benefits and hourly.
Scott	2021-09-07	Add query hints for Computed Care Queue

EXEC uspCFR_Top10RxMedRatio_MVDID	--(683/:13)(683/:12)

EXEC uspCFR_Merge @MVDProcedureName = 'uspCFR_Top10HiRxMedRatio_MVDID', @CustID = 16, @RuleID = 221, @ProductID = 2, @OwnerGroup= 153

EXEC uspCFR_MapRuleExclusion @RuleID = '221', @Action = 'DISPLAY'
*/
BEGIN
	SET NOCOUNT ON;

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

			-- member is active (a), has no case manager (b), no personal harm (i), high prediction for top 10%, hi ratio of Rx to Med
			SELECT DISTINCT CCQ.MVDID
			  FROM ComputedCareQueue (READUNCOMMITTED) CCQ
		 LEFT JOIN ComputedMemberAlert (READUNCOMMITTED) CA on CA.MVDID = CCQ.MVDID
		 LEFT JOIN FinalMember (READUNCOMMITTED) FM on FM.MVDID = CCQ.MVDID
		 LEFT JOIN ComputedMemberTotalPaidClaimsRollling12  (READUNCOMMITTED) PR on PR.MVDID = CCQ.MVDID and MonthID = @MaxMI
		 LEFT JOIN tags_for_high_risk_members (READUNCOMMITTED) CP on CP.PartyKey = FM.PartyKey
			 WHERE CCQ.IsActive = 1 
			   AND ISNULL(FM.CompanyKey,'0000') != '1338'
			   AND ISNULL(CCQ.CaseOwner,'--') = '--'
			   AND ISNULL(CA.PersonalHarm,0) = 0
			   AND ISNULL(CP.Is_Top10pct_predicted,0) = 1 -- in top 10% of predicted cost
			   AND (ISNULL([RX_PaidAmt_Prev360d],0) / (ISNULL(Med_PaidAmt_Prev360d,0) + ISNULL([RX_PaidAmt_Prev360d],0) + 1) >= .75) -- less than 75% of cost coming from Rx
			   AND ISNULL(CP.[SDOH_Vulnerable_Socioeconomic],0) > .75  -- SocioEconomic stress factor > 75%
			--unknown code.  
			--and IsNull(CP.[Family_Size],0) = 1 -- family size of 1
			--and IsNull(CP.[Is_Depressed_in_History],0) = 1 -- personal history of depression
			--and IsNull(CP.[Count_Dist_Chronic_CCS_in_history],0) >= 5 -- 5 or more CCS in history
			   AND ISNULL(CP.[Count_EDvisits_in_Prev120d],0) > 1 -- more than one ED visit in last 4 months
			   AND ISNULL(PR.[HighDollarClaim],0) = 0  -- include only if emergent high cost
			   AND NOT EXISTS (SELECT 1 FROM #ExcludedMVDID WHERE MVDID = CCQ.MVDID)

END