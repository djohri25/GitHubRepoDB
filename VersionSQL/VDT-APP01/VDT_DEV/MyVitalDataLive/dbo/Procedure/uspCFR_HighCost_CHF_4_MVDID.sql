/****** Object:  Procedure [dbo].[uspCFR_HighCost_CHF_4_MVDID]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[uspCFR_HighCost_CHF_4_MVDID] 
AS
/*
    CustID:  16
    RuleID:  224
 ProductID:  2
OwnerGroup:  168  Rules Review

Changes
WHO		WHEN		WHAT
Scott	2020-10-2	ALTERd by refactor of original to call uspCFR_Merge
Scott	2020-11-21	Applied changes made to original
Scott	2021-03-25  Reformat to CTE for performance and clarity
Scott	2021-04-22	Add Universal Exclusion for no benefits and hourly.
Scott	2012-08-02	Add exclusion code
Scott	2021-09-07	Add query hints for Computed Care Queue
Scott	2021-09-21	Add CCM Exclusions 

EXEC uspCFR_HighCost_CHF_4_MVDID	--(24288/:24) (24313:27)

EXEC uspCFR_Merge @MVDProcedureName = 'uspCFR_HighCost_CHF_4_MVDID', @CustID = 16, @RuleID = 224, @ProductID = 2, @OwnerGroup= 168

EXEC uspCFR_MapRuleExclusion @RuleID = '224', @Action = 'DISPLAY'

*/
BEGIN
	SET NOCOUNT ON;

	DECLARE @RuleID int = 224
	DECLARE @Grp int = 1  -- 1= CHF, 10=COPD, 7 = Hypertension, 12 = Diabetes, 19 = Cancer, 9 = Chronic Neurolical condition

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

     --Members must be in CCM_6 for this group, so exclude all others
	MERGE INTO #ExcludedMVDID AS tgt
	USING (SELECT MVDID
	         FROM FinalMember fm
			 JOIN ABCBS_GrpCcmEligMbr ccm ON fm.MemberID = ccm.MRB_ID
            WHERE (CCM_GRP_ELIG_IND = 'N'				
			   OR ISNULL(CCM_TYPE,'') NOT IN ('CCM_6'))
			) src
		ON tgt.MVDID = src.MVDID
	  WHEN NOT MATCHED THEN INSERT (MVDID) VALUES (MVDID);

	CREATE INDEX IX_ExcludedMVDID ON #ExcludedMVDID (MVDID)

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
			    AND ISNULL(CP.Is_Top10pct_predicted,0) = 1	-- in top 10% of predicted cost
			    AND (ISNULL([RX_PaidAmt_Prev360d],0) / (ISNULL(Med_PaidAmt_Prev360d,0) + ISNULL([RX_PaidAmt_Prev360d],0) + 1) < .75) -- less than 75% of cost coming from Rx
			    AND ISNULL(PR.[HighDollarClaim],0) = 0		-- include only if emergent high cost
			    AND ex.groupid=@Grp
			    AND ISNULL(FM.COBCD,'U') in ('S','N','U')
			    AND FM.GrpInitvCd != 'GRD'					-- exclude members associated to Grand Rounds
			    AND CCQ.RiskGroupID BETWEEN 4 AND 6
				AND NOT EXISTS (SELECT 1 FROM #ExcludedMVDID WHERE MVDID=CCQ.MVDID)

END