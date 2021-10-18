/****** Object:  Procedure [dbo].[Upd_HPOutgoingAlert]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		sw
-- Create date: 3/16/2009
-- Description:	Updates Health Plan outgoing alert record
-- 06/08/2017	Marc De Luca	Changed @recipients
-- =============================================
CREATE PROCEDURE [dbo].[Upd_HPOutgoingAlert] 
	@RecordID int,
	@SentDate datetime,
	@Status varchar(50)
AS
BEGIN
	SET NOCOUNT ON;

	Update SendHP_Alert set sentDate = @SentDate, status = @Status
		where ID = @RecordID

	if( isnull(@Status,'') <> 'OK')
	begin
		-- Send notification when failed
		declare @msgBody varchar(1000)
		
		set @msgBody = db_name() + nchar(13) + nchar(10)
		set @msgBody = @msgBody + 'Alert failed with status: ' + @Status + nchar(13) + nchar(10)
		set @msgBody = @msgBody + 'Record ID: ' + convert(varchar,@RecordID,20) + nchar(13) + nchar(10)


		EXEC msdb.dbo.sp_send_dbmail 
		@recipients = 'alerts@vitaldatatech.com', 
		@profile_name = 'VD-APP01',
		@body = @msgBody , 
		@subject = 'HPM alert unsuccessful'
	end
END