/****** Object:  Procedure [dbo].[uspInsertBroadcastAlert]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		dpatel
-- Create date: 05/25/2020
-- Description:	Inserts broadcast alert record and related meta-data.
------------------------------------------------
-- 10/25/2020	dpatel	Updated proc to save broadcast link(s).
-- =============================================
CREATE PROCEDURE [dbo].[uspInsertBroadcastAlert]
	@Id bigint = null,
	@CustomerId int,
	@ClientAppId int,
	@ClientBroadcastId uniqueidentifier = null,
	@TopicId int,
	@ThreadPopulationId int,
	@ReferralReason varchar(250) = null,
	@Subject varchar(250),
	@From varchar(150),
	@Message varchar(max),
	@CreatedDate datetime,
	@CreatedBy varchar(100),
	@IsActive bit,
	@MessageLinks [dbo].[udtMessageLink] readonly,
	@BroadcastPopulation [dbo].[BroadcastPopulation] readonly,
	@NewBroadcastId bigint output
	--BroadcastPopulation User-Defined-Type for list of members that should be included in broadcast population. It will be included once web-api is done.
AS
BEGIN

	BEGIN TRY
		BEGIN TRANSACTION

			-- SET NOCOUNT ON added to prevent extra result sets from
			-- interfering with SELECT statements.
			SET NOCOUNT ON;
		
			Declare @new_OMId bigint, 
					@OutgoingStatusId int, 
					@allMemberBrdPopId int, 
					@NoteTypeId int, 
					@Note varchar(max),
					@MbrBroadcastStatusId int,
					@broadcastMemberCount int,
					@NewBroadcastNoteId bigint,
					@MsgDirectionId int,
					@BrodcastStatusId int,
					@MessageTypeId int,
					@WasBroadcastPopulationInput bit = 0;	--This is list of all registered members on Mobile APP.
			
			--Get Broadcast population		
			drop table if exists #BroadcastPopulation
		
			create table #BroadcastPopulation
			(
				MVDID varchar(50)
			)

			select @allMemberBrdPopId = CodeID from Lookup_Generic_Code where CodeTypeID = 20 and Label = 'AllMbr';

			if exists (select top 1 MVDID from @BroadcastPopulation)
				begin
					--Only registered mobile members will be part of broadcast population. Currently only implemented for "All members" selection.
					--TODO: Implement combined approach for all possible broadcast population selection.
					set @WasBroadcastPopulationInput = 1;

					Insert into #BroadcastPopulation
					select distinct MVDID
					from @BroadcastPopulation
				end
			else
				begin
					if @allMemberBrdPopId != @ThreadPopulationId
						begin
							--Broadcast population is determined by PlanLink. For broadcast population selection except "All members".
							Insert into #BroadcastPopulation
							exec uspGetBroadcastPopulation @ThreadPopulationId = @ThreadPopulationId, @ReferralReason = @ReferralReason, @CustomerId = @CustomerId
						end
				end

			select @broadcastMemberCount = COUNT(MVDID) from #BroadcastPopulation

			--No member then return
			if ISNULL(@broadcastMemberCount,0) = 0
				begin
					set @NewBroadcastId = -99;
					COMMIT
					return;
				end
		
			select @MsgDirectionId = CodeID
			from Lookup_Generic_Code where CodeTypeID = 24 and Label = 'Outbound'

			select @BrodcastStatusId = CodeID
			from Lookup_Generic_Code where CodeTypeID = 21 and Label = 'Queued'

			select @OutgoingStatusId = CodeID
			from Lookup_Generic_Code where CodeTypeID = 22 and Label = 'Queued'
		
			select @MbrBroadcastStatusId = CodeID
			from Lookup_Generic_Code where CodeTypeID = 28 and Label = 'Queued'

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
		
			Insert into BroadcastAlert
				(
					ClientAppId,
					ClientBroadcastId,
					TopicId,
					ThreadPopulationId,
					ReferralReason,
					[Subject],
					[From],
					[MessageDirectionId],
					[BroadcastStatusId],
					CreatedDate,
					CreatedBy,
					IsActive
				)
			values
				(
					@ClientAppId,
					@ClientBroadcastId,
					@TopicId,
					@ThreadPopulationId,
					@ReferralReason,
					@Subject,
					@From,
					@MsgDirectionId,
					@BrodcastStatusId,
					@CreatedDate,
					@CreatedBy,
					@IsActive
				);
		
			set @NewBroadcastId = SCOPE_IDENTITY();
		
			Insert into Link_OutboundMessageBroadcast
				(
					OMId,
					BAId
				)
			values
				(
					@new_OMId,
					@NewBroadcastId
				)
		
			if @WasBroadcastPopulationInput = 1
				begin
					Insert into Link_BroadcastMember 
						(
							BAId
							,MVDID
							,BroadcastStatusId
							,IsMemberMobileRegistered
						)
					select @NewBroadcastId
							,MVDID
							,@MbrBroadcastStatusId
							,1
					from #BroadcastPopulation		
				end
			else
				begin
					Insert into Link_BroadcastMember 
						(
							BAId
							,MVDID
							,BroadcastStatusId
							,IsMemberMobileRegistered
						)
					select @NewBroadcastId
							,MVDID
							,@MbrBroadcastStatusId
							,0
					from #BroadcastPopulation	
				end
			

			select @MessageTypeId = CodeID from Lookup_Generic_Code where CodeTypeID = 29 and Label = 'Broadcast'

			Insert into MessageLink
			select @MessageTypeId, @NewBroadcastId, Title, Url, @CreatedBy, @CreatedDate
			from @MessageLinks
		
		
			select @NoteTypeId = CodeID from Lookup_Generic_Code where CodeTypeID = 5 and Label = 'Broadcast'
			set @Note = 'New broadcast sent for ' + @Subject
		
			exec dbo.uspInsertMessageNote
				@NoteTypeId = @NoteTypeId,
				@NoteType = 'Broadcast',
				@MessageId = @NewBroadcastId,
				@Note = @Note,
				@CreatedBy = @CreatedBy,
				@CreatedDate = @CreatedDate,
				@UpdatedBy = null,
				@UpdatedDate = null,
				@IsDeleted = 0,
				@IsActive = 1,
				@MessageNoteId = @NewBroadcastNoteId

		COMMIT
	END TRY
	BEGIN CATCH
	    THROW 
		ROLLBACK
	END CATCH
END