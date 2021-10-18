/****** Object:  Procedure [dbo].[uspCFR_DiabetesRenal_MVDID]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[uspCFR_DiabetesRenal_MVDID]
AS
/*
    CustID:  16
    RuleID:  217
 ProductID:  2
OwnerGroup:  168

Changes
WHO		WHEN		WHAT
Scott	2020-10-2	CREATEd by refactor of original to call uspCFR_Merge
Scott   2021-05-11  Refactor to CTE and add Universal Exclusion for no benefit and hourly.
Scott   2021-07-29  Add new exclusion logic
Scott	2021-09-07	Add query hints for Computed Care Queue
Scott	2021-09-17	Add CCM Exclusions

EXEC uspCFR_DiabetesRenal_MVDID  --1/:15

EXEC uspCFR_Merge @MVDProcedureName = 'uspCFR_DiabetesRenal_MVDID', @CustID = 16, @RuleID = 217, @ProductID = 2, @OwnerGroup= 168

EXEC uspCFR_MapRuleExclusion @RuleID = '217', @Action = 'DISPLAY'

*/
BEGIN
SET NOCOUNT ON;

	DECLARE @MaxMI varchar(6)
	SELECT TOP 1  @MaxMI = monthid FROM [MyVitalDataLive].[dbo].[ComputedMemberTotalPaidClaimsRollling12] ORDER BY ID DESC

	DROP TABLE IF EXISTS #ExcludedMVDID
	CREATE TABLE #ExcludedMVDID (MVDID varchar(30), Exclusion varchar(50))

	INSERT INTO #ExcludedMVDID (MVDID, Exclusion)
	SELECT em.MVDID, e.Exclusion  
	  FROM CFR_ExcludedMVDID em
	  JOIN CFR_Exclusion e ON em.ExclusionID = e.ID 
	  JOIN CFR_Rule_Exclusion re ON em.ExclusionID = re.ExclusionID
	  JOIN HPWorkFlowRule wfr ON wfr.Rule_ID = re.RuleID
	 WHERE wfr.Body = OBJECT_NAME(@@PROCID)

	MERGE INTO #ExcludedMVDID AS tgt
	USING (SELECT MVDID
	         FROM FinalMember fm
			 JOIN ABCBS_GrpCcmEligMbr ccm ON fm.MemberID = ccm.MRB_ID
            WHERE CCM_GRP_ELIG_IND = 'N') src
		ON tgt.MVDID = src.MVDID
	  WHEN NOT MATCHED THEN INSERT (MVDID) VALUES (MVDID);
	  
CREATE INDEX IX_ExcludedMVDID ON #ExcludedMVDID (MVDID)

		-- member is active (a), has no case manager (b), no personal harm (i),	high prediction for Renal, obesity, SDOH SocioEconomic
			SELECT DISTINCT CCQ.MVDID
			  FROM ComputedCareQueue (READUNCOMMITTED) CCQ
		 LEFT JOIN ComputedMemberAlert (READUNCOMMITTED) CA on CA.MVDID = CCQ.MVDID
		 LEFT JOIN FinalMember (READUNCOMMITTED) FM on FM.MVDID = CCQ.MVDID
		 LEFT JOIN ComputedMemberTotalPaidClaimsRollling12 (READUNCOMMITTED) PR on PR.MVDID = CCQ.MVDID and MonthID = @MaxMI
			--left join [VD-RPT02].[Datalogy].[ds].[tags_for_high_risk_members] CP on CP.PartyKey = FM.PartyKey /*Removed*/
		 LEFT JOIN [tags_for_high_risk_members] (READUNCOMMITTED) CP on CP.PartyKey = FM.PartyKey /*Added*/
			 WHERE CCQ.IsActive = 1 
			   AND ISNULL(FM.CompanyKey,'0000') != '1338'
			   AND ISNULL(CCQ.CaseOwner,'--') = '--'
			   AND ISNULL(CA.PersonalHarm,0) = 0
			   AND ISNULL(CP.Is_Renal3_predicted,0) = 1  -- highest predicted progression to renal
			   AND ISNULL(CP.SDOH_Vulnerable_Socioeconomic,0) > .75 -- SocioEconomic vulnerability index > .75
			   AND ISNULL(CP.[Is_Depressed_in_History],0) = 1 -- has personal history of depression
			   AND ISNULL(CP.Family_Size,0) = 1 -- has family size = 1
			   AND ISNULL(CP.[GapInCare_CDC_ha1c],0) = 1 -- has a Gap in Care around Ha1c
			   AND ISNULL(CP.[ElixGrp_DC_in_history],0) = 1 -- has Elixhauser class of Diabetes Complicated
			   AND ISNULL(PR.[HighDollarClaim],0) = 0  -- include only if emergent high cost
			   AND NOT EXISTS (SELECT 1 FROM #ExcludedMVDID WHERE MVDID = CCQ.MVDID)

END