/****** Object:  Procedure [dbo].[uspCFR_Ortho_MVDID_21010802]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[uspCFR_Ortho_MVDID_21010802]
AS
/*
    CustID:  16
    RuleID:  215
 ProductID:  2
OwnerGroup:  168

Changes
WHO		WHEN		WHAT
Scott	2020-10-29	Created by refactor of original to call uspCFR_Merge
Scott	2020-11-21	Updated with changes to original
Scott	2021-04-19	Refactor to CTE format and add Universal Exclusion of No-Benefit and Hourly workers.

EXEC uspCFR_Ortho_MVDID

EXEC uspCFR_Merge @MVDProcedureName = 'uspCFR_Ortho_MVDID', @CustID = 16, @RuleID = 215, @ProductID = 2, @OwnerGroup= 168

*/
BEGIN
	SET NOCOUNT ON;
	DECLARE @RuleID int = 215

	;WITH StandardExclusion AS
		(	-- active member management form (c) for specific program types
			SELECT MVDID, 'Active' AS Rsn 
			  FROM ABCBS_MemberManagement_Form MMF
			 WHERE MMF.CaseProgram in ('case management', 'chronic condition management', 'maternity')
			   AND ISNULL(MMF.SectionCompleted,9) < 3
			 UNION -- denial in last 120 days (d) for specific program types
			SELECT DISTINCT MVDID, 'Refused' AS Rsn 
			  FROM ABCBS_MemberManagement_Form MMF
			 WHERE MMF.CaseProgram IN ('case management', 'chronic condition management', 'maternity')
			   AND (MMF.qNonViableReason1 = 'member/family refused case management' 
				    OR MMF.q2ConsentNonViable = 'member/family refused case management' 
				    OR MMF.qNoReason = 'member/family refused case management'
				    OR MMF.q8 = 'member/family refused case management'
				    OR MMF.q2CloseReason = 'member/family refused case management'
				    OR MMF.qNonViableReason1 = 'no CM needs' 
				    OR MMF.q2ConsentNonViable = 'no CM needs' 
				    OR MMF.qNoReason = 'no CM needs'
				    OR MMF.q8 = 'no CM needs'
			       )
			   AND DATEDIFF(day,MMF.FormDate, GETDATE()) < 121
			 UNION  -- UTR in last 120 days (e) for specific program types
			SELECT DISTINCT MVDID, 'UTR' AS Rsn 
			  FROM ABCBS_MemberManagement_Form MMF
			 WHERE MMF.CaseProgram IN ('case management', 'chronic condition management', 'maternity')
			   AND (MMF.qNonViableReason1 = 'unable to reach member' 
				    OR MMF.q2ConsentNonViable = 'unable to reach member' 
				    OR MMF.qNoReason = 'unable to reach member'
				    OR MMF.q8 = 'unable to reach member'
			       )
			   AND DATEDIFF(day,MMF.FormDate, GETDATE()) < 121
			 UNION  -- member expired or valid date of death -- not captured on MMF
			SELECT DISTINCT MVDID, 'Expired' AS Rsn 
			  FROM ABCBS_MemberManagement_Form MMF
			 WHERE (MMF.qNonViableReason1 = 'member expired' 
				    OR MMF.q2ConsentNonViable = 'member expired' 
				    OR MMF.qNoReason = 'member expired'
					OR MMF.q8 = 'member expired'
					OR MMF.q2CloseReason = 'member expired'
			       ) 
			 UNION -- contact in last 120 days
			SELECT DISTINCT MVDID , 'Contact' AS Rsn
			  FROM ARBCBS_Contact_Form CF
			 WHERE DATEDIFF(day,CF.q1ContactDate, GETDATE()) < 121
			   AND q4ContactType IN ('Member','Caregiver')
			   AND q7ContactSuccess = 'Yes'
			   AND q2program IN ('Case Management','Specialty Care','Maternity')
		),
		UniversalExclusion AS
		(
			SELECT fm.MVDID
			  FROM FinalMember fm
			  JOIN Final.dbo.LookupGRP_CareFlowRule ue ON fm.CompanyKey = ue.Company_Key
			 WHERE (ue.Bill_Hourly_Ind = 'Y' OR ue.Exclude_Careflow_Ind = 'Y') 
		)
			SELECT DISTINCT CCQ.MVDID
			  FROM ComputedCareQueue CCQ
		 LEFT JOIN ComputedMemberAlert CA on CA.MVDID = CCQ.MVDID
		 LEFT JOIN FinalMember FM on FM.MVDID = CCQ.MVDID
			--left join [VD-RPT02].[Datalogy].[ds].[tags_for_high_risk_members] CP on CP.PartyKey = FM.PartyKey /*Removed*/
		 LEFT JOIN [tags_for_high_risk_members] CP on CP.PartyKey = FM.PartyKey /*Added*/
			 WHERE CCQ.IsActive = 1 
			   AND ISNULL(FM.COBCD,'U') in ('S','N','U')
			   AND ISNULL(FM.CompanyKey,'0000') != '1338'
			   AND ISNULL(CCQ.CaseOwner,'--') = '--'
			   AND ISNULL(CA.PersonalHarm,0) = 0
			   AND ISNULL(CP.Is_Ortho3_predicted,0) = 1
			   AND ISNULL(CP.Has_Obesity_History,0) = 1
			   AND FM.GrpInitvCd != 'GRD' -- exclude members associated to Grand Rounds
			   AND CCQ.RiskGroupID >= 5			--there are few in this risk group...
		       AND NOT EXISTS (SELECT 1 FROM StandardExclusion WHERE MVDID = CCQ.MVDID)
			   AND NOT EXISTS (SELECT 1 FROM UniversalExclusion WHERE MVDID = CCQ.MVDID)
	
END