/****** Object:  Procedure [dbo].[uspCFR_Depression_MVDID]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[uspCFR_Depression_MVDID]
AS
/*
    CustID:  16
    RuleID:  213
 ProductID:  2
OwnerGroup:  168

Changes
WHO		WHEN		WHAT
Scott	2020-10-30	CREATEd by refactor of original to call uspCFR_Merge
Scott	2021-04-19	Added Universal Exclusion for no benefits and hourly.
Scott	2021-07-28  Added New Exclusion Logic
Scott	2021-09-07	Add query hints for Computed Care Queue

EXEC uspCFR_Depression_MVDID  --(135/:13) (135/:11)

EXEC uspCFR_Merge @MVDProcedureName = 'uspCFR_Depression_MVDID', @CustID = 16, @RuleID = 213, @ProductID = 2, @OwnerGroup= 168

EXEC uspCFR_MapRuleExclusion @RuleID = '213', @Action='DISPLAY'

*/
BEGIN
	SET NOCOUNT ON;

	DECLARE @MaxMI varchar(6)
	SELECT TOP 1  @MaxMI = monthid FROM [MyVitalDataLive].[dbo].[ComputedMemberTotalPaidClaimsRollling12] order by id desc

	--new exxclusion code
	DROP TABLE IF EXISTS #ExcludedMVDID
	CREATE TABLE #ExcludedMVDID (MVDID varchar(30), Exclusion varchar(50))

	INSERT INTO #ExcludedMVDID (MVDID, Exclusion)
	SELECT em.MVDID, e.Exclusion  
	  FROM CFR_ExcludedMVDID em
	  JOIN CFR_Exclusion e ON em.ExclusionID = e.ID 
	  JOIN CFR_Rule_Exclusion re ON em.ExclusionID = re.ExclusionID
	  JOIN HPWorkFlowRule wfr ON wfr.Rule_ID = re.RuleID
	 WHERE wfr.Body = OBJECT_NAME(@@PROCID)

	 CREATE INDEX IX_ExcludedMVDID ON #ExcludedMVDID (MVDID)

		-- member is active (a), has no case manager (b),no personal harm (i)
	    -- top 10 % for cost (AC2), high prediction of undiagnosed depression,  high stressed community SDOH
		SELECT DISTINCT CCQ.MVDID
		  FROM ComputedCareQueue (READUNCOMMITTED) CCQ
	 LEFT JOIN ComputedMemberAlert (READUNCOMMITTED) CA on CA.MVDID = CCQ.MVDID
	 LEFT JOIN FinalMember (READUNCOMMITTED) FM on FM.MVDID = CCQ.MVDID
	 LEFT JOIN ComputedMemberTotalPaidClaimsRollling12 (READUNCOMMITTED) PR on PR.MVDID = CCQ.MVDID and MonthID = @MaxMI
	 LEFT JOIN tags_for_high_risk_members (READUNCOMMITTED) CP on CP.PartyKey = FM.PartyKey
		 WHERE CCQ.IsActive = 1 
		   AND ISNULL(CCQ.CaseOwner,'--') = '--'
		   AND ISNULL(FM.CompanyKey,'0000') != '1338'
		   AND ISNULL(CA.PersonalHarm,0) = 0
		   AND ISNULL(CP.Is_Depress3_predicted,0) = 1 -- highest predicted for depression
		   AND ISNULL(CP.SDOH_Vulnerable_OverAll,0) > 0.75 -- SocioEconomic stress ratio > 75%
		   AND ISNULL(CP.[Family_Size],0) = 1 -- family size of 1
		   AND ISNULL(CP.[GapInCare_MedExam],0) = 1 -- Gap in Care for medical exam
		   AND ISNULL(CP.[Count_Dist_Chronic_CCS_in_history],0) >= 5 -- history of 5 or more chronic conditions
		   AND ISNULL(PR.[HighDollarClaim],0) = 0  -- include only if emergent high cost
		   AND ISNULL(FM.COBCD,'U') in ('S','N','U')
		   --AND FM.GrpInitvCd != 'GRD' -- exclude members associated to Grand Rounds
		   AND NOT EXISTS (SELECT 1 FROM #ExcludedMVDID WHERE MVDID = CCQ.MVDID)

END