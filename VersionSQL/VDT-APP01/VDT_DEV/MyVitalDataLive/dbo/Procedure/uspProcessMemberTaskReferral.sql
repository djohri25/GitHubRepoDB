/****** Object:  Procedure [dbo].[uspProcessMemberTaskReferral]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		dpatel
-- Create date: 05/12/2020
-- Description:	Insert new Task and related metadata to tables for new Task Referral web-service endpoint
-- =============================================
CREATE PROCEDURE [dbo].[uspProcessMemberTaskReferral]
	@ProductId int,
	@CustomerId int,
	@MemberId varchar(50),
	@LOB varchar(50)= null,
	@Title nvarchar(100),
	@Narrative nvarchar(max) ,
	@Author varchar(100) =null,
	@Owner varchar(100),
	@CreatedDate datetime =null,
	@DueDate datetime =null,
	@TaskStatus varchar(50)= null,
	@TaskPriority varchar(50) = null ,
	@TaskType varchar(50) = null,
	@CheckAssignment bit =null, -- 0=N, 1=Y
	@ReferralId bigint output,
	@NewTaskId bigint OUTPUT

	--not needed for task webservice
	--@ReferralReason varchar(150),	--ReferralReason parameter from web-service
	--@ReferralSource varchar(50) =null, 
	--@CaseProgram varchar(150),
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	BEGIN TRY
		BEGIN TRANSACTION

			Declare @MVDID varchar(50),
					@TempOwner varchar(50)
			
			if exists (select MVDID from ComputedCareQueue where MemberID = @MemberId and LOB = @LOB)
				begin
					select @MVDID = MVDID
					from ComputedCareQueue 
					where MemberID = @MemberId 
						and LOB = @LOB 
				end
			else
				begin
					RAISERROR('Member not found.', 16, 1)
				end

			if @CheckAssignment = 1
				begin
					--Check if there is any active primary user (not group) owner, then assign task to that user. Else assign task to owner from web-service request.
					if exists (select UserID from Final_MemberOwner 
							   where MVDID = @MVDID 
								and OwnerType = 'Primary'
								and LTRIM(RTRIM(ISNULL(UserID, ''))) <> ''
								and LTRIM(RTRIM(ISNULL(OwnerName, ''))) <> ''
								and ISNULL(IsDeactivated, 0) = 0)
						begin
							select top (1) @TempOwner = OwnerName 
							from Final_MemberOwner 
							where MVDID = @MVDID 
								and OwnerType = 'Primary'
								and LTRIM(RTRIM(ISNULL(UserID, ''))) <> ''
								and LTRIM(RTRIM(ISNULL(OwnerName, ''))) <> ''
								and ISNULL(IsDeactivated, 0) = 0
							order by StartDate desc

							if LTRIM(RTRIM(ISNULL(@TempOwner, ''))) <> ''
								begin
									set @Owner = @TempOwner
								end
						end
				end

			If @Author is null 
				begin
					set @Author='System'
				end
		
			--Create New Task
			EXECUTE [dbo].[Set_UserTask] 
			   @Title=@Title
			  ,@Narrative=@Narrative
			  ,@MVDID=@MVDID
			  ,@CustomerId=@CustomerId
			  ,@ProductId=@ProductId
			  ,@Author=@Author
			  ,@Owner=@Owner        --******************* dpatel- Check if Form Owner is correct? Should form owner be owner from task web-service? Yes, owner will always be from web-service.
			  ,@CreatedDate=@CreatedDate
			  ,@DueDate=@DueDate
			  ,@TaskStatus=@TaskStatus
			  ,@TaskPriority=@TaskPriority
			  ,@TaskType=@TaskType
			  ,@NewTaskId =@NewTaskId OUTPUT

			--Insert into MemberReferral 
			EXECUTE  [dbo].[uspInsertMemberReferral] 
			   @DocID=null									--This would be null for Task referral web-service
			  ,@ParentDocID=null							--This would be null for Task referral web-service 
			  ,@MemberID=@MemberID							--not null
			  ,@TaskID=@NewTaskId							--not null - a new TaskId
			  ,@TaskSource='Task Notification Web Service'	--null for task webservice
			  ,@CaseProgram=null							--null for task webservice
			  ,@ParentReferralID=NULL						--This would be null for Task referral web-service 
			  ,@NonViableReason=NULL						--This would be null for Task referral web-service 
			  ,@CreatedDate=@CreatedDate					--not null
			  ,@CreatedBy=@Author							--not null 
			  ,@CheckAssignment=@CheckAssignment			--not null
			  ,@Cust_ID=@CustomerId							--not null
			  ,@ReferralId=@ReferralId OUTPUT				--not null 
		COMMIT
	END TRY
	BEGIN CATCH
	    THROW 
		ROLLBACK
	END CATCH
END