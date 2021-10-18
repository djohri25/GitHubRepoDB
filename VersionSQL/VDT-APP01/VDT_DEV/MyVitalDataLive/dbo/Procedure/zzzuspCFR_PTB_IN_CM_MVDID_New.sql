/****** Object:  Procedure [dbo].[zzzuspCFR_PTB_IN_CM_MVDID_New]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[uspCFR_PTB_IN_CM_MVDID_New] 
AS
/*
    CustID:  16
    RuleID:  222
 ProductID:  2
OwnerGroup:  155

Changes
WHO		WHEN		WHAT
Scott	2020-10-2	Created by refactor of original to call uspCFR_Merge
Scott	2020-11-21	Applied changes made to original
Scott	2020-11-25	Use local table tags_for_high_risk_PTB_members CP
Scott	2021-04-20	Reformat to CTE and add Universal Exclusion for no-benefit and houry.
Mike	2021-07-28	Added joins to make sure of pregnancy state and eligibility (TFS 5591)

EXEC uspCFR_PTB_IN_CM_MVDID (179/19:33)
EXEC uspCFR_PTB_IN_CM_MVDID_New  

EXEC uspCFR_Merge @MVDProcedureName = 'uspCFR_PTB_IN_CM_MVDID', @CustID = 16, @RuleID = 222, @ProductID = 2, @OwnerGroup= 155

*/
BEGIN
	SET NOCOUNT ON;

	DECLARE @RuleId int = 222
	DECLARE @OwnerGroup int = 155 --168 changed per email 11/16/2020

		;WITH TaskExclusion AS
			(
			SELECT DISTINCT MVDID, 'Task' AS Rsn
			  FROM Task
			 WHERE title LIKE 'ptb%high risk%'
			   AND DATEDIFF(day,CreatedDate, GETDATE()) < 60
			 UNION -- member expired
			SELECT DISTINCT MVDID, 'Expired' as Rsn 
			  FROM ABCBS_MemberManagement_Form MMF
			 WHERE (MMF.qNonViableReason1 = 'member expired' 
				    OR MMF.q2ConsentNonViable = 'member expired' 
				    OR MMF.qNoReason = 'member expired'
				    OR MMF.q8 = 'member expired'
				    OR MMF.q2CloseReason = 'member expired'
				   )
			)
			,
			UniversalExclusion AS
			(
				SELECT DISTINCT fm.MVDID
					FROM FinalMember fm
					JOIN Final.dbo.LookupGRP_CareFlowRule ue ON fm.CompanyKey = ue.Company_Key
					WHERE (ue.Bill_Hourly_Ind = 'Y' OR ue.Exclude_Careflow_Ind = 'Y') 
			)
			    SELECT DISTINCT CCQ.MVDID
				  FROM ComputedCareQueue CCQ
                  JOIN FinalMember FM on FM.MVDID = CCQ.MVDID
				   AND ISNULL(FM.COBCD,'U') in ('S','N','U')
				   AND ISNULL(FM.CompanyKey,'0000') != '1338'
				   AND FM.Gender = 'F'
				   AND FM.GrpInitvCd != 'GRD' -- not associated to Grand Rounds
				  JOIN tags_for_high_risk_PTB_members CP on CP.PartyKey = FM.PartyKey
				   AND CP.[Model_Used] = 'pbt_wk20'
			 LEFT JOIN ComputedMemberAlert CA on CA.MVDID = CCQ.MVDID
				   AND ISNULL(CA.PersonalHarm,0) = 0 
		          JOIN ComputedMemberMaternity C on C.MVDID = CCQ.MVDID  -- determined to be pregnant
		          JOIN FinalEligibility CC on CC.MVDID = C.MVDID -- there is basic eligibility
			      JOIN VitalData_MaternityEligibleFull VDTE on VDTE.memberID = FM.MemberID -- there is a maternity benefit
				 WHERE CCQ.IsActive = 1 
				   AND (ISNULL(CCQ.CaseOwner,'--') != '--' AND LEN(RTRIM(ISNULL(CCQ.CaseOwner,''))) > 0)
				   AND NOT EXISTS (SELECT 1 FROM TaskExclusion WHERE MVDID = CCQ.MVDID)
				   AND NOT EXISTS (SELECT 1 FROM UniversalExclusion WHERE MVDID = CCQ.MVDID)
		           AND cc.MemberEffectiveDate <= GetDate() and IsNull(CC.MemberTerminationDate,'9999-12-31') >= GetDate()
		           AND VDTE.maternityElig='Yes'     -- has maternity coverage
		           AND ISNULL(IsPregnant,0) > 0     -- member is pregnant
		           AND ISNULL(IsMiscarriage,0) < 1
		           AND ISNULL(IsDelivered,0) < 1
		           AND IsLateTerm < 1

END