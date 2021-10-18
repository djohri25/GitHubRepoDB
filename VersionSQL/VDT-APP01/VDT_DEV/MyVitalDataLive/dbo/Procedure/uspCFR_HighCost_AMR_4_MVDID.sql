/****** Object:  Procedure [dbo].[uspCFR_HighCost_AMR_4_MVDID]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[uspCFR_HighCost_AMR_4_MVDID] 
AS
/*

    CustID:  16
    RuleID:  249
 ProductID:  2
OwnerGroup:  168 RulesReview

Changes
WHO		WHEN		WHAT
Scott	20201102	Modifiy to use Merge
Scott   20210324    Refactor in CTE format for performance boost and clarity
Scott	20210802    Add new exclusion method
Scott   20210805	Correct COBCD definition and add GRD and COBCD to CFR_Exclusion.
Scott	2021-09-07	Add query hints for Computed Care Queue
Scott	2021-09-21	Add CCM Exclusions

EXEC uspCFR_HighCost_AMR_4_MVDID   --(6042/5:10)(4:41/6038)

EXEC uspCFR_Merge @MVDProcedureName = 'uspCFR_HighCost_AMR_4_MVDID', @CustID = 16, @RuleID = 249, @ProductID = 2, @OwnerGroup = 168

EXEC uspCFR_MapRuleExclusion @RuleID = 249, @Action='ADD', @ExclusionID=21

*/
BEGIN
	SET NOCOUNT ON;

	DECLARE @RuleID int = 249

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
			LEFT JOIN [tags_for_high_risk_members] (READUNCOMMITTED) CP on CP.PartyKey = FM.PartyKey  /*Added*/
			LEFT JOIN FinalClaimsHeader (READUNCOMMITTED) H on H.MVDID = FM.MVDID
			LEFT JOIN FinalClaimsHeaderCode (READUNCOMMITTED) Dx on Dx.MVDID = H.MVDID and H.ClaimNumber = Dx.ClaimNumber
				WHERE CCQ.IsActive = 1 
				  AND ISNULL(CCQ.CaseOwner,'--') = '--'
				  AND ISNULL(CA.PersonalHarm,0) = 0
				  AND ISNULL(CP.Is_Top10pct_predicted,0) = 1 -- in top 10% of predicted cost
				  AND (ISNULL([RX_PaidAmt_Prev360d],0) / (ISNULL(Med_PaidAmt_Prev360d,0) + ISNULL([RX_PaidAmt_Prev360d],0) + 1) < .75) -- less than 75% of cost coming from Rx
				  AND ISNULL(PR.[HighDollarClaim],0) = 0  -- include only if emergent high cost
				  AND dx.CodeValue IN ('J4521','J4522','J4530','J4531','J4532','J4540','J4541','J4542','J4550',
				                       'J4551','J4552','J45901','J45902','J45909','J45991','J45998')
				  AND CCQ.RiskGroupID BETWEEN 4 AND 6
				  AND NOT EXISTS (SELECT 1 FROM #ExcludedMVDID WHERE MVDID = CCQ.MVDID)

END