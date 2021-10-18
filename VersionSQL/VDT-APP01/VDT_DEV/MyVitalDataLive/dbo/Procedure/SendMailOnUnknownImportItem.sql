/****** Object:  Procedure [dbo].[SendMailOnUnknownImportItem]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		sw
-- Create date: 01/14/2008
-- Description:	Sends email to system administrator
--	that one of the import lookup items cannot be found in MVD system
-- 06/08/2017	Marc De Luca	Changed @recipients
-- =============================================
CREATE PROCEDURE [dbo].[SendMailOnUnknownImportItem]
	@RecordId int,
	@MVDId varchar(15),
	@ItemCode varchar(50),
	@ItemType varchar(50),
	@Date varchar(50)
AS
BEGIN
	SET NOCOUNT ON;
	declare @RecipientEmail varchar(50), @messageSubject varchar(50);
	declare @notificationType varchar(50)

	set @RecipientEmail = 'alerts@vitaldatatech.com';

	if(db_name() = 'MyVitalDataDemo')
	begin
		set @messageSubject = 'FOR DEMO USE ONLY: Import Item Not Found'		
	end
	else if(db_name() = 'MyVitalDataTest1')
	begin
		set @messageSubject = 'TEST_1: Import Item Not Found'		
	end
	else if(db_name() = 'MyVitalDataTest2')
	begin
		set @messageSubject = 'TEST_2: Import Item Not Found'		
	end
	else if(db_name() = 'MyVitalDataDev')
	begin
		set @messageSubject = 'DEV: Import Item Not Found'		
	end
	else
	begin
		set @messageSubject = 'Import Item Not Found'
	end


	IF @RecipientEmail IS NOT NULL AND LEN(@RecipientEmail) > 0
	BEGIN
		DECLARE	@MailBody varchar(max)

		set @MailBody = ''

		if(db_name() = 'MyVitalDataDemo')
		begin
			SET @MailBody = 'FOR DEMO USE ONLY' + nchar(13) + nchar(10)	+ nchar(13) + nchar(10)	
		end		
		else if(db_name() = 'MyVitalDataTest1')
		begin
			set @MailBody = '(TEST_1) FOR TEST USE ONLY' + nchar(13) + nchar(10) + nchar(13) + nchar(10)			
		end
		else if(db_name() = 'MyVitalDataTest2')
		begin
			set @MailBody = '(TEST_2) FOR TEST USE ONLY' + nchar(13) + nchar(10) + nchar(13) + nchar(10)		
		end
		else if(db_name() = 'MyVitalDataDev')
		begin
			set @MailBody = '(DEV) FOR DEV USE ONLY' + nchar(13) + nchar(10) + nchar(13) + nchar(10)			
		end

		SET @MailBody = @MailBody + 'Dear Administrator' + ',' + nchar(13) + nchar(10)		
		SET @MailBody = @MailBody + nchar(13) + nchar(10)
		SET @MailBody = @MailBody + 'This email is to inform you that '
		SET @MailBody = @MailBody + 'there was an attempt to import item which could not be found in MVD system.' + nchar(13) + nchar(10) 
		SET @MailBody = @MailBody + nchar(13) + nchar(10)		
		SET @MailBody = @MailBody + 'Date: ' + isnull(@Date,'') + ' (UTC)' +  nchar(13) + nchar(10)	
		SET @MailBody = @MailBody + 'Claim Record ID: ' + isnull(convert(varchar,@RecordId,10),'') +  nchar(13) + nchar(10)	
		SET @MailBody = @MailBody + 'MVD ID: ' + isnull(@MVDId,'') +  nchar(13) + nchar(10)	
		SET @MailBody = @MailBody + 'Item Code: ' + isnull(@ItemCode,'') +  nchar(13) + nchar(10)	
		SET @MailBody = @MailBody + 'Item Item: ' + isnull(@ItemType,'') +  nchar(13) + nchar(10)	

		SET @MailBody = @MailBody + nchar(13) + nchar(10)		
		
		SET @MailBody = @MailBody + 'Sincerely,' + nchar(13) + nchar(10)		
		SET @MailBody = @MailBody + nchar(13) + nchar(10)
		SET @MailBody = @MailBody + 'MyVitalData.com' + nchar(13) + nchar(10)		
		
		EXEC msdb.dbo.sp_send_dbmail 
		@recipients = @RecipientEmail, 
		@profile_name = 'VD-APP01',
		@body = @MailBody, 
		@subject = @messageSubject

	END
END