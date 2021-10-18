/****** Object:  Procedure [dbo].[uspInsertInboundMessage]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		dpatel
-- Create date: 06/22/2020
-- Description:	Insert inbound message and task.
/*
Example

declare @outputMessageId bigint
exec uspInsertInboundMessage
	@MVDID = '16466DTMP',
	@ClientThreadId = '4E67D992-7FE2-437E-B5C0-DBD42D5E8F05',
	@ClientMessageId = 'DA1E5C96-3D44-44A3-9881-729E95CC9B33',
	@TopicId = 329,
	@TopicGuid = '07CBDE01-1F9A-44E4-8DAB-57D8E52FED0A',
	@Message = 'Sko 11/4/2020 23:17',
	@CreatedDate = '2020-11-05 07:17:54.570',
	@CreatedBy  = 'Member',
	@ThreadOwner = '4B7BD117-F86D-4C64-B554-252EFC7EC2E7',
	@OutputMessageId = @outputMessageId

select @outputMessageId
*/

-- =============================================
CREATE PROCEDURE [dbo].[uspInsertInboundMessage] 
	@MVDID varchar(50),
	@ClientThreadId uniqueidentifier = null,
	@ClientMessageId uniqueidentifier = null,
	@TopicId int = null,
	@TopicGuid uniqueidentifier = null,
	@Message varchar(max),
	@CreatedDate datetime,
	@CreatedBy varchar(250),
	@ThreadOwner uniqueidentifier = null,
	--@Owner varchar(250) = null,
	@OutputMessageId bigint output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	BEGIN TRY
		BEGIN TRANSACTION

			declare @InternalThreadId bigint,
					@PlanLinkStatusId int,
					@ThreadPopulationId int,
					@MessageSenderTypeId int,
					@MessageDirectionId int,
					@IsActive bit = 1,
					@ClientAppId int = 4,
					@NewMessageId bigint,
					@NewIMId bigint,
					@Topic varchar(250),
					@NewTaskId bigint,
					@DueDate datetime = getutcdate(),
					@NoteTypeId int,
					@Note varchar(max),
					@NewMessageNoteId bigint,
					@Owner varchar(250),
					@AspnetUserName varchar(256) = null;
			
			--added to support quick fix solution of inbound messaging
			if @TopicId is null
				begin
					if @TopicGuid is null
						begin
							--hardcode to general message
							select @TopicId = lgcg.CodeId
							from LookupGenericCodeGuid lgcg
							join Lookup_Generic_Code lgc on lgcg.CodeId = lgc.CodeID and lgc.CodeTypeID = 19
							where lgc.Label = 'General'
						end
					else
						begin
							--Get TopicId (Lookup_Generic_Code) value for @TopicGuid
							select @TopicId = lgcg.CodeId
							from LookupGenericCodeGuid lgcg
							join Lookup_Generic_Code lgc on lgcg.CodeId = lgc.CodeID and lgc.CodeTypeID = 19
							where lgcg.CodeGuid = @TopicGuid
						end
				end
			
			--if message already exists then exit proc execution
			if exists (
						select
							Id
						from [Message]
						where ClientThreadId = @ClientThreadId
							and ClientMessageId = @ClientMessageId
					  )
				begin
					set @OutputMessageId = -1
					COMMIT;
					return;		
				end

			if @ThreadOwner is not null
				begin
					select @AspnetUserName = UserName
					from [dbo].[AspNetUsers]
					where Id = ltrim(rtrim(@ThreadOwner))
				end

			--Get internal ThreadId for a member if there is any existing thread.
			if @ClientThreadId is not null
				begin
					--check if existing thread
					select top 1 @InternalThreadId = [InternalThreadId] 
					from dbo.[Message]
					where ClientThreadId = @ClientThreadId;

					if @InternalThreadId is not null
						begin
							--Thread already exist
							--Get existing thread owner of the thread.
							select @Owner = ActiveOwner
							from ThreadActiveOwner
							where MVDID = @MVDID 
								and InternalThreadId = @InternalThreadId

							--If existing owner is Clinical Support and Passed-in Owner is different, which should be highly unlikely, then assign passed in owner.
							--Else existing thread owner
							if ISNULL(@Owner, '') = 'Clinical Support' and ISNULL(@AspnetUserName, '') != ''
								begin
									set @Owner = @AspnetUserName;

									update ThreadActiveOwner
									set ActiveOwner = @AspnetUserName
									where MVDID = @MVDID
										and InternalThreadId = @InternalThreadId
								end

							--Get existing topic id of the thread
							select top 1 @TopicId = m.TopicId
							from dbo.[Message] m
							where m.ClientThreadId = @ClientThreadId
								and m.InternalThreadId = @InternalThreadId;

							select @Topic = Label_Desc from Lookup_Generic_Code where CodeId = @TopicId

							--set initial part of chart message
							set @Note = case 
											when @Topic is null then '' 
											else @Topic + ' | '
										end;

							set @Note = CONCAT(@Note,'Reply Message from member');
						end
					else
						begin
						--Thread doesn't exists. New Message+Thread.
							if ISNULL(@AspnetUserName, '') != ''
								begin
									set @Owner = @AspnetUserName;
								end
							else
								begin
									set @Owner = 'Clinical Support';
								end
						end
				end
			else		
			--This else should not happen. Check is already in place in Polling API. 
			--Check PollingAPI logic. If ClientThreadId is coming null then report to MobileAPI. 
				begin
					if ISNULL(@AspnetUserName, '') != ''
						begin
							set @Owner = @AspnetUserName;
						end
					else
						begin
							set @Owner = 'Clinical Support';
						end
				end

			--mostly brand new message
			if @InternalThreadId is null
				begin
					--New Thread. Get max InternalThreadId
					select @InternalThreadId = max(m.InternalThreadId) 
					from dbo.[Message] m
					join dbo.Link_MessageMember lmm on m.Id = lmm.MId and lmm.MVDID = @MVDID;

					if @InternalThreadId is null
						begin
							--First time message + thread for this member
							set @InternalThreadId = 1;
						end
					else
						begin
							--Member already has existing thread(s)
							set @InternalThreadId = @InternalThreadId + 1;
						end

					Insert into ThreadActiveOwner
					(
						[MVDID],
						[InternalThreadId],
						[ActiveOwner]
					)
					values
					(
						@MVDID, 
						@InternalThreadId, 
						@Owner
					)

					select @Topic = Label_Desc from Lookup_Generic_Code where CodeId = @TopicId

					--set initial part of chart message
					set @Note = case 
									when @Topic is null then '' 
									else @Topic + ' | '
								end;

					set @Note = CONCAT(@Note,'New Message from member');
				end
			
			select @MessageDirectionId = CodeID from Lookup_Generic_Code where CodeTypeID = 24 and Label = 'Inbound'
			select @ThreadPopulationId = CodeID from Lookup_Generic_Code where CodeTypeID = 20 and Label = 'Member'
			select @PlanLinkStatusId = CodeID from Lookup_Generic_Code where CodeTypeID = 21 and Label = 'Received'
			select @MessageSenderTypeId = CodeID from Lookup_Generic_Code where CodeTypeID = 23 and Label = 'Member'

			Insert into dbo.[Message]
				(
					InternalThreadId,
					ClientAppId,
					ClientThreadId,
					ClientMessageId,
					TopicId,
					ThreadPopulationId,
					SenderTypeId,
					PLMsgStatusId,
					MessageDirectionId,
					CreatedDate,
					CreatedBy,
					IsActive
				)
			values
				(
					@InternalThreadId,
					@ClientAppId,
					@ClientThreadId,
					@ClientMessageId,
					@TopicId,
					@ThreadPopulationId,
					@MessageSenderTypeId,
					@PlanLinkStatusId,
					@MessageDirectionId,
					@CreatedDate,
					'Member',
					@IsActive
				);

			set @NewMessageId = SCOPE_IDENTITY();
			set @OutputMessageId = @NewMessageId;


			--Third insert into Link_MessageMember table to establish relationship which member this message belongs to
			Insert into Link_MessageMember
				(
					MId,
					MVDID
				)
			values
				(
					@NewMessageId,
					@MVDID
				);


			--Insert into Inbound message table
			Insert into [dbo].[InboundMessage]
				(
					Message,
					CreatedDate
				)
			values
				(
					@Message,
					@CreatedDate
				)

			set @NewIMId = SCOPE_IDENTITY();


			--Insert into relationship table [dbo].[Link_InboundMessageMessage]
			Insert into [dbo].[Link_InboundMessageMessage]
				(
					MID,
					IMId
				)
			values
				(
					@NewMessageId,
					@NewIMId
				)


			--Create new Task for Inbound message
			EXECUTE [dbo].[Set_UserTask] 
			   @Title=@Topic
			  ,@Narrative=@Message
			  ,@MVDID=@MVDID
			  ,@CustomerId=16
			  ,@ProductId=2
			  ,@Author='System'
			  ,@Owner=@Owner        
			  ,@CreatedDate=@CreatedDate
			  ,@DueDate=@DueDate
			  ,@TaskStatus='New'
			  ,@TaskPriority='High'
			  ,@TaskType='Messaging'
			  ,@IsDelete = 0
			  ,@NewTaskId = @NewTaskId OUTPUT


			--Insert into [dbo].[Link_MessageTask]
			Insert into [dbo].[Link_MessageTask]
				(
					[MId],
					[TaskId]
				)
			values
				(
					@NewMessageId,
					@NewTaskId
				)

			select @NoteTypeId = CodeID from Lookup_Generic_Code where CodeTypeID = 5 and Label = 'Message'

			--Insert into Note for message
			exec dbo.uspInsertMessageNote
				@NoteTypeId = @NoteTypeId,
				@NoteType = 'Message',
				@MessageId = @NewMessageId,
				@Note = @Note,
				@CreatedBy = 'Member',
				@CreatedDate = @CreatedDate,
				@UpdatedBy = null,
				@UpdatedDate = null,
				@IsDeleted = 0,
				@IsActive = 1,
				@MessageNoteId = @NewMessageNoteId
		COMMIT
	END TRY
	BEGIN CATCH
	    THROW 
		ROLLBACK
	END CATCH
END