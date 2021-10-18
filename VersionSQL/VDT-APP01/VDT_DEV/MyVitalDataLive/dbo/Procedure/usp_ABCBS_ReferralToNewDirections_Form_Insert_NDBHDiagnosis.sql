/****** Object:  Procedure [dbo].[usp_ABCBS_ReferralToNewDirections_Form_Insert_NDBHDiagnosis]    Committed by VersionSQL https://www.versionsql.com ******/

-- ========================================================
-- Author:		Deepank Johri
-- Create date: 2021-09-14
-- Description:	Create Task, MemberReferralForm & HP Alert Note for FormAuthors=System 
-- Example: exec [dbo].[usp_ABCBS_ReferralToNewDirections_Form_Insert_NDBHDiagnosis]
-- Modified:			
-- ========================================================
CREATE PROCEDURE
[dbo].[usp_ABCBS_ReferralToNewDirections_Form_Insert_NDBHDiagnosis]
(
	@p_PrintOnlyYN bit = 0
)
AS
BEGIN
	SET NOCOUNT ON;

	--DECLARE @v_task_type_id bigint;
	--DECLARE @v_task_status_id bigint;
	--DECLARE @v_task_priority_id bigint;

	DECLARE @v_form_id bigint;
	DECLARE @v_mvdid nvarchar(255);
	DECLARE @v_member_id nvarchar(255);

	DECLARE @v_task_exists_yn bit = 0;
	--DECLARE @v_referral_exists_yn bit = 0;
	--DECLARE @v_alert_note_exists_yn bit = 0;

	DECLARE @ReferralTo nvarchar(255) 
	--DECLARE @v_task_title nvarchar(255) 
	--DECLARE @v_task_narrative nvarchar(255) = 'Member has a new referral to New Directions.  Please review the ABCBS and New Directions Referral Form.';
	--DECLARE @v_customer_id bigint = 16;
	--DECLARE @v_product_id bigint = 2;
	DECLARE @v_owner nvarchar(255) = 'NDBH';
	--DECLARE @v_now date = GetUTCDate();
	--DECLARE @v_due_date date = DATEADD( DAY, 1, @v_now );
	--DECLARE @v_reminder_date date = NULL;
	--DECLARE @v_task_id bigint;
	--DECLARE @v_task_owner nvarchar(255) 	
	--DECLARE @v_group_id bigint 	
	--DECLARE @v_new_group_owner nvarchar(255);
	--DECLARE @v_task_source nvarchar(255) = 'New Directions Referrals';
	--DECLARE @v_case_program nvarchar(255) = 'CareFlowRule';
	--DECLARE @v_member_referral_created_by nvarchar(255) = 'VDT';
	--DECLARE @v_check_assignment bigint = 1;
	--DECLARE @v_referral_id bigint;
	DECLARE @v_form_type nvarchar(255) = 'ABCBS_ReferraltoNewDirections';
	DECLARE @v_note nvarchar(255) = 'ABCBS and New Directions Referral Form Saved.';
	DECLARE @v_code_type nvarchar(255) = 'NoteType';
	DECLARE @v_label nvarchar(255) = 'DocumentNote';
	DECLARE @v_hp_alert_note_id bigint;

	--SELECT
	--@v_task_type_id = c.CodeID
	--FROM
	--Lookup_Generic_Code_Type ct
	--INNER JOIN Lookup_Generic_Code c
	--ON c.CodeTypeID = ct.CodeTypeID
	--AND c.Label = 'Referral'
	--WHERE
	--ct.CodeType = 'TaskType';

	--SELECT
	--@v_task_status_id = c.CodeID
	--FROM
	--Lookup_Generic_Code_Type ct
	--INNER JOIN Lookup_Generic_Code c
	--ON c.CodeTypeID = ct.CodeTypeID
	--AND c.Label = 'New'
	--WHERE
	--ct.CodeType = 'TaskStatus';

	--SELECT
	--@v_task_priority_id = c.CodeID
	--FROM
	--Lookup_Generic_Code_Type ct
	--INNER JOIN Lookup_Generic_Code c
	--ON c.CodeTypeID = ct.CodeTypeID
	--AND c.Label = 'Medium'
	--WHERE
	--ct.CodeType = 'TaskPriority';

	--SELECT
	--@v_group_id = ID
	--FROM
	--HPAlertGroup
	--WHERE
	--Name = @v_task_owner;

