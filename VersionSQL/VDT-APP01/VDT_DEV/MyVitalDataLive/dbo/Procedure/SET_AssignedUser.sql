/****** Object:  Procedure [dbo].[SET_AssignedUser]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[SET_AssignedUser]
(
	@CustID int = NULL,
	@ProductID int = 2,
	@AssignedBy varchar(100) = NULL,
	@MVDID varchar(30) = NULL,
	@OwnerType varchar(50) = NULL,
	@FirstName varchar(100) = NULL,
	@LastName varchar(100) = NULL,
	@User varchar(100) = NULL,
	@GroupID  smallint = NULL,
	@UserID nvarchar(128) = NULL,
	@StartDate varchar(100) = NULL,
	@EndDate varchar(100) = NULL,	
	--@IsPrimary bit,
	@IsDeactivated bit,
	@IsEntityFromMMF bit,
	@IsTaskRequired bit = 0,
	@Title nvarchar(100) = NULL,
	@Narrative nvarchar(MAX) = NULL,
	@DueDate datetime = NULL,
	@ReminderDate datetime = NULL,
	@StatusId int = NULL,
	@PriorityId int = NULL,
	@TypeId int = NULL,
	@TaskStatus varchar(100) = NULL,
	@TaskPriority varchar(100) = NULL,
	@TaskType varchar(100) = NULL,
	@Author varchar(100) = NULL,
	@Owner varchar(100) = NULL,
	@NewAssignmentId bigint = NULL OUTPUT,
	@UpdatedOwnerType varchar(100) = NULL OUTPUT,
	@UpdatedDeactivationType bit = 0 OUTPUT,
	@NewUser varchar(100) = NULL OUTPUT,
	@TaskId bigint = NULL OUTPUT
)
AS
BEGIN
-- SET NOCOUNT ON added to prevent extra result sets from
-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @v_custid int = @CustID;
	DECLARE @v_mvdid varchar(30) = CAST( @MVDID AS varchar(30) );

	DECLARE @v_current_primary_userid nvarchar(100);
	DECLARE @v_current_primary_owner nvarchar(100);
	DECLARE @v_assignment_type_code_id int;
	DECLARE @v_owner_assignment_type nvarchar(100);
	DECLARE @v_owner_assignment_type_code_id int;
	DECLARE @v_mmf_id bigint;
	DECLARE @v_case_program nvarchar(max);
	DECLARE @v_case_id nvarchar(255);
	DECLARE @v_form_owner nvarchar(100);
	DECLARE @v_assignment_type_code_mmf int;
	DECLARE @v_assignment_type_code_at int;
	DECLARE @v_other_type nvarchar(255) = 'Other';
	DECLARE @v_primary_type nvarchar(255) = 'Primary';
	DECLARE @v_now datetime = GetUTCDate();
	DECLARE @v_start_date datetime = CASE WHEN @StartDate IS NOT NULL THEN @StartDate WHEN @IsDeactivated = 0 THEN @v_now END;
	DECLARE @v_end_date datetime = CASE WHEN @EndDate IS NOT NULL THEN @EndDate WHEN @IsDeactivated = 1 THEN @v_now END;
	DECLARE @v_updated_record_id bigint;
	DECLARE @v_bypass_yn bit = 0;

	DROP TABLE IF EXISTS
	#ProgramPriority;

	CREATE TABLE
	#ProgramPriority
	(
		Type nvarchar(255),
		Priority int
	);
	INSERT INTO #ProgramPriority( Type, Priority ) VALUES ( 'Case Management', 1 );
	INSERT INTO #ProgramPriority( Type, Priority ) VALUES ( 'Maternity', 2 );
	INSERT INTO #ProgramPriority( Type, Priority ) VALUES ( 'Chronic Condition Management', 3 );
	INSERT INTO #ProgramPriority( Type, Priority ) VALUES ( 'Clinical Support', 4 );
	INSERT INTO #ProgramPriority( Type, Priority ) VALUES ( 'Social Work', 5 );

	SET @NewAssignmentId = NULL;
	SET @UpdatedOwnerType = NULL;
	SET @UpdatedDeactivationType = 0;
	SET @NewUser = NULL;

-- Get the current owner of the member
	SELECT TOP 1
	@v_current_primary_userid = UserID,
	@v_current_primary_owner = OwnerName,
	@v_assignment_type_code_id = AssignmentTypeCodeID
	FROM
	Final_MemberOwner
	WHERE
	CustID = @v_custid
	AND MVDID = @v_mvdid
	AND IsDeactivated = 0
	AND OwnerType = @v_primary_type
	ORDER BY
	ID DESC;

-- Get the owner type of the proposed new owner
	SELECT TOP 1
	@v_owner_assignment_type = OwnerType,
	@v_owner_assignment_type_code_id = AssignmentTypeCodeID
	FROM
	Final_MemberOwner
	WHERE
	CustID = @v_custid
	AND MVDID = @v_mvdid
	AND OwnerName = LTRIM( RTRIM( @User ) )
	AND IsDeactivated = 0
	ORDER BY
	ID DESC;

-- get the MMF assignment type code ID
	SELECT
	@v_assignment_type_code_mmf = CodeID
	FROM
	Lookup_Generic_Code_Type lgct
	INNER JOIN Lookup_Generic_Code lgc
	ON lgc.CodeTypeID = lgct.CodeTypeID
	AND lgc.Label = 'MMF'
	WHERE
	lgct.CodeType = 'AssignmentType';

-- get the assignment tool type code ID
	SELECT
	@v_assignment_type_code_at = CodeID
	FROM
	Lookup_Generic_Code_Type lgct
	INNER JOIN Lookup_Generic_Code lgc
	ON lgc.CodeTypeID = lgct.CodeTypeID
	AND lgc.Label = 'AT'
	WHERE
	lgct.CodeType = 'AssignmentType';

	IF ( @User IS NOT NULL AND LTRIM( RTRIM( @User ) ) = 'Admission AutoQ' )
	BEGIN
		SET @User = dbo.Get_CareQForAdmissionAutoQ( @v_mvdid );
		SET @NewUser = @User;
	END


/*
	EXEC Get_MemberPrimaryCaseOwner
		@p_MVDID = @v_mvdid,
		@p_CaseProgram = @v_case_program OUTPUT,
		@p_FormID = @v_mmf_id OUTPUT,
		@p_CaseID = @v_case_id OUTPUT,
		@p_AssignedUser = @v_form_owner OUTPUT;
*/

	BEGIN TRY
		BEGIN TRANSACTION
