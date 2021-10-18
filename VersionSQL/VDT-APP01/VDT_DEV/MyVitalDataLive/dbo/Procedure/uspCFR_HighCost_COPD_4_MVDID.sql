/****** Object:  Procedure [dbo].[uspCFR_HighCost_COPD_4_MVDID]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[uspCFR_HighCost_COPD_4_MVDID] 
AS
/*

   CustID:  16
    RuleID:  227
 ProductID:  2
OwnerGroup:  168 Rules Review

Changes
WHO		WHEN		WHAT
Scott	20201020	Create as MERGE CFR only
Scott	20201102	Update history to record ModifiedDate as GETUTCDATE and ModifiedBy as 'MERGE' 
Scott	20210428	Add Universal Exclusion for no benefit and hourly employees.
Scott	2021-09-21	Add CCM Exclusions and READUNCOMMITTED Query hints

EXEC uspCFR_HighCost_COPD_4_MVDID		--(9660/:18)(9660)

EXEC uspCFR_Merge @MVDProcedureName = 'uspCFR_HighCost_COPD_4_MVDID', @CustID = 16, @RuleID = 227, @ProductID = 2, @OwnerGroup = 168

*/
BEGIN
	SET NOCOUNT ON;

	DECLARE @RuleID int = 227
	DECLARE @Grp int = 10  -- 1= CHF, 10=COPD, 7 = Hypertension, 12 = Diabetes, 19 = Cancer, 9 = Chronic Neurolical condition

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
			   JOIN ElixMemberRisk (READUNCOMMITTED) ex on ex.mvdid = fm.mvdid
			  WHERE CCQ.IsActive = 1 
			    AND ISNULL(FM.COBCD,'U') IN ('S','N','U')
			    AND ISNULL(FM.CompanyKey,'0000') != '1338'
			    AND ISNULL(CCQ.CaseOwner,'--') = '--'
			    AND ISNULL(CA.PersonalHarm,0) = 0
			    AND ISNULL(CP.Is_Top10pct_predicted,0) = 1 -- in top 10% of predicted cost
			    AND (ISNULL([RX_PaidAmt_Prev360d],0) / (ISNULL(Med_PaidAmt_Prev360d,0) + ISNULL([RX_PaidAmt_Prev360d],0) + 1) < .75) -- less than 75% of cost coming from Rx
			    AND ISNULL(PR.[HighDollarClaim],0) = 0  -- include only if emergent high cost
			    AND ex.groupid=@Grp
			    AND FM.GrpInitvCd != 'GRD' -- exclude members associated to Grand Rounds
			    AND CCQ.RiskGroupID BETWEEN 4 AND 6
				AND NOT EXISTS (SELECT 1 FROM #ExcludedMVDID WHERE MVDID = CCQ.MVDID)

END