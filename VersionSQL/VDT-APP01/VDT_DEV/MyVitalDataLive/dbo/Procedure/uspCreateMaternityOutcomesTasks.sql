/****** Object:  Procedure [dbo].[uspCreateMaternityOutcomesTasks]    Committed by VersionSQL https://www.versionsql.com ******/

/*
-- 1/12/2021		SunilNokku		Add Readuncommitted hint for MMF
-- 1/13/2021		Sunil Nokku		Remove MVDIsNull Function
-- 2021-08-27		Ed Zanelli		Added WHERE clause to insure that due date is after MMF date
*/
CREATE PROCEDURE
[dbo].[uspCreateMaternityOutcomesTasks]
(
	@p_CustomerId int,
	@p_ProductId int
)
AS
BEGIN
	DECLARE @v_procedure_name nvarchar(255) = 'uspCreateMaternityOutcomesTasks';
	DECLARE @v_quick_action_id bigint;
	DECLARE @v_gestation_threshold_weeks int = 36;
	DECLARE @v_gestation_threshold_days int = @v_gestation_threshold_weeks * 7;

	DECLARE @v_default_queue nvarchar(255) = 'Maternity Support';
	DECLARE @v_maternity_due_date_vartext nvarchar(255) = '[maternity due date]';
	DECLARE @v_task_title nvarchar(255) = 'Maternity Member Due for Outcomes Call';
	DECLARE @v_task_narrative nvarchar(255);
	DECLARE @v_task_narrative_template nvarchar(255) =
		CONCAT( 'Member is due for a Maternity Outcomes Call.  The Member''s due date is:  ', @v_maternity_due_date_vartext, '.' );
	DECLARE @v_task_type nvarchar(255) = 'General';
	DECLARE @v_task_priority nvarchar(255) = 'Medium';
	DECLARE @v_task_status nvarchar(255) = 'New';
	DECLARE @v_task_due_date datetime;
	DECLARE @v_task_due_date_num_days int = 14;
	DECLARE @v_task_reminder_date datetime;
	DECLARE @v_task_reminder_date_num_days int = -1;

	DECLARE @v_mvd_id varchar(20);
	DECLARE @v_case_owner varchar(max);
	DECLARE @v_mmf_id bigint;
	DECLARE @v_mmf_form_date datetime;
	DECLARE @v_case_id varchar(100);
	DECLARE @v_mef_id bigint;
	DECLARE @v_mef_form_date datetime;
	DECLARE @v_due_date datetime;
	DECLARE @v_gestation bigint;

	DECLARE @v_task_id bigint;

-- Get the quick action ID
	EXEC Get_QuickActionID
		@p_ActionName = @v_procedure_name,
		@p_ID = @v_quick_action_id OUTPUT,
		@p_CustomerId = @p_CustomerId,
		@p_ProductId = @p_ProductId;

