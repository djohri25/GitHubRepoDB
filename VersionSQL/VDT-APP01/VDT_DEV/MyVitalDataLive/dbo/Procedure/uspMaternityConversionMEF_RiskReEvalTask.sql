/****** Object:  Procedure [dbo].[uspMaternityConversionMEF_RiskReEvalTask]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE
uspMaternityConversionMEF_RiskReEvalTask
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @v_CCAID nvarchar(max);
	DECLARE @v_ID nvarchar(max);
	DECLARE @v_ReferralID nvarchar(max);
	DECLARE @v_member_id nvarchar(max);
	DECLARE @v_MaternityProgram nvarchar(max);
	DECLARE @v_cm_org_region nvarchar(max);
	DECLARE @v_EnrollStatus nvarchar(max);
	DECLARE @v_HRACompletedDate nvarchar(max);
	DECLARE @v_HRAScore nvarchar(max);
	DECLARE @v_CCACaseId nvarchar(max);
	DECLARE @v_CaseId nvarchar(max);
	DECLARE @v_ConvertedCaseFromCCA nvarchar(max);
	DECLARE @v_EnrollDate nvarchar(max);
	DECLARE @v_PregnancyDueDate nvarchar(max);
	DECLARE @v_GestationAtEnrollment nvarchar(max);
	DECLARE @v_GestationCurrent nvarchar(max);
	DECLARE @v_emailAddress nvarchar(max);
	DECLARE @v_IndEmailPregnancyTips nvarchar(max);
	DECLARE @v_DateEmailPregnancyTips nvarchar(max);
	DECLARE @v_IndPktPrenatal nvarchar(max);
	DECLARE @v_DatePktPrenatal nvarchar(max);
	DECLARE @v_IndPktPrenatal_DentalXtra nvarchar(max);
	DECLARE @v_DatePktPrenatal_DentalXtra nvarchar(max);
	DECLARE @v_IndPktInfant nvarchar(max);
	DECLARE @v_DatePktInfant nvarchar(max);
	DECLARE @v_IndPktInfant_Smoking nvarchar(max);
	DECLARE @v_DatePktInfant_Smoking nvarchar(max);
	DECLARE @v_IndTaskLowRisk nvarchar(max);
	DECLARE @v_DateTaskLowRisk nvarchar(max);
	DECLARE @v_IndTaskHighRisk nvarchar(max);
	DECLARE @v_DateTaskHighRisk nvarchar(max);
	DECLARE @v_IndTaskHighRisk2 nvarchar(max);
	DECLARE @v_DateTaskHighRisk2 nvarchar(max);
	DECLARE @v_IndTaskOutComes nvarchar(max);
	DECLARE @v_DateTaskOutComes nvarchar(max);
	DECLARE @v_IndMiscarriage nvarchar(max);
	DECLARE @v_DateMiscarriage nvarchar(max);
	DECLARE @v_IndLtrExchangeWelcome nvarchar(max);
	DECLARE @v_DateLtrExchangeWelcome nvarchar(max);
	DECLARE @v_IndLtrFEPRewardBox nvarchar(max);
	DECLARE @v_DateLtrFEPRewardBox nvarchar(max);
	DECLARE @v_IndRiskLevel nvarchar(max);
	DECLARE @v_DateRiskLevel nvarchar(max);
	DECLARE @v_Date28WeeksGestation nvarchar(max);
	DECLARE @v_Date34WeeksGestation nvarchar(max);
	DECLARE @v_DateCCACaseCreated nvarchar(max);
	DECLARE @v_DateCaseCreated nvarchar(max);
	DECLARE @v_DateCaseClosed nvarchar(max);
	DECLARE @v_ClosedReason nvarchar(max);
	DECLARE @v_Auditable nvarchar(max);
	DECLARE @v_OnLineEnrollment nvarchar(max);

	DECLARE @v_now datetime = getDate();
	DECLARE @v_mvdid nvarchar(255);
	DECLARE @v_lob nvarchar(50);
	DECLARE @v_case_id nvarchar(255)
	DECLARE @v_age int;
	DECLARE @v_mmf_id bigint;
	DECLARE @v_owner nvarchar(255);
	DECLARE @v_form_id bigint;
	DECLARE @v_narrative nvarchar(max);
	DECLARE @v_task_id bigint;

	DECLARE member_cursor
	CURSOR FOR
	SELECT
	mef.CCAID,
	mef.ID,
	mef.ReferralID,
	mef.member_id,
	mef.MaternityProgram,
	mef.cm_org_region,
	mef.EnrollStatus,
	mef.HRACompletedDate,
	mef.HRAScore,
	mef.CCACaseId,
	mef.CaseId,
	mef.ConvertedCaseFromCCA,
	mef.EnrollDate,
	mef.PregnancyDueDate,
	mef.GestationAtEnrollment,
	mef.GestationCurrent,
	mef.emailAddress,
	mef.IndEmailPregnancyTips,
	mef.DateEmailPregnancyTips,
	mef.IndPktPrenatal,
	mef.DatePktPrenatal,
	mef.IndPktPrenatal_DentalXtra,
	mef.DatePktPrenatal_DentalXtra,
	mef.IndPktInfant,
	mef.DatePktInfant,
	mef.IndPktInfant_Smoking,
	mef.DatePktInfant_Smoking,
	mef.IndTaskLowRisk,
	mef.DateTaskLowRisk,
	mef.IndTaskHighRisk,
	mef.DateTaskHighRisk,
	mef.IndTaskHighRisk2,
	mef.DateTaskHighRisk2,
	mef.IndTaskOutComes,
	mef.DateTaskOutComes,
	mef.IndMiscarriage,
	mef.DateMiscarriage,
	mef.IndLtrExchangeWelcome,
	mef.DateLtrExchangeWelcome,
	mef.IndLtrFEPRewardBox,
	mef.DateLtrFEPRewardBox,
	mef.IndRiskLevel,
	mef.DateRiskLevel,
	mef.Date28WeeksGestation,
	mef.Date34WeeksGestation,
	mef.DateCCACaseCreated,
	mef.DateCaseCreated,
	mef.DateCaseClosed,
	mef.ClosedReason,
	mef.Auditable,
	mef.OnLineEnrollment
	FROM
	MyVitalDataLive.dbo.VitalData_MaternityEnrolledMembers_20191216 mef
	INNER JOIN FinalMemberETL fme
	ON fme.MemberID = mef.member_id
	INNER JOIN ComputedCareQueue ccq
	ON ccq.MVDID = fme.MVDID
	AND ccq.LOB = fme.LOB
	AND ISNULL( ccq.IsActive, 0 ) = 1
	WHERE
	mef.member_id IN
	(
		'Y0043469602',
		'Y0046809601',
		'12791729W01',
		'13574487W01',
		'M6139062100',
		'K0047265902',
		'14810635W00',
		'M6147006900',
		'16299118W00',
		'17817479W00',
		'Y0022753101'
	);

	OPEN member_cursor;
-- Get the first record
	FETCH NEXT FROM member_cursor INTO
		@v_CCAID,
		@v_ID,
		@v_ReferralID,
		@v_member_id,
		@v_MaternityProgram,
		@v_cm_org_region,
		@v_EnrollStatus,
		@v_HRACompletedDate,
		@v_HRAScore,
		@v_CCACaseId,
		@v_CaseId,
		@v_ConvertedCaseFromCCA,
		@v_EnrollDate,
		@v_PregnancyDueDate,
		@v_GestationAtEnrollment,
		@v_GestationCurrent,
		@v_emailAddress,
		@v_IndEmailPregnancyTips,
		@v_DateEmailPregnancyTips,
		@v_IndPktPrenatal,
		@v_DatePktPrenatal,
		@v_IndPktPrenatal_DentalXtra,
		@v_DatePktPrenatal_DentalXtra,
		@v_IndPktInfant,
		@v_DatePktInfant,
		@v_IndPktInfant_Smoking,
		@v_DatePktInfant_Smoking,
		@v_IndTaskLowRisk,
		@v_DateTaskLowRisk,
		@v_IndTaskHighRisk,
		@v_DateTaskHighRisk,
		@v_IndTaskHighRisk2,
		@v_DateTaskHighRisk2,
		@v_IndTaskOutComes,
		@v_DateTaskOutComes,
		@v_IndMiscarriage,
		@v_DateMiscarriage,
		@v_IndLtrExchangeWelcome,
		@v_DateLtrExchangeWelcome,
		@v_IndLtrFEPRewardBox,
		@v_DateLtrFEPRewardBox,
		@v_IndRiskLevel,
		@v_DateRiskLevel,
		@v_Date28WeeksGestation,
		@v_Date34WeeksGestation,
		@v_DateCCACaseCreated,
		@v_DateCaseCreated,
		@v_DateCaseClosed,
		@v_ClosedReason,
		@v_Auditable,
		@v_OnLineEnrollment;

-- Iterate through the list
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SELECT
		@v_mvdid = fme.MVDID,
		@v_lob = fme.LOB,
		@v_age = DATEDIFF( YEAR, fme.DateOfBirth, @v_now )
		FROM
		FinalMemberETL fme
		WHERE
		fme.MemberId = @v_member_id;

		SELECT DISTINCT
		@v_mmf_id = mmf.ID,
		@v_case_id = mmf.CaseID,
		@v_owner = mmf.q1CaseOwner
		FROM
		ABCBS_MemberManagement_Form mmf
		WHERE
		mmf.MVDID = @v_mvdid
		AND mmf.FormAuthor = 'Transitioned from CCA';

		IF ( ( dbo.MVDIsNull( @v_IndTaskHighRisk2 ) = 0 OR dbo.MVDIsNull( @v_DateTaskHighRisk2 ) = 0 ) AND @v_IndTaskHighRisk2 NOT LIKE 'N/A%' )
		BEGIN
			IF ( @v_IndTaskHighRisk2 LIKE '20%' AND dbo.MVDIsNull( @v_DateTaskHighRisk2 ) = 1 )
			BEGIN
				SET @v_DateTaskHighRisk2 = @v_IndTaskHighRisk2;
			END;
			IF ( @v_DateTaskHighRisk2 NOT LIKE '20%' )
			BEGIN
				SET @v_DateTaskHighRisk2 = getUTCDate();
			END;

-- Indicate that High Risk Re Eval Task was created
			EXEC Set_UserTask
				@Title = 'Maternity Member Send Risk Re-Evaluation Letter Task',
				@Narrative = 'Member has been identified as needing a Risk Re-Evaluation Letter sent.',
				@MVDID = @v_mvdid,
				@CustomerId = 16,
				@ProductId = 2,
				@Author = 'Transitioned from CCA',
				@Owner = @v_owner,
				@UpdatedBy = 'Transitioned from CCA',
				@CreatedDate = @v_DateTaskHighRisk2,
				@UpdatedDate = @v_DateTaskHighRisk2,
				@TypeId = 287,
				@CaseId = @v_case_id,
				@TaskType = 'General',
				@TaskPriority = 'Medium',
				@TaskStatus = 'Completed',
				@CompletedDate = @v_DateTaskHighRisk2,
				@NewTaskId = @v_task_id;

			UPDATE
			Task
			SET
			AutomationProcId = 2
			WHERE
			ID = @v_task_id;
		END;

-- Get the next record
		FETCH NEXT FROM member_cursor INTO
			@v_CCAID,
			@v_ID,
			@v_ReferralID,
			@v_member_id,
			@v_MaternityProgram,
			@v_cm_org_region,
			@v_EnrollStatus,
			@v_HRACompletedDate,
			@v_HRAScore,
			@v_CCACaseId,
			@v_CaseId,
			@v_ConvertedCaseFromCCA,
			@v_EnrollDate,
			@v_PregnancyDueDate,
			@v_GestationAtEnrollment,
			@v_GestationCurrent,
			@v_emailAddress,
			@v_IndEmailPregnancyTips,
			@v_DateEmailPregnancyTips,
			@v_IndPktPrenatal,
			@v_DatePktPrenatal,
			@v_IndPktPrenatal_DentalXtra,
			@v_DatePktPrenatal_DentalXtra,
			@v_IndPktInfant,
			@v_DatePktInfant,
			@v_IndPktInfant_Smoking,
			@v_DatePktInfant_Smoking,
			@v_IndTaskLowRisk,
			@v_DateTaskLowRisk,
			@v_IndTaskHighRisk,
			@v_DateTaskHighRisk,
			@v_IndTaskHighRisk2,
			@v_DateTaskHighRisk2,
			@v_IndTaskOutComes,
			@v_DateTaskOutComes,
			@v_IndMiscarriage,
			@v_DateMiscarriage,
			@v_IndLtrExchangeWelcome,
			@v_DateLtrExchangeWelcome,
			@v_IndLtrFEPRewardBox,
			@v_DateLtrFEPRewardBox,
			@v_IndRiskLevel,
			@v_DateRiskLevel,
			@v_Date28WeeksGestation,
			@v_Date34WeeksGestation,
			@v_DateCCACaseCreated,
			@v_DateCaseCreated,
			@v_DateCaseClosed,
			@v_ClosedReason,
			@v_Auditable,
			@v_OnLineEnrollment;

	END;

	CLOSE member_cursor;
	DEALLOCATE member_cursor;

END;