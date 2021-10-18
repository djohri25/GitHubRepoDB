/****** Object:  Procedure [dbo].[SendMailOnMVD_RecordAccess]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 01/14/2008
-- Description:	Sends email to the primary owner of 
--		MyVitalData account notifying about the access 
--		of the profile
-- =============================================
CREATE PROCEDURE [dbo].[SendMailOnMVD_RecordAccess]
	@RecipientEmail varchar(50),
	@RecipentFName varchar(50),
	@RecipentLName varchar(50),
	@MVDID varchar(30),
	@ProfileOwnerFName varchar(50),
	@ProfileOwnerLName varchar(50),
	@IsPrimary bit,
	@Date varchar(50),
	@UserAccessed varchar(50),
	@AppAccessed varchar(100),
	@ChiefComplaint varchar(100),
	@EMSNote varchar(1000)
AS
BEGIN
	SET NOCOUNT ON;
	declare @mvdSupport varchar(50), @messageSubject varchar(50);
	declare @notificationType varchar(50)

	set @mvdSupport = 'mvd.support@vitaldatatech.com';

	if(db_name() = 'MyVitalDataDemo')
	begin
		set @messageSubject = 'DEMO: MyVitalData record access alert'		
	end
	else if(db_name() = 'MyVitalDataTest1')
	begin
		set @messageSubject = 'TEST_1 TEST: MyVitalData record access alert'		
	end
	else if(db_name() = 'MyVitalDataTest2')
	begin
		set @messageSubject = 'TEST_2 TEST: MyVitalData record access alert'		
	end
	else if(db_name() = 'MyVitalDataDev')
	begin
		set @messageSubject = 'DEV TEST: MyVitalData record access alert'		
	end
	else
	begin
		set @messageSubject = 'MyVitalData record access alert'
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

		SET @MailBody = @MailBody + 'Dear ' + isnull(@RecipentFName,'') + ',' + nchar(13) + nchar(10)		
		SET @MailBody = @MailBody + nchar(13) + nchar(10)
		SET @MailBody = @MailBody + 'This email is to inform you that '

		if(@IsPrimary = '1')
		begin
			SET @MailBody = @MailBody + 'your MyVitalData account '
			set @notificationType = 'Owner'
		end
		else
		begin
			SET @MailBody = @MailBody + 'the account of ' + isnull(@ProfileOwnerFName,'') + ' ' + isnull(@ProfileOwnerLName,'') + ' ';		
			set @notificationType = 'Contact'
		end

		SET @MailBody = @MailBody + '(MVD#: ' + @MVDID + ') has been accessed.' + nchar(13) + nchar(10)
		SET @MailBody = @MailBody + 'Access date: ' + @Date + ' EST' + nchar(13) + nchar(10)		
		SET @MailBody = @MailBody + nchar(13) + nchar(10)		
		--SET @MailBody = @MailBody + 'By: ' + @UserAccessed +  nchar(13) + nchar(10)		
		SET @MailBody = @MailBody + 'At: ' + isnull(@AppAccessed,'') +  nchar(13) + nchar(10)	
		SET @MailBody = @MailBody + nchar(13) + nchar(10)		
		
		SET @MailBody = @MailBody + nchar(13) + nchar(10)
		SET @MailBody = @MailBody + 'If you did not authorize the access of this account, please contact MyVitalData customer support at 888/MVD-DATA (683-3292).' + nchar(13) + nchar(10)	
		SET @MailBody = @MailBody + nchar(13) + nchar(10)
		SET @MailBody = @MailBody + 'Sincerely,' + nchar(13) + nchar(10)		
		SET @MailBody = @MailBody + nchar(13) + nchar(10)
		SET @MailBody = @MailBody + 'MyVitalData.com' + nchar(13) + nchar(10)		

-- TO DO WHEN SQL SERVER MAIL ENABLED

		--EXEC msdb.dbo.sp_send_dbmail @recipients = @RecipientEmail, 
		--	@blind_copy_recipients = @mvdSupport,
		--	@body = @MailBody, 
		--	@subject = @messageSubject

		-- Log emails sent
		insert into MVD_AccessNotifSent (RecipientEmail,RecipientFName,RecipientLName,
			Subject,Body,Type)
		values(@RecipientEmail, @RecipentFName, @RecipentLName, @messageSubject, @MailBody, @notificationType)
	END
END