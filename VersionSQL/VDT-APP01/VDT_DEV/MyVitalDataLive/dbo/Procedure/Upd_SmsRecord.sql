/****** Object:  Procedure [dbo].[Upd_SmsRecord]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 7/16/2008
-- Description:	Updates SMS record
-- =============================================
CREATE PROCEDURE [dbo].[Upd_SmsRecord] 
	@RecordID int,
	@Modified datetime,
	@Status varchar(50),
	@StatusCode varchar(10),
	@TrackingTag varchar(30)
AS
BEGIN
	SET NOCOUNT ON;

	Update sendSMS set sentDate = @Modified, status = @Status, statusCode = @StatusCode,
			trackingTag = @TrackingTag
		where ID = @RecordID
END