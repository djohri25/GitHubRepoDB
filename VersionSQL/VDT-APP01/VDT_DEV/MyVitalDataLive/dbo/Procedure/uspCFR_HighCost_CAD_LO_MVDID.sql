/****** Object:  Procedure [dbo].[uspCFR_HighCost_CAD_LO_MVDID]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[uspCFR_HighCost_CAD_LO_MVDID] 
AS
/*

    CustID:  16
    RuleID:  253
 ProductID:  2
OwnerGroup:  168

Changes
WHO		WHEN		WHAT
Scott	20201102	Modifiy to use Merge
Scott	2020-11-21	Applied changes from original
Scott	2021-05-20	Modified to CTE and add Universal Exclusion
Scott	2021-08-02	Added new exclusion code.
Scott   2021-08-05	Correct COBCD definition and add GRD and COBCD to CFR_Exclusion.
Scott	2021-09-07	Add query hints for Computed Care Queue

EXEC uspCFR_HighCost_CAD_LO_MVDID  --(18,202/4:17)(18189/4:12)

EXEC uspCFR_Merge @MVDProcedureName = 'uspCFR_HighCost_CAD_LO_MVDID', @CustID = 16, @RuleID = 253, @ProductID = 2, @OwnerGroup = 168

EXEC uspCFR_MapRuleExclusion @RuleID = 253, @Action='DISPLAY'

*/
BEGIN
	SET NOCOUNT ON;

	DECLARE @RuleID int = 253
	DECLARE @OwnerGroup int = 168

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

	;WITH ComputedQueues AS
		(
		   SELECT DISTINCT CCQ.MVDID 
			 FROM ComputedCareQueue (READUNCOMMITTED) CCQ
			 JOIN ComputedMemberTotalPaidClaimsRollling12 (READUNCOMMITTED) PR ON PR.MVDID = CCQ.MVDID AND MonthID = @MaxMI
			  AND ISNULL(PR.[HighDollarClaim],0) = 0  -- include only if emergent high cost
			 JOIN ComputedMemberAlert (READUNCOMMITTED) CA on CA.MVDID = CCQ.MVDID
			  AND ISNULL(CA.PersonalHarm,0) = 0
			WHERE CCQ.IsActive = 1 
			  AND ISNULL(CCQ.CaseOwner,'--') = '--'
			  AND CCQ.RiskGroupID < 4
		 ),
		 Claims AS
		 (
			SELECT DISTINCT FM.MVDID 
			  FROM FinalMember (READUNCOMMITTED) FM 
			  JOIN [tags_for_high_risk_members] CP ON CP.PartyKey = FM.PartyKey				--Added
		   	   AND ISNULL(CP.Is_Top10pct_predicted,0) = 1 -- in top 10% of predicted cost
																							-- less than 75% of cost coming from Rx
			   AND (ISNULL(CP.[RX_PaidAmt_Prev360d],0) / (ISNULL(CP.Med_PaidAmt_Prev360d,0) + ISNULL(CP.[RX_PaidAmt_Prev360d],0) + 1) < .75) 
			  JOIN FinalClaimsHeader (READUNCOMMITTED) H on H.MVDID = FM.MVDID
			  JOIN FinalClaimsHeaderCode (READUNCOMMITTED) Dx on Dx.MVDID = H.MVDID and H.ClaimNumber = Dx.ClaimNumber
			   AND LEFT(Dx.CodeValue,3) BETWEEN 'I20' AND 'I25'
			 WHERE ISNULL(FM.COBCD,'U') IN ('S','N','U')
			   AND FM.GrpInitvCd != 'GRD'													-- exclude members associated to Grand Rounds
		 )
		 SELECT DISTINCT cq.MVDID
		   FROM ComputedQueues cq
	       JOIN Claims c ON cq.MVDID = c.MVDID
		  WHERE NOT EXISTS (SELECT 1 FROM #ExcludedMVDID WHERE MVDID = CQ.MVDID)

END