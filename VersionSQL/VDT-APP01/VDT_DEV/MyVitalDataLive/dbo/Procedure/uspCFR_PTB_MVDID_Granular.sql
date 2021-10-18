/****** Object:  Procedure [dbo].[uspCFR_PTB_MVDID_Granular]    Committed by VersionSQL https://www.versionsql.com ******/

create PROCEDURE [dbo].[uspCFR_PTB_MVDID_Granular] 
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

EXEC uspCFR_PTB_MVDID  --(52/:26)(52/:18)

EXEC uspCFR_Merge @MVDProcedureName = 'uspCFR_PTB_MVDID', @CustID = 16, @RuleID = 216, @ProductID = 2, @OwnerGroup= 155

EXEC uspCFR_MapRuleExclusion @pRuleID = '216', @pAction = 'DISPLAY'

*/
BEGIN
	SET NOCOUNT ON;

	DECLARE @RuleId int = 216
	DECLARE @OwnerGroup int = 155

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
			   AND FM.Gender = 'F'
		       AND cc.MemberEffectiveDate <= GetDate() and IsNull(CC.MemberTerminationDate,'9999-12-31') >= GetDate()
		       AND VDTE.maternityElig='Yes'     -- has maternity coverage
		       AND ISNULL(IsPregnant,0) > 0               -- member is pregnant
		       AND ISNULL(IsMiscarriage,0) < 1
		       AND ISNULL(IsDelivered,0) < 1
		       AND IsLateTerm < 1
			   AND FM.GrpInitvCd != 'GRD' -- not associated to Grand Rounds
			   AND ISNULL(FM.COBCD,'U') in ('S','N','U')
			   AND NOT EXISTS (SELECT 1 FROM #ExcludedMVDID WHERE MVDID = CCQ.MVDID)

END