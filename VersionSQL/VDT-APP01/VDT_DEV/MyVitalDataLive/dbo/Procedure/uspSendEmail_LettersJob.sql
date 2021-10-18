/****** Object:  Procedure [dbo].[uspSendEmail_LettersJob]    Committed by VersionSQL https://www.versionsql.com ******/

/*=========================================================================================================:
author: Sunil Nokku
purpose: for email notification when Letters file are not sent

Changes
Luna        
date: 
Description: 

==============================================================================================================*/
--exec [dbo].[uspSendEmail_DailyJob] 
CREATE PROCEDURE [dbo].[uspSendEmail_LettersJob] 

AS

SET NOCOUNT ON

Declare
@recipientsStr varchar(255) = 'snokku@vitaldatatech.com;djohri@vitaldatatech.com;ezanelli@vitaldatatech.com;lzhang@vitaldatatech.com',
@EmailSubjectLine varchar(max) = 'TEST - VD-APP02 Letters are not sent to FTP',
@EmailBody varchar(max) ='Letters are not sent Today. Please check.'
                

EXEC [VD-RPT02].msdb.dbo.sp_send_dbmail @profile_name='VD-RPT02',
		@recipients = @recipientsStr,
		@importance = 'High',
		@body_format='HTML',
		@subject= @EmailSubjectLine,
		@body= @EmailBody