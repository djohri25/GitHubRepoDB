/****** Object:  Procedure [dbo].[uspCFR_PTB_MVDID]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[uspCFR_PTB_MVDID_20210803] 
AS
/*
    CustID:  16
    RuleID:  216
 ProductID:  2
OwnerGroup:  155

Changes
WHO		WHEN		WHAT
Sunil   08/28/2020	remove cross server reference.
Scott	2020-10-29	Created by refactor of original to call uspCFR_Merge
Scott	2020-11-21	Updated with changes to original
Scott	2020-11-25  Use local table tags_for_high_risk_PTB_members

EXEC uspCFR_PTB_MVDID  237 /:06

EXEC uspCFR_Merge @MVDProcedureName = 'uspCFR_PTB_MVDID', @CustID = 16, @RuleID = 216, @ProductID = 2, @OwnerGroup= 155

*/
BEGIN
	SET NOCOUNT ON;

	DECLARE @RuleId int = 216
	DECLARE @OwnerGroup int = 155


	;WITH StandardExclusion AS
		(-- active member management form (c) for specific program types
			SELECT MVDID, 'Active' AS Rsn 
			  FROM ABCBS_MemberManagement_Form MMF
			 WHERE MMF.CaseProgram in ('case management', 'chronic condition management', 'maternity')
			   AND ISNULL(MMF.SectionCompleted,9) < 3
			 UNION  -- denial in last 120 days (d) for specific program types
			SELECT DISTINCT MVDID, 'Refused' AS Rsn 
			  FROM ABCBS_MemberManagement_Form MMF
			 WHERE MMF.CaseProgram in ('case management', 'chronic condition management', 'maternity')
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
			  and DateDiff(day,MMF.FormDate, GetDate()) < 121
			UNION -- UTR in last 120 days (e) for specific program types
		   select distinct MVDID, 'UTR' as Rsn 
			 from ABCBS_MemberManagement_Form MMF
			where MMF.CaseProgram in ('case management', 'chronic condition management', 'maternity')
			  and (MMF.qNonViableReason1 = 'unable to reach member' 
				   or MMF.q2ConsentNonViable = 'unable to reach member' 
				   or MMF.qNoReason = 'unable to reach member'
				   or MMF.q8 = 'unable to reach member'
			      )
			  and DateDiff(day,MMF.FormDate, GetDate()) < 121
			UNION  -- member expired
		   SELECT DISTINCT MVDID, 'Expired' AS Rsn 
			 FROM ABCBS_MemberManagement_Form MMF
			WHERE (MMF.qNonViableReason1 = 'member expired' 
				   OR MMF.q2ConsentNonViable = 'member expired' 
				   OR MMF.qNoReason = 'member expired'
				   OR MMF.q8 = 'member expired'
				   OR MMF.q2CloseReason = 'member expired'
			      ) -- or valid date of death -- not captured on MMF
			UNION -- contact in last 120 days
		   SELECT DISTINCT MVDID , 'Contact' AS Rsn
			 FROM ARBCBS_Contact_Form CF
			WHERE DateDiff(day,CF.q1ContactDate, GetDate()) < 121
			  AND q4ContactType in ('Member','Caregiver')
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
		      JOIN ComputedMemberMaternity C on C.MVDID = CCQ.MVDID  -- determined to be pregnant
		      JOIN FinalEligibility CC on CC.MVDID = C.MVDID -- there is basic eligibility
		      JOIN FinalMember FM on FM.MVDID = C.MVDID 
			  JOIN VitalData_MaternityEligibleFull VDTE on VDTE.memberID = FM.MemberID -- there is a maternity benefit
			  JOIN tags_for_high_risk_PTB_members CP on CP.PartyKey = FM.PartyKey
			 WHERE CCQ.IsActive = 1 
			   AND ISNULL(CCQ.CaseOwner,'--') = '--'
			   AND CP.[Model_Used] = 'pbt_wk20'
			   AND ISNULL(FM.CompanyKey,'0000') != '1338'
			   AND ISNULL(CA.PersonalHarm,0) = 0
			   AND FM.GrpInitvCd != 'GRD' -- not associated to Grand Rounds
			   AND ISNULL(FM.COBCD,'U') in ('S','N','U')
			   AND FM.Gender = 'F'
			   AND NOT EXISTS (SELECT 1 FROM StandardExclusion WHERE MVDID = CCQ.MVDID)
			   AND NOT EXISTS (SELECT 1 FROM UniversalExclusion WHERE MVDID = CCQ.MVDID)
		       AND cc.MemberEffectiveDate <= GetDate() and IsNull(CC.MemberTerminationDate,'9999-12-31') >= GetDate()
		       AND VDTE.maternityElig='Yes'     -- has maternity coverage
		       AND ISNULL(IsPregnant,0) > 0               -- member is pregnant
		       AND ISNULL(IsMiscarriage,0) < 1
		       AND ISNULL(IsDelivered,0) < 1
		       AND IsLateTerm < 1

END