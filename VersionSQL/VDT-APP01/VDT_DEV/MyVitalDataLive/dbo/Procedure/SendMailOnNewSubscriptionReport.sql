/****** Object:  Procedure [dbo].[SendMailOnNewSubscriptionReport]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 1/24/2010
-- Description:	Sends email to report subscriber that new report
--	has been generated
-- 06/08/2017	Marc De Luca	Changed @recipients
-- =============================================
CREATE PROCEDURE [dbo].[SendMailOnNewSubscriptionReport]
	@email varchar(50),
	@reportName varchar(50),
	@reportDate varchar(50)
AS
BEGIN
	SET NOCOUNT ON;

	declare @mvdSupport varchar(50), @messageSubject varchar(100), @dbname varchar(50)
	set @mvdSupport = 'alerts@vitaldatatech.com';

	set @reportName = dbo.Get_ReportNameByFilename(@reportName)

	set @messageSubject = ISNULL(dbo.Get_EmailPrefix(),'') + 'Subscription report "' + @reportName + '" executed on ' + @reportDate		

	IF LEN(isnull(@email,'')) > 0
	BEGIN
		DECLARE	@MailBody varchar(max)

		set @dbname = db_name()
		set @MailBody = ''

		SET @MailBody = @MailBody + 'Dear user,' + nchar(13) + nchar(10)		
		SET @MailBody = @MailBody + nchar(13) + nchar(10)
		SET @MailBody = @MailBody + 'You’re receiving this email because you have requested to receive MyVitalData report:' + nchar(13) + nchar(10)		
		SET @MailBody = @MailBody + nchar(13) + nchar(10)
		SET @MailBody = @MailBody + '"' + @reportName + '"' + nchar(13) + nchar(10)
		SET @MailBody = @MailBody + nchar(13) + nchar(10)
		SET @MailBody = @MailBody + 'You can access the report by logging in to the following website:';		
		SET @MailBody = @MailBody + nchar(13) + nchar(10)

		if(@dbname = 'MyVitalDataDemo')
		begin
			set @MailBody = @MailBody +  'http://demo.myvitaldata.com/demo/AdminLogin.aspx'		
		end
		else if(@dbname = 'MyVitalDataTest1')
		begin
			set @MailBody = @MailBody +  'http://test.myvitaldata.com/www1/AdminLogin.aspx'		
		end
		else if(@dbname = 'MyVitalDataTest2')
		begin
			set @MailBody = @MailBody +  'http://test.myvitaldata.com/www2/AdminLogin.aspx'		
		end
		else if(@dbname = 'MyVitalDataDev')
		begin
			set @MailBody = @MailBody +  'http://demo.myvitaldata.com/demo/AdminLogin.aspx'		
		end
		else if(@dbname = 'MyVitalDataLive')
		begin
			set @MailBody = @MailBody +  'https://www.myvitaldata.com/web/AdminLogin.aspx'		
		end

		SET @MailBody = @MailBody + nchar(13) + nchar(10) + nchar(13) + nchar(10)

		SET @MailBody = @MailBody + 'The report will be deleted from the MVD system within 14 days.  If you wish to keep the report longer than 14 days, please save the report to your system.' + nchar(13) + nchar(10)
		SET @MailBody = @MailBody + nchar(13) + nchar(10)
		SET @MailBody = @MailBody + 'If you no longer wish to receive the report or would like to modify the subscription, go to the Report Scheduler on MyVitalData, select the report above and delete/modify the existing subscription(s).' + nchar(13) + nchar(10)
		SET @MailBody = @MailBody + nchar(13) + nchar(10)
		SET @MailBody = @MailBody + 'Should you have any questions, please contact customer support at 888/MVD-DATA (683-3292).' + nchar(13) + nchar(10)
		SET @MailBody = @MailBody + nchar(13) + nchar(10)
		SET @MailBody = @MailBody + 'Sincerely,' + nchar(13) + nchar(10)		
		SET @MailBody = @MailBody + nchar(13) + nchar(10)
		SET @MailBody = @MailBody + 'MyVitalData.com' + nchar(13) + nchar(10)		
		
		EXEC msdb.dbo.sp_send_dbmail 
		@recipients = @email, 
		@profile_name = 'VD-APP01',
		@blind_copy_recipients = @mvdSupport,
		@body = @MailBody, 
		@subject = @messageSubject
	END

END