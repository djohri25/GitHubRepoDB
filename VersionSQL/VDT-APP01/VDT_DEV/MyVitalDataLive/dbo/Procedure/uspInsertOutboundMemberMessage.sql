/****** Object:  Procedure [dbo].[uspInsertOutboundMemberMessage]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		dpatel
-- Create date: 04/23/2020
-- Description:	Insert new/reply message data for outboud process.
------------------------------------------------
--	10/21/2020	dpatel	Updated PROC to add MessageLink(s) to MessageLink table for new or reply message.
-- =============================================
CREATE PROCEDURE [dbo].[uspInsertOutboundMemberMessage]
	@MessageId bigint = null,
	@InternalThreadId bigint = null,
	@MVDID varchar(50),
	@ClientAppId int,
	@ClientThreadId uniqueidentifier = null,
	@ClientMessageId uniqueidentifier = null,
	@TopicId int,
	@Message varchar(max),
	@ThreadPopulationId int,
	@CreatedDate datetime,
	@CreatedBy varchar(250),
	@OutgoingStatusId int,
	@PlanLinkStatusId int,
	@MessageSenderTypeId int,
	@MessageDirectionId int,
	@IsActive bit,
	@MessageLinks [dbo].[udtMessageLink] readonly,
	@NewMessageId bigint output,
	@NewInternalThreadId bigint output,
	@NewMessageNoteId bigint = null output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	BEGIN TRY
		BEGIN TRANSACTION
		
			Declare @new_messageId bigint, 
					@new_OMId bigint, 
					@NoteTypeId int, 
					@Note varchar(max), 
					@Topic varchar(100),
					@msgCountWithNoCTId int,
					@existingThreadOwner varchar(200),
					@MessageTypeId int;
			

			select @Topic = Label_Desc  from Lookup_Generic_Code where CodeID = @TopicId
			set @Note = case 
							when @Topic is null then '' 
							else @Topic + ' | '
						end;
		
		    --First Insert record into OutboundMessage table
			Insert into OutboundMessage
				(
					[Message],
					OutgoingStatusId,
					TopicId
				)
			values
				(
					@Message,
					@OutgoingStatusId,
					@TopicId
				);
		
			set @new_OMId = SCOPE_IDENTITY();
		
			if @InternalThreadId is null
				begin
					select @InternalThreadId = max(m.InternalThreadId) 
					from dbo.[Message] m
					join dbo.Link_MessageMember lmm on m.Id = lmm.MId and lmm.MVDID = @MVDID;
		
					if @InternalThreadId is null
						begin
							set @InternalThreadId = 1;
						end
					else
						begin
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
						@CreatedBy
					)
		
					set @Note = CONCAT(@Note,'New message sent')
				end
			else
				begin
					--Update already existing message records with null ClientThreadId with ThreadId from MobileAPI.
					if @ClientThreadId is not null
						begin
							select @msgCountWithNoCTId = count(Id)
							from dbo.[Message]
							where InternalThreadId = @InternalThreadId and ClientThreadId is null
		
							if ISNULL(@msgCountWithNoCTId, 0) > 0
								begin
									Update dbo.[Message] set ClientThreadId = @ClientThreadId where InternalThreadId = @InternalThreadId
								end
						end

					--Find existing thread owner from ThreadActiveOwner table.
					select @existingThreadOwner = ActiveOwner
					from ThreadActiveOwner
					where MVDID = @MVDID 
						and InternalThreadId = @InternalThreadId

					--update existing thread owner to user who is replying to the message
					if @existingThreadOwner = 'Clinical Support' and @CreatedBy != 'Clinical Support'
						begin
							update ThreadActiveOwner
							set ActiveOwner = @CreatedBy
							where MVDID = @MVDID 
								and InternalThreadId = @InternalThreadId
						end
		
					set @Note = CONCAT(@Note,'Reply message sent')
				end
		
			--Second Insert record into Message table
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
					@CreatedBy,
					@IsActive
				);
		
			set @new_messageId = SCOPE_IDENTITY();
		
			--Third insert into Link_MessageMember table to establish relationship which member this message belongs to
			Insert into Link_MessageMember
				(
					MId,
					MVDID
				)
			values
				(
					@new_messageId,
					@MVDID
				);
		
			--Forth insert into Link_OutboundMessageMessage table to keep link of temporary OutboundMessage and permanent Message record
			Insert into [dbo].[Link_OutboundMessageMessage]
				(
					OMId,
					MId
				)
			values
				(
					@new_OMId,
					@new_messageId
				);
		
			set @NewMessageId = @new_messageId
			set @NewInternalThreadId = @InternalThreadId

			select @MessageTypeId = CodeID from Lookup_Generic_Code where CodeTypeID = 29 and Label = 'Messaging'

			Insert into MessageLink
			select @MessageTypeId, @new_messageId, Title, Url, @CreatedBy, @CreatedDate
			from @MessageLinks
		
			select @NoteTypeId = CodeID from Lookup_Generic_Code where CodeTypeID = 5 and Label = 'Message'
		
			exec dbo.uspInsertMessageNote
				@NoteTypeId = @NoteTypeId,
				@NoteType = 'Message',
				@MessageId = @NewMessageId,
				@Note = @Note,
				@CreatedBy = @CreatedBy,
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