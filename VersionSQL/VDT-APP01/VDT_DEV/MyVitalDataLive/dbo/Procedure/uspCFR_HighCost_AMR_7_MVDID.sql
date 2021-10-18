/****** Object:  Procedure [dbo].[uspCFR_HighCost_AMR_7_MVDID]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[uspCFR_HighCost_AMR_7_MVDID] 
AS
/*

    CustID:  16
    RuleID:  248
 ProductID:  2
OwnerGroup:  168

Changes
WHO		WHEN		WHAT
Scott	2020-11-02	Modifiy to use Merge
Scott	2020-11-21	Applied changes from original
Scott   2021-05-11  Refactor to CTE and add Universal Exclusion for no benefit and hourly.
Scott   2021-08-05	Correct COBCD definition and add GRD and COBCD to CFR_Exclusion.
Scott	2021-09-21	Add CCM Exclusions and READUNCOMMITTED Query hints

EXEC uspCFR_HighCost_AMR_7_MVDID	--(28/:18)(28/:16)

EXEC uspCFR_Merge @MVDProcedureName = 'uspCFR_HighCost_AMR_7_MVDID', @CustID = 16, @RuleID = 248, @ProductID = 2, @OwnerGroup = 161

EXEC uspCFR_MapRuleExclusion @RuleID = 249, @Action='DISPLAY'


*/
BEGIN
	SET NOCOUNT ON;

	DECLARE @RuleID int = 248
	DECLARE @OwnerGroup int = 161

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

		 -- member is active (a) has no case manager (b) no personal harm (i) high prediction for top 10% hi ratio of Rx to Med
		 SELECT DISTINCT CCQ.MVDID
		   FROM ComputedCareQueue (READUNCOMMITTED) CCQ
	  LEFT JOIN ComputedMemberAlert (READUNCOMMITTED) CA ON CA.MVDID = CCQ.MVDID
	  LEFT JOIN FinalMember (READUNCOMMITTED) FM ON FM.MVDID = CCQ.MVDID
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
		    AND dx.CodeValue IN ('J4521','J4522','J4530','J4531','J4532','J4540','J4541','J4542','J4550','J4551','J4552','J45901','J45902','J45909','J45991','J45998')
			--AND ISNULL(FM.COBCD,'U') IN ('S','N','U')
		 --   AND FM.GrpInitvCd != 'GRD' -- exclude members associated to Grand Rounds
		    AND CCQ.RiskGroupID > 6
		    AND NOT EXISTS (SELECT 1 FROM #ExcludedMVDID WHERE MVDID = CCQ.MVDID)

END