-- Get the candidate list of tasks
	DECLARE task_cursor
	CURSOR FOR
	SELECT
	*
	FROM
	(
		SELECT
		mmf.MVDID,
		CASE
		WHEN dbo.MVDIsNull( mmf.q1CaseOwner ) = 1 THEN @v_default_queue
		ELSE mmf.q1CaseOwner
		END CaseOwner,
		mmf.ID MMFID,
		mmf.FormDate MMFFormDate,
		mmf.CaseID,
		mef.ID MEFID,
		mef.FormDate MEFFormDate,
		CASE
		WHEN mef.q2BabyDue = '1900-01-01' THEN NULL
		ELSE mef.q2BabyDue
		END DueDate,
		dbo.Get_NumberOfDaysFromWD( mef.q3MemberGestation ) gestationAtEnrollmentDays
		FROM
		ABCBS_MaternityEnrollment_Form mef
		INNER JOIN HPAlertNote hpan_mef
		ON hpan_mef.LinkedFormType = 'ABCBS_MaternityEnrollment'
		AND hpan_mef.LinkedFormID = mef.ID
		AND ISNULL( hpan_mef.IsDelete, 0 ) != 1
		INNER JOIN
		(
			SELECT
			*
			FROM
			(
				SELECT
				ammf.*,
				RANK() OVER ( PARTITION BY ammf.OriginalFormID ORDER BY ammf.SectionCompleted DESC, ammf.ID DESC ) order_rank
				FROM
				ABCBS_MMFHistory_Form ammf (READUNCOMMITTED)
				INNER JOIN HPAlertNote hpan_ammf
				ON hpan_ammf.LinkedFormType = 'ABCBS_MMFHistory'
				AND hpan_ammf.LinkedFormID = ammf.ID
				AND ISNULL( hpan_ammf.IsDelete, 0 ) != 1
				WHERE
				ammf.CaseProgram = 'Maternity'
				--AND dbo.MVDIsNull( ammf.CaseID ) = 0
				AND CASE
					WHEN ammf.CaseID IS NULL THEN 1
					WHEN ammf.CaseID = '' THEN 1
					WHEN ammf.CaseID = 'NULL' THEN 1
					ELSE 0
					END = 0
			) mmfr
			WHERE
			mmfr.order_rank = 1
			AND
-- Trigger criteria: 2.) but only if the case does not have a case closed date.
			CASE
			WHEN mmfr.ID IS NOT NULL AND ISNULL( mmfr.qCloseCase, 'No' ) != 'Yes' THEN 1
			WHEN mmfr.ID IS NULL THEN 1
			ELSE 0
			END = 1
		) mmf
		ON mmf.MVDID = mef.MVDID
	) mef
	WHERE
-- Exception: 1.)  If Gestation at time of enrollment is 36 weeks or greater, do not generate the task.
	mef.gestationAtEnrollmentDays < @v_gestation_threshold_days
-- Trigger criteria: 1.) Generate as nightly batch on the member's  maternity due date
	AND mef.DueDate <= getDate()
	AND mef.DueDate > mef.MMFFormDate
	ORDER BY
	mef.MVDID;

	OPEN task_cursor;
	-- Get the first record
	FETCH NEXT FROM task_cursor INTO
		@v_mvd_id,
		@v_case_owner,
		@v_mmf_id,
		@v_mmf_form_date,
		@v_case_id,
		@v_mef_id,
		@v_mef_form_date,
		@v_due_date,
		@v_gestation;

	-- Iterate through the list
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @v_task_id = NULL;

		-- Check to see if the task has already been created
		EXEC Get_MemberTask
			@p_MVDID = @v_mvd_id,
			@p_CaseId = @v_case_id,
			@p_ProcedureName = @v_procedure_name,
			@p_TaskStatus = 'Completed',
			@p_MatchStatusYN = 0,
			@p_CustomerId = @p_CustomerId,
			@p_ProductId = @p_ProductId,
			@p_ID = @v_task_id OUTPUT;

		-- Create the task
		IF ( @v_task_id IS NULL )
		BEGIN
			SET @v_task_narrative = REPLACE( @v_task_narrative_template, @v_maternity_due_date_vartext, CONVERT( varchar, @v_due_date, 107 ) );
			SET @v_task_due_date = DATEADD( DAY, @v_task_due_date_num_days, getDate() );
			SET @v_task_reminder_date = DATEADD( DAY, @v_task_reminder_date_num_days, @v_task_due_date );

			EXEC Set_UserTask
				@Title = @v_task_title,
				@Narrative = @v_task_narrative,
				@MVDID = @v_mvd_id,
				@CustomerId = @p_CustomerId,
				@ProductId = @p_ProductId,
				@CaseId = @v_case_id,
				@TaskType = @v_task_type,
				@TaskPriority = @v_task_priority,
				@TaskStatus = @v_task_status,
				@Owner = @v_case_owner,
				@DueDate = @v_task_due_date,
				@ReminderDate = @v_task_reminder_date,
				@AutomationProcId = @v_quick_action_id,
				@NewTaskId = @v_task_id OUTPUT;
		END;

		-- Get the next record
		FETCH NEXT FROM task_cursor INTO
			@v_mvd_id,
			@v_case_owner,
			@v_mmf_id,
			@v_mmf_form_date,
			@v_case_id,
			@v_mef_id,
			@v_mef_form_date,
			@v_due_date,
			@v_gestation;
	END;

	CLOSE task_cursor;
	DEALLOCATE task_cursor;

END;