-- Can only deactivate an ownership that already exists
			IF ( @v_owner_assignment_type IS NULL AND @IsDeactivated = 1 )
			BEGIN
				SET @v_bypass_yn = 1;
			END;
		
-- If this is a primary assignment
			IF ( @OwnerType = @v_primary_type )
			BEGIN
-- This member is already the active primary owner
				IF ( @v_current_primary_owner = @User )
				BEGIN
					IF ( @IsEntityFromMMF = 1 AND @v_assignment_type_code_id = @v_assignment_type_code_at )
					BEGIN
							UPDATE
							Final_MemberOwner
							SET
							UpdatedBy = @AssignedBy,
							UpdatedDate = @v_now,
							AssignmentTypeCodeID = @v_assignment_type_code_mmf
							WHERE
							CustID = @v_custid
							AND OwnerName = @User
							AND MVDID = @v_mvdid
							AND ISNULL( IsDeactivated, 0 ) = 0
							AND OwnerType = @v_primary_type;
					END;
					SET @v_bypass_yn = 1;
				END;
		
-- There is already an active Primary owner from MMF
				IF ( @IsEntityFromMMF = 0 AND @v_assignment_type_code_id = @v_assignment_type_code_mmf )
				BEGIN
					SET @v_bypass_yn = 1;
				END;
		
				IF ( @v_bypass_yn = 0 )
				BEGIN
-- If there is a change in primary, or a new primary, create primary owner
					IF ( @IsDeactivated = 0 AND ( @v_current_primary_owner != @User OR @v_current_primary_owner IS NULL ) )
					BEGIN
