/****** Object:  Procedure [dbo].[SaveEngagementMessages]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		dpatel
-- Create date: 12/28/2016
-- Description:	This SP saves Engagement Messages to different table based on flag values in order to broadcast them to different applications
--				DeliveredToPCP is True --> Save message to MDMessage table.
--				DeliveredToMobile is True --> Save message to MObileMVDDev.Messages / MobileMVDLive.Messages
-- =============================================
CREATE PROCEDURE [dbo].[SaveEngagementMessages]
	@messages EngagementMessage readonly
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	Insert into [VD-APP01].[MobileMVDDev].[dbo].[Messages]
	select MVDID
			, MessageSubject
			, MessageSender
			, MessageDate
			, MessageText
			, null
			, CreatedDate
	from @messages
	where DeliveredToMobile is not null 
		and DeliveredToMobile = 1

	Insert into MDMessage
	select	TIN
			, MessageSubject
			, MessageText
			, MessageSender
			, CreatedDate
			, null
	from @messages
	where DeliveredToPCP is not null 
		and DeliveredToPCP = 1
    
END