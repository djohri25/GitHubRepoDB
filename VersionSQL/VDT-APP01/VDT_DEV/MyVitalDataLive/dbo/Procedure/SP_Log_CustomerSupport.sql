/****** Object:  Procedure [dbo].[SP_Log_CustomerSupport]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		Sylvester Wyrzykowski
-- Create date: 01/31/2008
-- Description:	Records a customer support call
-- 06/08/2017	Marc De Luca	Changed @recipients
-- =============================================
CREATE PROCEDURE [dbo].[SP_Log_CustomerSupport]
	@Agent_FirstName varchar(15),
	@Agent_LastName varchar(15),
	@CallDate datetime,
	@CallTime varchar(15),
	@Category varchar(50),
	@Reporter_FirstName varchar(15),
	@Reporter_LastName varchar(15),
	@MVDId varchar(15),
	@Status varchar(15),
	@Comments varchar(250)	
AS
BEGIN
	SET NOCOUNT ON;

	insert into dbo.CustomerSupportLog(Agent_FirstName,Agent_LastName,CallDate,CallTime,Category,
		Reporter_FirstName,Reporter_LastName,MVDId,Status,Comments)
	values(@Agent_FirstName,@Agent_LastName,@CallDate,@CallTime,@Category,@Reporter_FirstName,
		@Reporter_LastName,@MVDId,@Status,@Comments)


	-- NOTIFY SYSTEM ADMIN
	declare @RecipientEmail varchar(50), @messageSubject varchar(50);
	declare @notificationType varchar(50), @categoryName varchar(50), @statusName varchar(50)

	Select @categoryName = CategoryName From LookupCS_Category where categoryID = @Category
	Select @statusName = StatusName From LookupCS_Status where StatusID = @Status

	set @RecipientEmail = 'alerts@vitaldatatech.com';

	if(db_name() = 'MyVitalDataDemo')
	begin
		set @messageSubject = 'FOR DEMO USE ONLY: Call Suppport'		
	end
	else if(db_name() = 'MyVitalDataTest1')
	begin
		set @messageSubject = 'TEST_1: Call Suppport'		
	end
	else if(db_name() = 'MyVitalDataTest2')
	begin
		set @messageSubject = 'TEST_2: Call Suppport'		
	end
	else if(db_name() = 'MyVitalDataDev')
	begin
		set @messageSubject = 'DEV: Call Suppport'		
	end
	else
	begin
		set @messageSubject = 'Call Suppport'
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
		SET @MailBody = @MailBody + 'This email is to inform you that new call support record was submitted.' + nchar(13) + nchar(10) 
		SET @MailBody = @MailBody + nchar(13) + nchar(10)		
		SET @MailBody = @MailBody + 'Agent First Name: ' + isnull(@Agent_FirstName,'') +  nchar(13) + nchar(10)	
		SET @MailBody = @MailBody + 'Agent Last Name: ' + isnull(@Agent_LastName,'') +  nchar(13) + nchar(10)	
		SET @MailBody = @MailBody + 'Call Date: ' + isnull(convert(varchar, @CallDate, 101),'') +  nchar(13) + nchar(10)	
		SET @MailBody = @MailBody + 'Call Time: ' + isnull(@CallTime,'') +  nchar(13) + nchar(10)	
		SET @MailBody = @MailBody + 'Support Category: ' + isnull(@categoryName,'') +  nchar(13) + nchar(10)	
		SET @MailBody = @MailBody + 'Reporter First Name: ' + isnull(@Reporter_FirstName,'') +  nchar(13) + nchar(10)	
		SET @MailBody = @MailBody + 'Reporter Last Name: ' + isnull(@Reporter_LastName,'') +  nchar(13) + nchar(10)	
		SET @MailBody = @MailBody + 'MVD ID: ' + isnull(@MVDId,'') +  nchar(13) + nchar(10)	
		SET @MailBody = @MailBody + 'Status: ' + isnull(@statusName,'') +  nchar(13) + nchar(10)	
		SET @MailBody = @MailBody + 'Comments: ' + isnull(@Comments,'') +  nchar(13) + nchar(10)	

		SET @MailBody = @MailBody + nchar(13) + nchar(10)				

		EXEC msdb.dbo.sp_send_dbmail 
		@recipients = @RecipientEmail, 
		@profile_name = 'VD-APP01',
		@body = @MailBody, 
		@subject = @messageSubject
	END
END