-- Get list of forms to process
	DECLARE form_cursor
	CURSOR FOR
	SELECT
	ID,
	MVDID,
	MemID,
	q1RefTo
	FROM
	ABCBS_ReferraltoNewDirections_Form
	WHERE
	LoadDate IS NOT NULL
	AND FormAuthor = 'SYSTEM';


	OPEN form_cursor;
-- Get the first record from the cursor
	FETCH NEXT FROM form_cursor INTO
		@v_form_id,
		@v_mvdid,
		@v_member_id,
		@ReferralTo;

	WHILE @@FETCH_STATUS = 0
	BEGIN
-- Iterate through the records
		SET @v_task_exists_yn = 0;

---- If referral has been created, then we already processed the form
--		SELECT
--		@v_task_exists_yn = 1
--		FROM
--		MemberReferral
--		WHERE
--		MemberID = @v_member_id
--		AND DocID = @v_form_id;

		IF ( @v_task_exists_yn = 0 )
		BEGIN
-- Process the form
			BEGIN TRANSACTION

			--IF ( @p_PrintOnlyYN = 0 )
			--BEGIN
			 
			--SET @v_task_title = case when @ReferralTo = 'NewDirections' then 'Referral to New Directions'  end;

   --         SET @v_task_owner = 'NewDirections'
       
---- Create the task
--				EXEC Set_UserTask
--					@Title = @v_task_title,
--					@Narrative = @v_task_narrative,
--					@MVDID = @v_mvdid,
--					@CustomerID = @v_customer_id,
--					@ProductID = @v_product_id,
--					@Owner = @v_task_owner,
--					@Author = @v_owner,
--					@CreatedDate = @v_now,
--					@UpdatedDate = @v_now,
--					@DueDate = @v_due_date,
--					@ReminderDate = @v_reminder_date,
--					@StatusID = @v_task_status_id,
--					@PriorityID = @v_task_priority_id,
--					@TypeID = @v_task_type_id,
--					@IsDelete = 0,
--					@GroupID = @v_group_id,
--					@TaskStatus = @v_task_status_id,
--					@TaskPriority = @v_task_priority_id,
--					@NewTaskID = @v_task_id OUTPUT,
--					@NewGroupOwner = @v_new_group_owner OUTPUT;
--			END
--			ELSE
--			BEGIN
--				PRINT CONCAT( 'About to create task for MVDID = ', @v_mvdid );
--			END;

			IF ( @p_PrintOnlyYN = 0 )
			BEGIN
-- Create the HP alert note
				EXEC Set_HPAlertNoteForForm
					@MVDID = @v_mvdid,
					@Owner = @v_owner,
					@Note = @v_note,
					@FormID = @v_form_type,
					@MemberFormID = @v_form_id,
					@StatusID = 0,
					@CodeType = @v_code_type,
					@Label = @v_label,
					@Result = @v_hp_alert_note_id;
			END
			ELSE
			BEGIN
				PRINT CONCAT( 'About to create HP alert note for MVDID = ', @v_mvdid, ' and ND form ID = ', @v_form_id, '.' );
			END;

--			IF ( @p_PrintOnlyYN = 0 )
--			BEGIN
---- Create the referral
--				EXEC uspInsertMemberReferral
--					@DocID = @v_form_id,
--					@MemberID = @v_member_id,
--					@TaskID = @v_task_id,
--					@TaskSource = @v_task_source,
--					@CaseProgram = @v_case_program,
--					@CreatedDate = @v_now,
--					@CreatedBy = @v_member_referral_created_by,
--					@CheckAssignment = @v_check_assignment,
--					@Cust_ID = @v_customer_id,
--					@ReferralID = @v_referral_id OUTPUT;
--			END
--			ELSE
--			BEGIN
--				PRINT CONCAT( 'About to create member referral for Member ID = ', @v_member_id, ' and task ID = ', @v_task_id, ' and ND form ID = ', @v_form_id, '.' );
--			END;

		COMMIT TRANSACTION;
	END;

-- Get the next record from the cursor
		FETCH NEXT FROM form_cursor INTO
			@v_form_id,
			@v_mvdid,
			@v_member_id,
			@ReferralTo;
	END;

	CLOSE form_cursor;
	DEALLOCATE form_cursor;
END;