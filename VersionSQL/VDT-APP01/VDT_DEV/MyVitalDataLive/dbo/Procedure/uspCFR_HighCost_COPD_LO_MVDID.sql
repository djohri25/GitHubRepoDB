/****** Object:  Procedure [dbo].[uspCFR_HighCost_COPD_LO_MVDID]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[uspCFR_HighCost_COPD_LO_MVDID] 
AS
/*

    CustID:  16
    RuleID:  228
 ProductID:  2
OwnerGroup:  168

Changes
WHO		WHEN		WHAT
Scott	20201102	Modifiy to use Merge
Scott	2020-11-21	Applied changes from original
Scott	2021-08-02	Added new exclusion code.

EXEC uspCFR_HighCost_COPD_LO_MVDID --(26769/:16) (26769/:13)

EXEC uspCFR_Merge @MVDProcedureName = 'uspCFR_HighCost_COPD_LO_MVDID', @CustID = 16, @RuleID = 228, @ProductID = 2, @OwnerGroup = 168

*/
BEGIN

	SET NOCOUNT ON;

	DECLARE @RuleID int = 228
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

	--;WITH StandardExclusion AS
	--	( -- active member management form (c) for specific program types
	--	   SELECT MVDID, 'Active' AS Rsn 
	--	     FROM ABCBS_MemberManagement_Form MMF
	--	    WHERE MMF.CaseProgram IN ('case management', 'chronic condition management', 'maternity')
	--	      AND ISNULL(MMF.SectionCompleted,9) < 3
	--	    UNION -- denial in last 120 days (d) for specific program types
	--	   SELECT DISTINCT MVDID, 'Refused' AS Rsn 
	--	    FROM ABCBS_MemberManagement_Form MMF
	--	   WHERE MMF.CaseProgram IN ('case management', 'chronic condition management', 'maternity')
	--	     AND (MMF.qNonViableReason1 = 'member/family refused case management' 
	--		      OR MMF.q2ConsentNonViable = 'member/family refused case management' 
	--		      OR MMF.qNoReason = 'member/family refused case management'
	--		      OR MMF.q8 = 'member/family refused case management'
	--		      OR MMF.q2CloseReason = 'member/family refused case management'
	--			  OR MMF.qNonViableReason1 = 'no CM needs' 
	--		      OR MMF.q2ConsentNonViable = 'no CM needs' 
	--		      OR MMF.qNoReason = 'no CM needs'
	--		      OR MMF.q8 = 'no CM needs'
	--	         )
	--	     AND DATEDIFF(day,MMF.FormDate, GETDATE()) < 121
	--	   UNION  -- UTR in last 120 days (e) for specific program types
	--	  SELECT DISTINCT MVDID, 'UTR' AS Rsn 
	--	    FROM ABCBS_MemberManagement_Form MMF
	--	   WHERE MMF.CaseProgram IN ('case management', 'chronic condition management', 'maternity')
	--	     AND (MMF.qNonViableReason1 = 'unable to reach member' 
	--		      OR MMF.q2ConsentNonViable = 'unable to reach member' 
	--		      OR MMF.qNoReason = 'unable to reach member'
	--		      OR MMF.q8 = 'unable to reach member'
	--	         )
	--	     AND DATEDIFF(day,MMF.FormDate, GETDATE()) < 121
	--	   UNION  -- member expired
	--	  SELECT DISTINCT MVDID, 'Expired' AS Rsn 
	--	    FROM ABCBS_MemberManagement_Form MMF
	--	   WHERE (MMF.qNonViableReason1 = 'member expired' 
	--		      OR MMF.q2ConsentNonViable = 'member expired' 
	--		      OR MMF.qNoReason = 'member expired'
	--		      OR MMF.q8 = 'member expired'
	--		      OR MMF.q2CloseReason = 'member expired'
	--	         ) -- or valid date of death -- not captured on MMF
	--	   UNION  -- contact in last 120 days
	--	  SELECT DISTINCT MVDID , 'Contact' AS Rsn
	--	    FROM ARBCBS_Contact_Form CF
	--	   WHERE DATEDIFF(day,CF.q1ContactDate, GETDATE()) < 121
	--	     AND q4ContactType IN ('Member','Caregiver')
	--	     AND q7ContactSuccess = 'Yes'
	--	     AND q2program IN ('Case Management','Specialty Care','Maternity')
	--	),
	--	UniversalExclusion AS
	--	(
	--		SELECT fm.MVDID
	--		  FROM FinalMember fm
	--		  JOIN Final.dbo.LookupGRP_CareFlowRule ue ON fm.CompanyKey = ue.Company_Key
	--		 WHERE (ue.Bill_Hourly_Ind = 'Y' OR ue.Exclude_Careflow_Ind = 'Y') 
	--	)
		 -- member is active (a) has no case manager (b) no personal harm (i) high prediction for top 10%, hi ratio of Rx to Med
		 SELECT DISTINCT CCQ.MVDID
		   FROM ComputedCareQueue CCQ
	  LEFT JOIN ComputedMemberAlert CA on CA.MVDID = CCQ.MVDID
	  LEFT JOIN FinalMember FM on FM.MVDID = CCQ.MVDID
	  LEFT JOIN ComputedMemberTotalPaidClaimsRollling12 PR on PR.MVDID = CCQ.MVDID and MonthID = @MaxMI
		 --left join [VD-RPT02].[Datalogy].[ds].[tags_for_high_risk_members] CP on CP.PartyKey = FM.PartyKey /*Removed*/
	  LEFT JOIN [tags_for_high_risk_members] CP on CP.PartyKey = FM.PartyKey /*Added*/
		   JOIN ElixMemberRisk ex on ex.mvdid = fm.mvdid
		  WHERE CCQ.IsActive = 1 
		    AND ISNULL(FM.COBCD,'U') in ('S','N','U')
		    AND ISNULL(FM.CompanyKey,'0000') != '1338'
		    AND ISNULL(CCQ.CaseOwner,'--') = '--'
		    AND ISNULL(CA.PersonalHarm,0) = 0
		    AND ISNULL(CP.Is_Top10pct_predicted,0) = 1 -- in top 10% of predicted cost
		    AND (ISNULL([RX_PaidAmt_Prev360d],0) / (ISNULL(Med_PaidAmt_Prev360d,0) + ISNULL([RX_PaidAmt_Prev360d],0) + 1) < .75) -- less than 75% of cost coming from Rx
		    AND ISNULL(PR.[HighDollarClaim],0) = 0  -- include only if emergent high cost
		    AND ex.groupid=@Grp
		    AND FM.GrpInitvCd != 'GRD' -- exclude members associated to Grand Rounds
		    AND CCQ.RiskGroupID < 4
			AND NOT EXISTS (SELECT 1 FROM #ExcludedMVDID WHERE MVDID=CCQ.MVDID)

			--AND NOT EXISTS (SELECT 1 FROM StandardExclusion WHERE MVDID=CCQ.MVDID)
			--AND NOT EXISTS (SELECT 1 FROM UniversalExclusion WHERE MVDID = CCQ.MVDID)

END