-- PRINT CONCAT( 'Creating Primary Owner: ', @User );
						INSERT INTO
						Final_MemberOwner
						(
							CreatedBy,
							CreatedDate,
							UpdatedBy,
							UpdatedDate,
							UserID,
							GroupID,
							OwnerName,
							FirstName,
							LastName,
							StartDate,
							EndDate,
							CustID,
							MVDID,
							OwnerType,
							IsDeactivated,
							AssignmentTypeCodeID
						)
						VALUES
						(
							@AssignedBy,
							GetUTCDate(),
							@AssignedBy,
							GetUTCDate(),
							@UserID,
							@GroupID,
							@User,
							@FirstName,
							@LastName,
							@v_start_date,
							@v_end_date,
							@v_custid,
							@v_mvdid,
							@OwnerType,
							@IsDeactivated,
							CASE WHEN @IsEntityFromMMF = 1 THEN @v_assignment_type_code_mmf ELSE @v_assignment_type_code_at END
						);
									
						SET @NewAssignmentId = SCOPE_IDENTITY();
			
-- If there is a change in primary, close current primary owner
-- PRINT CONCAT( 'Closing Primary Owner: ', @v_current_primary_owner );
						IF ( @v_current_primary_owner != @User OR @v_current_primary_owner IS NULL )
						BEGIN
-- PRINT CONCAT( 'Closing Primary Owner: ', @v_current_primary_owner );
							UPDATE
							Final_MemberOwner
							SET
							UpdatedBy = @AssignedBy,
							UpdatedDate = @v_now,
							EndDate = @v_now,
							IsDeactivated = 1
							WHERE
							CustID = @v_custid
							AND OwnerName = @v_current_primary_owner
							AND MVDID = @v_mvdid
							AND ISNULL( IsDeactivated, 0 ) = 0
							AND OwnerType = @v_primary_type;
			
/*
From Ragu:
Set @UpdatedDeactivationType to 1 if:
	- Not from MMF
	- there was a previous primary (needs to be deactivated)
	- there is a new primary
*/
							IF ( @IsEntityFromMMF = 0 AND @v_current_primary_owner IS NOT NULL )
							BEGIN
								SET @UpdatedDeactivationType = 1;
							END;
			
-- If there is a change in primary and owner is other, close other owner
-- PRINT CONCAT( 'Closing Other Owner: ', @User );
							IF ( @v_owner_assignment_type = @v_other_type )
							BEGIN
-- PRINT CONCAT( 'Closing Other Owner: ', @User );
								UPDATE
								Final_MemberOwner
								SET
								UpdatedBy = @AssignedBy,
								UpdatedDate = @v_now,
								EndDate = @v_now,
								IsDeactivated = 1
								WHERE
								CustID = @v_custid
								AND OwnerName = @User
								AND MVDID = @v_mvdid
								AND IsDeactivated = 0
								AND OwnerType = @v_other_type;
			
								SET @UpdatedOwnerType = @v_primary_type;
							END;
						END;
			
-- IF source = MMF, create new other owner
						IF ( @IsEntityFromMMF = 1 AND @v_current_primary_owner IS NOT NULL )
						BEGIN
-- PRINT CONCAT( 'Creating Other Owner: ', @v_current_primary_owner );
							INSERT INTO
							Final_MemberOwner
							(
								CreatedBy,
								CreatedDate,
								UpdatedBy,
								UpdatedDate,
								UserID,
								GroupID,
								OwnerName,
								FirstName,
								LastName,
								StartDate,
								EndDate,
								CustID,
								MVDID,
								OwnerType,
								IsDeactivated,
								AssignmentTypeCodeID
							)
							VALUES
							(
								@AssignedBy,
								GetUTCDate(),
								@AssignedBy,
								GetUTCDate(),
								@v_current_primary_userid,
								@GroupID,
								@v_current_primary_owner,
								@FirstName,
								@LastName,
								@v_start_date,
								@v_end_date,
								@v_custid,
								@v_mvdid,
								@v_other_type,
								@IsDeactivated,
								@v_assignment_type_code_mmf
							);
						END;
		
					END;
				END;
			END;
		
