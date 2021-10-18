/****** Object:  Procedure [dbo].[Set_UserTask]    Committed by VersionSQL https://www.versionsql.com ******/

/*
									Set_UserTask

Modifications:	
WHO			WHEN		WHAT
dpatel		03/06/2019	created
Spaitereddy 03/26/2019	Insert/Update user created task.
dpatel		10/14/2019	Updated proc to accept literals for Task - Status, Priority, and Type. SO @StatusId vs. @TaskStatus, 
                        @PriorityId vs. @TaskPriority, @TypeId vs. @TaskType can work mutually exclusively.
dpatel		10/14/2019	Updated proc to pre-determine CareQ for MVDID if input @Owner is Admission AutoQ. Performance improvement.
ezanelli	10/25/2019  Made @CreatedDate optional and defaulted CreatedDate and UpdatedDate on insert
ezanelli	10/25/2019	Added calls to uspUpdateCCQOpenTaskCount after insert and update
schisman	6/16/2020	Added new columns to Task table for latest task activity. Update these columns in addition insert into TaskActivityLog. #3143

*/
CREATE PROCEDURE [dbo].[Set_UserTask]
	@Id bigint = NULL,
	@Title nvarchar(100),
	@Narrative nvarchar(MAX),
	@MVDID varchar(20),
	@CustomerId int,
	@ProductId int,
	@Author varchar(100) = NULL,
	@Owner varchar(100) = NULL,
	@UpdatedBy varchar(100) = NULL,
	@CreatedDate datetime = NULL,
	@UpdatedDate datetime = NULL,
	@DueDate datetime = NULL,
	@ReminderDate datetime = NULL,
	@CompletedDate datetime = NULL,
	@PercentComplete tinyint = NULL,
	@StatusId int = Null,
	@PriorityId int = null,
	@TypeId int = null,
	@ParentTaskId bigint = NULL,
	@TaskLibraryId int = NULL,
	@AutomationProcId int = NULL,
	@SensitivityId int = NULL,
	@AccountingId int = NULL,
	@CaseId varchar(50) = NULL,
	@IsDelete bit = null,
	@ReasonForUpdate varchar(250) = null,
	@GroupID int =null,
	@TaskStatus varchar(100) = null,
	@TaskPriority varchar(100) = null,
	@TaskType varchar(100) = null,
	@NewTaskId bigint output,
	@NewGroupOwner varchar(100) = null output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @CodeTypeId int;
	DECLARE @v_num int;

	if @StatusId is null
		begin
			set @CodeTypeId = (select CodeTypeID from Lookup_Generic_Code_Type where CodeType = 'TaskStatus')
			SET @StatusId = (SELECT CodeId FROM Lookup_Generic_Code WHERE Label = ISNULL(@TaskStatus, 'New') and CodeTypeID = @CodeTypeId)		
		end

	if @PriorityId is null
		begin
			set @CodeTypeId = (select CodeTypeID from Lookup_Generic_Code_Type where CodeType = 'TaskPriority')
			SET @PriorityId = (SELECT CodeId FROM Lookup_Generic_Code WHERE LABEL = ISNULL(@TaskPriority, 'Medium') and CodeTypeID = @CodeTypeId)		
		end

	if @TypeId is null
		begin
			set @CodeTypeId = (select CodeTypeID from Lookup_Generic_Code_Type where CodeType = 'TaskType')
			SET @TypeId = (SELECT CodeId FROM Lookup_Generic_Code WHERE LABEL = ISNULL(@TaskType, 'General') and CodeTypeID = @CodeTypeId)		
		end

	--get appropriate owner for task if owner is Admission AutoQ
	if @Owner is not null and LTRIM(RTRIM(@Owner)) = 'Admission AutoQ'
		begin
			select @Owner = dbo.Get_CareQForAdmissionAutoQ(@MVDID)
			set @NewGroupOwner = @Owner
		end

	if @GroupID is null
		begin
			if exists (select top 1 ID from HPAlertGroup where [Name] = @Owner and Cust_ID = @CustomerId and Active = 1)
				begin
					select top 1 @GroupID = ID from HPAlertGroup where [Name] = @Owner and Cust_ID = @CustomerId and Active = 1
				end
		end

	if @Id is null
		begin
			Insert into Task
			(
				Title,
				Narrative,
				MVDID,
				CustomerId,
				ProductId,
				Author,
				CreatedDate,
				UpdatedDate,
				ReminderDate,
				CompletedDate,
				PercentComplete,
				TypeId,
				ParentTaskId,
				TaskLibraryId,
				AutomationProcId,
				SensitivityId,
				AccountingId,
				CaseId,
				UpdatedBy,
				IsDelete,
				--added 2020-06-16 scott
				Owner,
				DueDate,
				StatusID,
				PriorityID,
				GroupID
			)
			values
			(
				 @Title
				,@Narrative
				,@MVDID
				,@CustomerId
				,@ProductId
				,@Author
				--,@Owner
				,ISNULL( @CreatedDate, GetUTCDate() )
				,ISNULL( @UpdatedDate, GetUTCDAte() )
				--,@DueDate
				,@ReminderDate
				,@CompletedDate
				,@PercentComplete
				--,@StatusId
				--,@PriorityId
				,@TypeId
				,@ParentTaskId
				,@TaskLibraryId
				,@AutomationProcId
				,@SensitivityId
				,@AccountingId
				,@CaseId
				,@UpdatedBy
				,@IsDelete
		        --added 2020-06-16 scott
				,@Owner
				,@DueDate
				,@StatusID
				,@PriorityID
				,@GroupID
			)

			set @NewTaskId = SCOPE_IDENTITY()

			EXEC uspUpdateCCQOpenTaskCount @p_MVDID = @MVDID, @p_OpenTaskCount = @v_num OUTPUT;

			Insert into TaskActivityLog 
			(	[TaskId]
			   ,[Owner]
			   ,[DueDate]
			   ,[StatusId]
			   ,[PriorityId]
			   ,[CreatedDate]
			   ,[CreatedBy]
			   ,[ReasonForUpdate]
			   ,GroupID)
				values (@NewTaskId
						,@Owner
						,@DueDate
						,@StatusId
						,@PriorityId
						,ISNULL( @CreatedDate, GetUTCDate() )
						,@Author
						,@ReasonForUpdate
						,@GroupID)
		end
	else
		begin
				Update Task
				set
					Title = @Title,
					Narrative = @Narrative,
					MVDID = @MVDID,
					CustomerId = @CustomerId,
					ProductId = @ProductId,
					Author = @Author,
					--[Owner] = @Owner,
					CreatedDate = ISNULL( @CreatedDate, CreatedDate ),
					UpdatedDate = ISNULL( @UpdatedDate, GetUTCDate() ),
					--DueDate = @DueDate,
					ReminderDate = @ReminderDate,
					CompletedDate = @CompletedDate,
					PercentComplete = @PercentComplete,
					--StatusId = @StatusId,
					--PriorityId = @PriorityId,
					TypeId = @TypeId,
					ParentTaskId = @ParentTaskId,
					TaskLibraryId = @TaskLibraryId,
					AutomationProcId = @AutomationProcId,
					SensitivityId = @SensitivityId,
					AccountingId = @AccountingId,
					CaseId = @CaseId,
					UpdatedBy = @UpdatedBy,
					IsDelete = @IsDelete,
					--added 2020-06-16 scott
					Owner = @Owner,
					DueDate = @DueDate,
					StatusID = @StatusID,
					PriorityID = @PriorityID,
					GroupID = @GroupID
				where Id = @Id

				-- If task is closed, update the open task count for the member
				IF ( @CompletedDate IS NOT NULL ) EXEC uspUpdateCCQOpenTaskCount @p_MVDID = @MVDID, @p_OpenTaskCount = @v_num OUTPUT;

				--If the task status has changed, add it to the task activity log.
			DECLARE @oldOwner varchar(100), @oldDueDate datetime, @oldStatusId int, @oldPriorityId int, @oldGroupID int, @MaxCreatedDate datetime

			SELECT @MaxCreatedDate = MAX(CreatedDate) FROM TaskActivityLog WHERE TaskID = @ID 

			SELECT @oldOwner = Owner,
			       @oldDueDate = DueDate, 
				   @oldStatusID = StatusID,
				   @oldPriorityID = PriorityID,
				   @oldGroupID = GroupID 
			  FROM TaskActivityLog 
             WHERE TaskID = @ID
			   AND CreatedDate = @MaxCreatedDate 

			 if ((@Owner is not null and ISNULL(@oldOwner,'') <> @Owner)
				or (@DueDate is not null and ISNULL(@oldDueDate, cast(-53690 as datetime)) <> @DueDate)
				or (@StatusId is not null and ISNULL(@oldStatusId, -99) <> @StatusId)
				or (@PriorityId is not null and ISNULL(@oldPriorityId, -99) <> @PriorityId)
				or (ISNULL(@oldGroupID, -99) <> ISNULL(@GroupID,-99)))
				begin 
					Insert into TaskActivityLog 
					   ([TaskId]
					   ,[Owner]
					   ,[DueDate]
					   ,[StatusId]
					   ,[PriorityId]
					   ,[CreatedDate]
					   ,[CreatedBy]
					   ,[ReasonForUpdate]
					   ,GroupID)
						values ( @Id
								,@Owner
								,@DueDate
								,@StatusId
								,@PriorityId
								,ISNULL( ISNULL( @UpdatedDate, @CreatedDate ), GetUTCDate() )
								,@UpdatedBy
								,@ReasonForUpdate
								,@GroupID)
				end
		end

END 