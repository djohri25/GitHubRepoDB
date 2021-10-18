/****** Object:  Procedure [dbo].[uspCFR_SUDandDepression_MVDID]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[uspCFR_SUDandDepression_MVDID]
AS
/*
    CustID:  16
    RuleID:  214
 ProductID:  2
OwnerGroup:  168

Changes
WHO		WHEN		WHAT
Scott	2020-10-2	Created by refactor of original to call uspCFR_Merge
Scott	2021-04-19	Refactor to CTE and add Universal Exclusion for No Benefit and Hourly

EXEC uspCFR_SUDandDepression_MVDID  --(1028/:19)(1031/:11)

EXEC uspCFR_Merge @MVDProcedureName = 'uspCFR_SUDandDepression_MVDID', @CustID = 16, @RuleID = 214, @ProductID = 2, @OwnerGroup= 168

EXEC uspCFR_MapRuleExclusion @pRuleID = '214', @pAction = 'DISPLAY'

*/
BEGIN
	SET NOCOUNT ON;
	DECLARE @MaxMI varchar(6)
	SELECT TOP 1  @MaxMI = monthid FROM [MyVitalDataLive].[dbo].[ComputedMemberTotalPaidClaimsRollling12] order by id desc

	DROP TABLE IF EXISTS #ExcludedMVDID
	CREATE TABLE #ExcludedMVDID (MVDID varchar(30))

	INSERT INTO #ExcludedMVDID (MVDID)
	SELECT DISTINCT em.MVDID
	  FROM CFR_Rule_Exclusion re
	  JOIN HPWorkFlowRule wfr ON wfr.Rule_ID = re.RuleID
	  JOIN CFR_ExcludedMVDID em ON em.ExclusionID = re.ExclusionID
	  JOIN CFR_Exclusion e ON em.ExclusionID = e.ID
	 WHERE wfr.Body = OBJECT_NAME(@@PROCID)

		SELECT DISTINCT CCQ.MVDID
		  FROM ComputedCareQueue CCQ
	 LEFT JOIN ComputedMemberAlert CA on CA.MVDID = CCQ.MVDID
	 LEFT JOIN FinalMember FM on FM.MVDID = CCQ.MVDID
	 LEFT JOIN ComputedMemberTotalPaidClaimsRollling12 PR on PR.MVDID = CCQ.MVDID and MonthID = @MaxMI
	 LEFT JOIN tags_for_high_risk_members CP on CP.PartyKey = FM.PartyKey
	     WHERE CCQ.IsActive = 1 
	       AND ISNULL(FM.COBCD,'U') in ('S','N','U')
	       AND ISNULL(FM.CompanyKey,'0000') != '1338'
	       AND ISNULL(CCQ.CaseOwner,'--') = '--'
	       AND FM.GrpInitvCd != 'GRD' -- exclude members associated to Grand Rounds
	       AND ISNULL(CA.PersonalHarm,0) = 0
	       AND ISNULL(CP.Is_SUD3_predicted,0) = 1
	       AND ISNULL(CP.[Family_Size],0) = 1 -- family size of 1
	       AND ISNULL(CP.[SDOH_Vulnerable_Socioeconomic],0) > .75  -- SocioEconomic stress factor > 75%
	       AND ISNULL(CP.[Count_Dist_Chronic_CCS_in_history],0) >= 5 -- 5 or more CCS in history
	       AND ISNULL(PR.[HighDollarClaim],0) = 0  -- include only if emergent high cost
		   AND NOT EXISTS (SELECT 1 FROM #ExcludedMVDID WHERE MVDID = CCQ.MVDID)
END