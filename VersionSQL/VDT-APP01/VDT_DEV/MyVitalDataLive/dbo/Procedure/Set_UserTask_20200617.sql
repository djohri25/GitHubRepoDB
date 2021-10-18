/****** Object:  Procedure [dbo].[Set_UserTask_20200617]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		dpatel
-- Create date: 03/06/2019
-- Modified date: 03/26/2019
-- Change: Spaitereddy
-- Description:	Insert/Update user created task.
-- dpatel - 10/14/2019 - Updated proc to accept literals for Task - Status, Priority, and Type. SO @StatusId vs. @TaskStatus, @PriorityId vs. @TaskPriority, @TypeId vs. @TaskType can work mutually exclusively.
-- dpatel - 10/14/2019 - Updated proc to pre-determine CareQ for MVDID if input @Owner is Admission AutoQ. Performance improvement.
-- ezanelli - 10/25/2019 - Made @CreatedDate optional and defaulted CreatedDate and UpdatedDate on insert
-- ezanelli - 10/25/2019 - Added calls to uspUpdateCCQOpenTaskCount after insert and update
-- =============================================
CREATE PROCEDURE [dbo].[Set_UserTask_20200617]
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
				IsDelete
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
			)

			set @NewTaskId = SCOPE_IDENTITY()

--			EXEC uspUpdateCCQOpenTaskCount @p_MVDID = @MVDID, @p_OpenTaskCount = @v_num OUTPUT;

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
				IsDelete = @IsDelete
			where Id = @Id

/*			-- If task is closed, update the open task count for the member

			IF ( @CompletedDate IS NOT NULL )
			BEGIN
				EXEC uspUpdateCCQOpenTaskCount @p_MVDID = @MVDID, @p_OpenTaskCount = @v_num OUTPUT;
			END;
*/

	--if (@Owner is not null or @DueDate is not null or @StatusId is not null or @PriorityId is not null)

	--begin 

	------select 3,	'dpatel',	'2019-03-27 07:00:00.000',	238,	242,	'2019-03-26 23:45:31.373',	'dpatel',	NULL

	--select @CreatedDate=  max(CreatedDate) from  TaskActivityLog where TaskId=@Id

	--if @Owner is null 
	--select @Owner = owner from TaskActivityLog where CreatedDate=@CreatedDate and  TaskId=@Id

	--if @DueDate is null 
	--select @DueDate = DueDate from TaskActivityLog where CreatedDate=@CreatedDate and TaskId=@Id

	--if @StatusId is null 
	--select @StatusId = StatusId from TaskActivityLog where CreatedDate=@CreatedDate and  TaskId=@Id

	--if @PriorityId is null 
	--select @PriorityId = PriorityId from TaskActivityLog where CreatedDate=@CreatedDate and TaskId=@Id

declare @oldOwner varchar(100), @oldDueDate datetime, @oldStatusId int, @oldPriorityId int, @maxCreatedDate datetime

select @maxCreatedDate= max(createddate) from TaskActivityLog where TaskId=@Id

select @oldOwner=Owner,@oldDueDate=DueDate,@oldStatusId=StatusId, @oldPriorityId= PriorityId 
from   TaskActivityLog where TaskId=@Id and createddate=@maxCreatedDate

if ((@Owner is not null and ISNULL(@oldOwner,'') <> @Owner)
	or (@DueDate is not null and ISNULL(@oldDueDate, cast(-53690 as datetime)) <> @DueDate)
	or (@StatusId is not null and ISNULL(@oldStatusId, -99) <> @StatusId)
	or (@PriorityId is not null and ISNULL(@oldPriorityId, -99) <> @PriorityId))

	Begin
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
						,@Author
						,@ReasonForUpdate
						,@GroupID)
	END
end
 --New logic update for form owner   
	--IF @Id IS NULL
	--	begin
	--		exec [dbo].[ARBCBS_UpdateFormOwner] @NewTaskId
	--	end
	--else
	--	begin
	--		exec [dbo].[ARBCBS_UpdateFormOwner] @Id
	--	end    
End 