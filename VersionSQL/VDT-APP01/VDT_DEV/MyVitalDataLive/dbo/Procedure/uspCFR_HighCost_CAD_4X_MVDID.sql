/****** Object:  Procedure [dbo].[uspCFR_HighCost_CAD_4X_MVDID]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[uspCFR_HighCost_CAD_4X_MVDID] 
AS
/*

    CustID:  16
    RuleID:  290
 ProductID:  2
OwnerGroup:  159 Clinical Support

Changes
WHO		WHEN		WHAT
        20200924	The definition of CAD change per email from Dr Spiro to dx.CodeValue in ('I2510','I4891','I509','I639','I6523',
						'I6529','I672','I679','I739','I209','I2109','I213','I252','I2584','I259','I10','I110','I119') 
Scott	20201102	Modify to use Merge
Scott	20210324	Refactor to CTE format for performance boost and clarity
Scott	20210324	Add Company Exclusion and change name to uspCFR_HighCost_CAD_4X_MVDID
Scott	20210514	Add Universal Exclusion for hourly and no benefit.
Scott	20210802	Add new exclusion code
Scott   20210805	Correct COBCD definition and add GRD and COBCD to CFR_Exclusion.
Scott	2021-09-07	Add query hints for Computed Care Queue

EXEC uspCFR_HighCost_CAD_4X_MVDID --(59,666 /07) (59,940/06)

EXEC uspCFR_Merge @MVDProcedureName = 'uspCFR_HighCost_CAD_4X_MVDID', @CustID = 16, @RuleID = 290, @ProductID = 2, @OwnerGroup = 159

EXEC uspCFR_MapRuleExclusion @RuleID = 290, @Action='DISPLAY'


*/
BEGIN
	SET NOCOUNT ON;

	DECLARE @RuleID int = 290
	DECLARE @OwnerGroup int = 159

	DECLARE @MaxMI varchar(6)
	SELECT TOP 1  @MaxMI = monthid FROM [MyVitalDataLive].[dbo].[ComputedMemberTotalPaidClaimsRollling12] ORDER BY id DESC

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