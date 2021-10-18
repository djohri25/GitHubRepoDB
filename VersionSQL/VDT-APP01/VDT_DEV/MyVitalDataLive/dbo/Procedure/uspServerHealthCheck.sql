/****** Object:  Procedure [dbo].[uspServerHealthCheck]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE uspServerHealthCheck
AS
BEGIN

declare @dateHealth datetime = NULL
select @dateHealth = getdate()
IF (@dateHealth IS NOT NULL)
BEGIN
		EXEC [VD-RPT02].msdb.dbo.sp_send_dbmail 
		@profile_name = 'VD-RPT02',
		@from_address= 'no-reply@vitaldatatech.com',
		@recipients= 'djohri@vitaldatatech.com; snokku@vitaldatatech.com; ezanelli@vitaldatatech.com',
		@subject= '135 Server is UP and running', 
		@body='135 server is online', 
		@body_format='HTML'
END

END