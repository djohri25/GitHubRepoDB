/****** Object:  Procedure [dbo].[uspMaternityConversionMEF_OutcomesTask]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE
uspMaternityConversionMEF_OutcomesTask
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
		'M1258407800',
		'09708539W00',
		'K0042781201',
		'K0043358501',
		'Y0022520201',
		'M6135876801',
		'T0063985500',
		'T0070223101',
		'T0063135200',
		'T0063509600',
		'09700849W01',
		'11151362W00',
		'12408804W00',
		'13854500W00',
		'M6141807701',
		'T0081986000',
		'13587515W01',
		'Y0015637601',
		'Y0036463201',
		'Y0081806201',
		'Y0084703201',
		'Y0085631701',
		'Y0086164202',
		'T0064594600',
		'M6144685300',
		'Y0086726801',
		'05160586W00',
		'12834201W01',
		'15581873W01',
		'12873357W02',
		'60035127801',
		'T0090423100',
		'50000289701',
		'K0051425301',
		'T0092737900',
		'13224358W00',
		'14500517W00',
		'13484897W01',
		'T0092425601',
		'K0051666701',
		'M6155136500',
		'T0093798000',
		'50002698502',
		'60041771701',
		'T0089738900',
		'50004490801',
		'M6158229801',
		'60044350301',
		'17723068W00',
		'10728663W00',
		'Y0090988701',
		'Y0040718301',
		'60044666902',
		'18007976W01',
		'M6162170700',
		'18439946W01',
		'T0097131001',
		'T0101158100'
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

		IF ( ( dbo.MVDIsNull( @v_IndTaskOutComes ) = 0 OR dbo.MVDIsNull( @v_DateTaskOutcomes ) = 0 ) AND @v_IndTaskOutComes NOT LIKE 'N/A%' )
		BEGIN
			IF ( @v_DateTaskOutcomes NOT LIKE '20%' )
			BEGIN
				SET @v_DateTaskOutcomes = getUTCDate();
			END;

			SET @v_narrative =
				CONCAT( 'Member is due for a Maternity Outcomes Call.  The Member''s due date is:  ', CONVERT( varchar, @v_PregnancyDueDate, 107 ) );

-- Indicate that Outcome Task was created
			EXEC Set_UserTask
				@Title = 'Maternity Member Due for Outcomes Call',
				@Narrative = @v_narrative,
				@MVDID = @v_mvdid,
				@CustomerId = 16,
				@ProductId = 2,
				@Author = 'Transitioned from CCA',
				@Owner = @v_owner,
				@UpdatedBy = 'Transitioned from CCA',
				@CreatedDate = @v_DateTaskOutcomes,
				@UpdatedDate = @v_DateTaskOutcomes,
				@TypeId = 287,
				@CaseId = @v_case_id,
				@TaskType = 'General',
				@TaskPriority = 'Medium',
				@TaskStatus = 'Completed',
				@CompletedDate = @v_DateTaskOutComes,
				@NewTaskId = @v_task_id;

			UPDATE
			Task
			SET
			AutomationProcId = 1
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