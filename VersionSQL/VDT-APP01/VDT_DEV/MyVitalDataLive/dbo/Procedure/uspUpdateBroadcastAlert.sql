/****** Object:  Procedure [dbo].[uspUpdateBroadcastAlert]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		dpatel
-- Create date: 09/23/2020
-- Description:	update broadcast alert record and related meta-data.
-- =============================================
CREATE PROCEDURE [dbo].[uspUpdateBroadcastAlert]
	@Id bigint,
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
	@IsSent bit = null,
	@BroadcastPopulation [dbo].[BroadcastPopulation] readonly
AS
BEGIN
	if @Id is not null
		begin
			--UPDATE [dbo].[BroadcastAlert]
			--SET 
			--   [ClientBroadcastId] = @ClientBroadcastId
			--   ,[IsActive] = @IsActive
			--WHERE Id = @Id

			declare @sentLkupId int,
					@mbrNotRegLkupId int,
					@OutgoingStatusId int,
					@BrodcastStatusId int;
			
			--This block will only run first time when Broadcast is successfully sent out to MobileAPI
			if ISNULL(@IsSent, 0) = 1
				begin
					select @OutgoingStatusId = CodeID from Lookup_Generic_Code where CodeTypeID = 22 and Label = 'Sent'

					select @BrodcastStatusId = CodeID from Lookup_Generic_Code where CodeTypeID = 21 and Label = 'Sent'
					
					--First Update record into OutboundMessage table
					Update om
					set om.OutgoingStatusId = @OutgoingStatusId
					from OutboundMessage om
					join Link_OutboundMessageBroadcast lomb on om.Id = lomb.OMId
					where lomb.BAId = @Id

					--Update Broadcast alert record
					Update BroadcastAlert
					set [BroadcastStatusId] = @BrodcastStatusId
						,[ClientBroadcastId] = @ClientBroadcastId
						,[IsActive] = @IsActive
					where Id = @Id
				end
			
			if ISNULL(@IsSent, 0) = 0
				begin
					select @OutgoingStatusId = CodeID from Lookup_Generic_Code where CodeTypeID = 22 and Label = 'Errored'

					select @BrodcastStatusId = CodeID from Lookup_Generic_Code where CodeTypeID = 21 and Label = 'Failed'	--Currently setting it to failed when PlanLink API fails to deliver Broadcast. Change it to errored once we have background processing set-up working.
					
					--First Update record into OutboundMessage table
					Update om
					set om.OutgoingStatusId = @OutgoingStatusId
					from OutboundMessage om
					join Link_OutboundMessageBroadcast lomb on om.Id = lomb.OMId
					where lomb.BAId = @Id

					--Update Broadcast alert record
					Update BroadcastAlert
					set [BroadcastStatusId] = @BrodcastStatusId
						,[ClientBroadcastId] = @ClientBroadcastId
						,[IsActive] = @IsActive
					where Id = @Id
				end

			select @sentLkupId = CodeId from Lookup_Generic_Code where CodeTypeID = 28 and Label = 'Sent'
			select @mbrNotRegLkupId = CodeId from Lookup_Generic_Code where CodeTypeID = 28 and Label = 'MbrNotRegistered'
			--TODO: Once background processing is setup, we should introduce Errored and Failed status to flag each member's broadcast status appropriatly.

			Update lbm
			set lbm.[BroadcastStatusId] = case
												when ISNULL(bp.[IsMemberRegistered], 0) = 0 then @mbrNotRegLkupId
												else @sentLkupId
											end,
				lbm.IsMemberMobileRegistered = case 
													when ISNULL(bp.[IsMemberRegistered], 0) = 0 then 0
													when bp.[IsMemberRegistered] = 1 then 1
													else 0
												end
			from Link_BroadcastMember lbm
			join @BroadcastPopulation bp on lbm.MVDID = bp.MVDID and lbm.BAId = @Id
		end
end