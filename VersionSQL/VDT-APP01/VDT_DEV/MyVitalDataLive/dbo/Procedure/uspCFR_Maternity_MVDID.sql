/****** Object:  Procedure [dbo].[uspCFR_Maternity_MVDID]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[uspCFR_Maternity_MVDID] 
AS
/*
    CustID:  16
    RuleID:  204
 ProductID:  2
OwnerGroup:  156

Changes
WHO		WHEN		WHAT
Scott	20201106	Modifiy to use Merge
Mike	2020-12-02	Changed MemberManagement_Form to MMFHistory_Form to support join to HPAlertNote.
Mike	2020-12-05	Screen out members under 13 or over 50 per client
Scott   2021-04-21  Remove AND NOT EXIST for this rule in Careflow Queue - the merge takes care of that...
Scott	2021-05-25  Add Universal Exclustions for hourly and no benefit
Scott	2021-08-03	Add new exclusion code

exec uspCFR_Maternity_MVDID  --(1051/:10)((1051/:04)

exec uspCFR_Merge @MVDProcedureName = 'uspCFR_Maternity_MVDID', @CustID = 16, @RuleID = 204, @ProductID = 2, @OwnerGroup = 156

EXEC uspCFR_MapRuleExclusion @pRuleID = '204', @pAction = 'DISPLAY'

*/
BEGIN
	SET NOCOUNT ON;

	DECLARE @RuleID int = 204

	--DELETE from CareFlowTask where RuleId = @RuleID and StatusId =278  -- clear out any existing entries that have not been acted on

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

	;WITH Members AS
	(
		SELECT DISTINCT C.MVDID
		  FROM ComputedMemberMaternity C  -- determined to be pregnant
		  JOIN FinalEligibilityETL CC on CC.MVDID = C.MVDID -- there is basic eligibility
		  JOIN FinalMember FM on FM.MVDID = C.MVDID
		  JOIN VitalData_MaternityEligibleFull VDTE on VDTE.memberID = fm.MemberID -- there is eligiblity for maternity program
		 WHERE cc.MemberEffectiveDate <= GetDate() and IsNull(CC.MemberTerminationDate,'9999-12-31') >= GetDate()
		   AND VDTE.maternityElig='Yes'     -- has maternity coverage
		   AND ISNULL(IsPregnant,0) > 0               -- member is pregnant
		   AND ISNULL(IsMiscarriage,0) < 1
		   AND ISNULL(IsDelivered,0) < 1
		   AND IsLateTerm < 1
		   AND ISNULL(FM.COBCD,'U') in ('S','N','U')
		   AND ISNULL(FM.CompanyKey,'0000') != '1338'
		   AND DATEDIFF(yy, DateOfBirth, GETDATE()) BETWEEN 13 AND 50
		   AND FM.Gender = 'F'
		   AND FM.GrpInitvCd != 'GRD' -- exclude members associated to Grand Rounds
	), Exclusions AS
	(	--contact form
		select distinct AC.MVDID
		  from ARBCBS_Contact_Form AC
		  join HPAlertNote HAN on HAN.MVDID = AC.MVDID and HAN.LinkedFormID = AC.ID and HAN.LinkedFormType like '%CONTACT%'
		 where datediff(day,AC.FormDate,GetDate()) <= 120
		   and IsNull(HAN.IsDelete,0) = 0
		   and AC.q2program = 'Maternity'
		   and AC.q4ContactType in ('Member','Caregiver')
		 union -- Identify all the pregnant members that have coverage,  Contact form exclusion (a), Active Member Management Form exclusion (b)
		select distinct MMF.MVDID
		  from ABCBS_MMFHistory_Form MMF
		  join HPAlertNote HAN on HAN.MVDID = MMF.MVDID and HAN.LinkedFormID = MMF.ID
		 where HAN.LinkedFormType in ('ABCBS_MemberManagement','ABCBS_MMFHistory')
		   and IsNull(HAN.IsDelete,0) = 0
		   and MMF.CaseProgram='Maternity'
		   and MMF.SectionCompleted < 3
		 union  -- Any Member Management Form in last 45 days exclusion (c)***
		select distinct MMF.MVDID
		  from ABCBS_MMFHistory_Form MMF
		  join HPAlertNote HAN on HAN.MVDID = MMF.MVDID and HAN.LinkedFormID = MMF.ID
		 where datediff(DAY,MMF.FormDate,GetDate()) <= 120
		   and HAN.LinkedFormType in ('ABCBS_MemberManagement','ABCBS_MMFHistory')
		   and IsNull(HAN.IsDelete,0) = 0
		   and MMF.CaseProgram='Maternity'
		   and MMF.ReferralReason = 'Maternity - Mom'
         union -- Any Member Management Form in last 60 days exclusion, non-viable (d)***
		select distinct MMF.MVDID
		  from ABCBS_MMFHistory_Form MMF
	      join HPAlertNote HAN on HAN.MVDID = MMF.MVDID and HAN.LinkedFormID = MMF.ID
	     where datediff(DAY,MMF.FormDate,GetDate()) <= 120
	       and HAN.LinkedFormType in ('ABCBS_MemberManagement','ABCBS_MMFHistory')
	       and IsNull(HAN.IsDelete,0) = 0
	       and MMF.CaseProgram='Maternity'
	       and MMF.ReferralReason = 'Maternity - Mom'
	       and MMF.qViableReason = 'No'
	     union -- Any Member Management Form in last 60 days exclusion, UTR (e) ***
		select distinct MMF.MVDID
	      from ABCBS_MMFHistory_Form MMF
	      join HPAlertNote HAN on HAN.MVDID = MMF.MVDID and HAN.LinkedFormID = MMF.ID
	     where datediff(DAY,MMF.FormDate,GetDate()) <= 120
	       and HAN.LinkedFormType in ('ABCBS_MemberManagement','ABCBS_MMFHistory')
	       and IsNull(HAN.IsDelete,0) = 0
	       and MMF.CaseProgram='Maternity'
	       and MMF.ReferralReason = 'Maternity - Mom'
	       and MMF.q1ConsentRef = 'No'
	       and MMF.q9followmember = 'No'
		 union -- Any Member Management Form consent in last 60 days exclusion, no CM offered (f) ***
		select distinct MMF.MVDID
		  from ABCBS_MMFHistory_Form MMF
	      join HPAlertNote HAN on HAN.MVDID = MMF.MVDID and HAN.LinkedFormID = MMF.ID
	     where datediff(DAY,MMF.q2ConsentDate,GetDate()) <= 120
	       and HAN.LinkedFormType in ('ABCBS_MemberManagement','ABCBS_MMFHistory')
	       and IsNull(HAN.IsDelete,0) = 0
	       and MMF.CaseProgram='Maternity'
	       and MMF.ReferralReason = 'Maternity - Mom'
	       and MMF.q1ConsentRef = 'Yes'
	       and MMF.q1ConsentofferCM = 'No'
	       and MMF.q9followmember = 'No'
	     union -- Any Member Management Form consent in last 60 days exclusion, CM offered, no consent (g) ***
		select distinct MMF.MVDID
	      from ABCBS_MMFHistory_Form MMF
	      join HPAlertNote HAN on HAN.MVDID = MMF.MVDID and HAN.LinkedFormID = MMF.ID
	     where datediff(DAY,MMF.q2ConsentDate,GetDate()) <= 120
	       and HAN.LinkedFormType in ('ABCBS_MemberManagement','ABCBS_MMFHistory')
	       and IsNull(HAN.IsDelete,0) = 0
	       and MMF.CaseProgram='Maternity'
	       and MMF.ReferralReason = 'Maternity - Mom'
	       and MMF.q1ConsentRef = 'Yes'
	       and MMF.q1ConsentofferCM = 'Yes'
	       and MMF.q6Consentverbal = 'No'
	       and MMF.q9followmember = 'No'
	     union -- Any Member Management Form case closed in last 60 days exclusion (h) ***
	    select distinct MMF.MVDID
	      from ABCBS_MMFHistory_Form MMF
	      join HPAlertNote HAN on HAN.MVDID = MMF.MVDID and HAN.LinkedFormID = MMF.ID
	     where datediff(DAY,IsNull(MMF.q1CaseCloseDate,'9999-12-31'),GetDate()) <= 120
	       and HAN.LinkedFormType in ('ABCBS_MemberManagement','ABCBS_MMFHistory')
	       and IsNull(HAN.IsDelete,0) = 0
	       and MMF.CaseProgram='Maternity'
	       and MMF.ReferralReason = 'Maternity - Mom'
		)
			SELECT DISTINCT MVDID		--, 204, GetDate(), 'WORKFLOW', 2, 16, 278, 156, '99991231'  
			  FROM Members m
			 WHERE NOT EXISTS (SELECT 1 FROM Exclusions WHERE MVDID = m.MVDID)
			   AND NOT EXISTS (SELECT 1 FROM #ExcludedMVDID WHERE MVDID = m.MVDID)

END