-- If this is an other assignment
			IF ( @OwnerType = @v_other_type )
			BEGIN
-- This member is already the active primary owner
				IF ( @v_current_primary_owner = @User AND @v_owner_assignment_type_code_id = @v_assignment_type_code_mmf )
				BEGIN
					SET @v_bypass_yn = 1;
				END;
		
-- There is already an active Primary owner from MMF
				IF ( @IsEntityFromMMF = 0 AND @v_owner_assignment_type_code_id = @v_assignment_type_code_mmf )
				BEGIN
					SET @v_bypass_yn = 1;
				END;
		
-- MMF can not initiate an other ownership
				IF ( @IsEntityFromMMF = 1 AND @v_owner_assignment_type = @v_other_type )
				BEGIN
					SET @v_bypass_yn = 1;
				END;
		
				IF ( @v_bypass_yn = 0 )
				BEGIN
					IF
					(
						CASE
-- If owner is being downgraded from primary to other
						WHEN @v_owner_assignment_type = @v_primary_type THEN 1
-- If there is no assignment by Owner
						WHEN @v_owner_assignment_type IS NULL THEN 1
						END = 1
					)
					BEGIN
-- Close current primary owner
-- PRINT CONCAT( 'Closing primary Owner: ', @User );
						IF ( @v_owner_assignment_type IS NOT NULL )
						BEGIN
							UPDATE
							Final_MemberOwner
							SET
							UpdatedBy = @AssignedBy,
							UpdatedDate = @v_now,
							EndDate = @v_now,
							IsDeactivated = 1
							WHERE
							CustID = @v_custid
							AND OwnerName = @User
							AND MVDID = @v_mvdid
							AND ISNULL( IsDeactivated, 0 ) = 0
							AND OwnerType = @v_primary_type;
			
							SET @UpdatedOwnerType = @v_other_type;
						END;
			
-- Create new other owner
-- PRINT CONCAT( 'Creating other Owner: ', @User );
						IF ( @IsDeactivated = 0 )
						BEGIN
							INSERT INTO
							Final_MemberOwner
							(
								CreatedBy,
								CreatedDate,
								UpdatedBy,
								UpdatedDate,
								UserID,
								GroupID,
								OwnerName,
								FirstName,
								LastName,
								StartDate,
								EndDate,
								CustID,
								MVDID,
								OwnerType,
								IsDeactivated,
								AssignmentTypeCodeID
							)
							VALUES
							(
								@AssignedBy,
								GetUTCDate(),
								@AssignedBy,
								GetUTCDate(),
								@UserID,
								@GroupID,
								@User,
								@FirstName,
								@LastName,
								@v_start_date,
								@v_end_date,
								@v_custid,
								@v_mvdid,
								@OwnerType,
								@IsDeactivated,
								CASE WHEN @IsEntityFromMMF = 1 THEN @v_assignment_type_code_mmf ELSE @v_assignment_type_code_at END
							);
						END;
			
						SET @NewAssignmentId = SCOPE_IDENTITY();
					END;
		
				END;
			END;

-- Task creation
			IF ( @v_bypass_yn = 0 )
			BEGIN
				IF ( @IsTaskRequired = 1 )
				BEGIN
					EXEC Set_UserTask
						@Title = @Title,
						@Narrative = @Narrative,
						@MVDID = @v_mvdid,
						@CustomerId = @v_custid,
						@ProductId = @ProductID,
						@Author = @Author,
						@Owner = @Owner,
						@CreatedDate = @v_now,
						@UpdatedDate = @v_now,
						@DueDate = @DueDate,
						@ReminderDate = @ReminderDate,
						@StatusId = @StatusId,
						@PriorityId = @PriorityId,
						@TypeId = @TypeId,
						@TaskStatus = @TaskStatus,
						@TaskPriority = @TaskPriority,
						@TaskType = @TaskType,
						@NewTaskId = @TaskId OUTPUT;
				END;
			END;
		COMMIT;
	END TRY
	BEGIN CATCH
		IF ( @@TRANCOUNT > 0 )
		BEGIN
			ROLLBACK;
		END;
	END CATCH;

END;