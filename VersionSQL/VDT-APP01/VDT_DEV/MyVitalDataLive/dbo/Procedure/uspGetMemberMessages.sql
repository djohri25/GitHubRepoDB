/****** Object:  Procedure [dbo].[uspGetMemberMessages]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		dpatel
-- Create date: 04/28/2020
-- Description:	<Description,,>
-- Example: exec uspGetMemberMessages @MVDID = '1690E46DC455A995F83F'
-- =============================================
CREATE PROCEDURE [dbo].[uspGetMemberMessages] 
	@MVDID varchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	declare @MessageTypeId int, 
			@BroadcastTypeId int;

	select @MessageTypeId = CodeID
	from Lookup_Generic_Code 
	where CodeTypeID = 29 
		and Label = 'Messaging'

	select @BroadcastTypeId = CodeID
	from Lookup_Generic_Code 
	where CodeTypeID = 29 
		and Label = 'Broadcast'

    select
		lmmr.MVDID,
		m.Id as 'MessageId',
		m.ClientAppId,
		m.InternalThreadId,
		m.ClientThreadId,
		m.ClientMessageId,
		m.TopicId,
		lgcg.CodeGuid as TopicGuid,
		(select Label_Desc from Lookup_Generic_Code where CodeID = m.TopicId) as Topic,
		NULL as 'Subject',
		CONCAT(Isnull(om.[Message], ''), isnull(im.[Message],'')) as 'Message',
		m.ThreadPopulationId,
		m.CreatedDate,
		m.CreatedBy,
		om.OutgoingStatusId,
		m.PLMsgStatusId as 'PlanLinkStatusId',
		m.SenderTypeId as 'MessageSenderTypeId',
		m.MessageDirectionId,
		NULL as 'MbrBroadcastStatusId',
		lmt.TaskId,
		m.IsActive,
		(select [Id],[MessageTypeId],[MessageEntityId],[Title],[Url],[CreatedBy],[CreatedDate]
		from MessageLink
		where [MessageTypeId] = @MessageTypeId 
			and [MessageEntityId] = m.Id
		FOR JSON AUTO) AS 'MessageLinks'
	from Link_MessageMember lmmr
	join dbo.[Message] m  on m.Id = lmmr.MId 
	left join Link_OutboundMessageMessage lomm on m.Id = lomm.MId
	left join OutboundMessage om on lomm.OMId = om.Id
	left join Link_InboundMessageMessage limm on m.Id = limm.MId
	left join InboundMessage im on limm.IMId = im.Id
	left join Link_MessageTask lmt on m.Id = lmt.MId
	left join LookupGenericCodeGUID lgcg on m.TopicId = lgcg.CodeId
	where lmmr.MVDID = @MVDID
		and ISNULL(m.IsActive, 0) = 1
	union
	select
		lbm.MVDID,
		ba.Id as 'MessageId',
		ba.ClientAppId,
		-99 as 'InternalThreadId',
		NULL as 'ClientThreadId',
		ba.ClientBroadcastId as ClientMessageId,
		ba.TopicId,
		lgcg.CodeGuid as TopicGuid,
		(select Label_Desc from Lookup_Generic_Code where CodeID = ba.TopicId) as Topic,
		ba.[Subject],
		Isnull(om.[Message], '') as 'Message',
		ba.ThreadPopulationId,
		ba.CreatedDate,
		ba.CreatedBy,
		om.OutgoingStatusId,
		ba.BroadcastStatusId as 'PlanLinkStatusId',
		(select CodeID from Lookup_Generic_Code where CodeTypeID = 23 and Label = 'PlanLinkUser') as 'MessageSenderTypeId',
		(select CodeID from Lookup_Generic_Code where CodeTypeID = 24 and Label = 'Outbound') as 'MessageDirectionId',
		lbm.BroadcastStatusId as 'MbrBroadcastStatusId',
		NULL as 'TaskId',
		ba.IsActive,
		(
			select [Id],[MessageTypeId],[MessageEntityId],[Title],[Url],[CreatedBy],[CreatedDate]
			from MessageLink
			where [MessageTypeId] = @BroadcastTypeId 
				and [MessageEntityId] = ba.Id
			FOR JSON AUTO
		) AS 'MessageLinks'
	from Link_BroadcastMember lbm
	join BroadcastAlert ba on lbm.BAId = ba.Id
	left join Link_OutboundMessageBroadcast lomb on ba.Id = lomb.BAId
	left join OutboundMessage om on lomb.OMId = om.Id
	left join LookupGenericCodeGUID lgcg on ba.TopicId = lgcg.CodeId
	where lbm.MVDID = @MVDID
		and ISNULL(ba.IsActive, 0) = 1

END