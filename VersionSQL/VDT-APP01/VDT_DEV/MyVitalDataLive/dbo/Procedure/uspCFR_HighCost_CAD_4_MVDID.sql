/****** Object:  Procedure [dbo].[uspCFR_HighCost_CAD_4_MVDID]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[uspCFR_HighCost_CAD_4_MVDID] 
AS
/*

    CustID:  16
    RuleID:  252
 ProductID:  2
OwnerGroup:  168 Rules Review

Changes
WHO		WHEN		WHAT
        20200924	The definition of CAD change per email from Dr Spiro to dx.CodeValue in ('I2510','I4891','I509','I639','I6523',
						'I6529','I672','I679','I739','I209','I2109','I213','I252','I2584','I259','I10','I110','I119') 
Scott	20201102	Modify to use Merge
Scott	20210324	Refactor to CTE format for performance boost and clarity
Scott	20210520	Add UniversalExclusion to filter no benefits or hourly.
Scott	20210802	Add new exclusion code
Scott	2021-09-07	Add query hints for Computed Care Queue
Scott	2021-09-17	Add CCM Exclusions

EXEC uspCFR_HighCost_CAD_4_MVDID --(107,359/:05)

EXEC uspCFR_Merge @MVDProcedureName = 'uspCFR_HighCost_CAD_4_MVDID', @CustID = 16, @RuleID = 252, @ProductID = 2, @OwnerGroup = 168

EXEC uspCFR_MapRuleExclusion @RuleID = 252, @Action='ADD', @ExclusionID=21

*/
BEGIN
	SET NOCOUNT ON;

	DECLARE @RuleID int = 252
	DECLARE @OwnerGroup int = 168

	DECLARE @MaxMI varchar(6)
	SELECT TOP 1  @MaxMI = monthid FROM [MyVitalDataLive].[dbo].[ComputedMemberTotalPaidClaimsRollling12] ORDER BY id DESC

-- Admin Exclusion Code
	DROP TABLE IF EXISTS #ExcludedMVDID
	CREATE TABLE #ExcludedMVDID (MVDID varchar(30))

	INSERT INTO #ExcludedMVDID (MVDID)
	SELECT DISTINCT em.MVDID
	  FROM CFR_Rule_Exclusion re
	  JOIN HPWorkFlowRule wfr ON wfr.Rule_ID = re.RuleID
	  JOIN CFR_ExcludedMVDID em ON em.ExclusionID = re.ExclusionID
	  JOIN CFR_Exclusion e ON em.ExclusionID = e.ID
	 WHERE wfr.Body = OBJECT_NAME(@@PROCID)

	MERGE INTO #ExcludedMVDID AS tgt
	USING (SELECT MVDID
	         FROM FinalMember fm
			 JOIN ABCBS_GrpCcmEligMbr ccm ON fm.MemberID = ccm.MRB_ID
            WHERE CCM_GRP_ELIG_IND = 'N') src
		ON tgt.MVDID = src.MVDID
	  WHEN NOT MATCHED THEN INSERT (MVDID) VALUES (MVDID);

	CREATE INDEX IX_ExcludedMVDID ON #ExcludedMVDID (MVDID)

			SELECT DISTINCT CCQ.MVDID
			  FROM ComputedCareQueue (READUNCOMMITTED) CCQ
		 LEFT JOIN FinalMember (READUNCOMMITTED) FM on FM.MVDID = CCQ.MVDID
		 LEFT JOIN ComputedMemberAlert (READUNCOMMITTED) CA on CA.MVDID = CCQ.MVDID
			   AND ISNULL(CA.PersonalHarm,0) = 0
		 LEFT JOIN ComputedMemberTotalPaidClaimsRollling12 (READUNCOMMITTED) PR on PR.MVDID = CCQ.MVDID and MonthID = @MaxMI
			   AND ISNULL(PR.[HighDollarClaim],0) = 0  -- include only if emergent high cost
		 LEFT JOIN [tags_for_high_risk_members] (READUNCOMMITTED) CP on CP.PartyKey = FM.PartyKey  /*Added*/
			   AND ISNULL(CP.Is_Top10pct_predicted,0) = 1 -- in top 10% of predicted cost
			   AND (ISNULL(CP.[RX_PaidAmt_Prev360d],0) / (ISNULL(CP.Med_PaidAmt_Prev360d,0) + ISNULL(CP.[RX_PaidAmt_Prev360d],0) + 1) < .75) -- less than 75% of cost coming from Rx
		 LEFT JOIN FinalClaimsHeader (READUNCOMMITTED) H on H.MVDID = FM.MVDID
		 LEFT JOIN FinalClaimsHeaderCode (READUNCOMMITTED) Dx on Dx.MVDID = H.MVDID and H.ClaimNumber = Dx.ClaimNumber
			   AND LEFT(dx.CodeValue,3) BETWEEN 'I20' AND 'I25'
			 WHERE CCQ.IsActive = 1 
			   AND ISNULL(CCQ.CaseOwner,'--') = '--'
			   AND CCQ.RiskGroupID BETWEEN 4 AND 6
		       AND NOT EXISTS (SELECT 1 FROM #ExcludedMVDID WHERE MVDID = CCQ.MVDID)
		   		 		 
END