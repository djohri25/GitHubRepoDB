/****** Object:  Procedure [dbo].[SendMailToHPAgent]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		sw
-- Create date: 10/7/2008
-- Description:	Sends email to Health Plan agent to 
--		notify that member record was accessed in
--		a health care facility
-- 06/08/2017	Marc De Luca	Changed @recipients
-- =============================================
CREATE PROCEDURE [dbo].[SendMailToHPAgent]
	@RecordAccessID int,
	@CustomerID int,
	@RecipientEmail varchar(50),
	@InsMemberId varchar(30),
	@MemberFName varchar(50),
	@MemberLName varchar(50),
	@Date varchar(50),
	@NPI varchar(50),
	@Facility varchar(50),		-- Name of the facility where the record was accessed
	@ChiefComplaint varchar(100),
	@EMSNote varchar(1000),
	@TriggerType varchar(50) = null,	-- What logic triggered this email e.g. Individual (assgnment), Rule
	@TriggerName varchar(50) = null	-- Name of the rule which resulted with that email (parameter is blank in case of Individual assignment)
AS
BEGIN
	SET NOCOUNT ON;

	declare @mvdSupport varchar(50), @messageSubject varchar(50);
	set @mvdSupport = 'alerts@vitaldatatech.com';

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


		-- FORWARD TO QA on test environments; ********** 
		if( db_name() != 'MyVitalDataLive' and db_name() != 'MyVitalDataDemo' )
		begin
			set @RecipientEmail = 'alerts@vitaldatatech.com'
		end


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

		SET @MailBody = @MailBody + 'Dear user,' + nchar(13) + nchar(10)		
		SET @MailBody = @MailBody + nchar(13) + nchar(10)
		SET @MailBody = @MailBody + 'This email is to inform you that '

		SET @MailBody = @MailBody + 'the account of ' + isnull(@MemberFName,'') + ' ' + isnull(@MemberLName,'') + ' ';		

		SET @MailBody = @MailBody + '(Insurance #: ' + isnull(@InsMemberId,'') + ') has been accessed:' + nchar(13) + nchar(10)
		SET @MailBody = @MailBody + 'Access date: ' + isnull(@Date,'') + ' EST' + nchar(13) + nchar(10)		
		SET @MailBody = @MailBody + nchar(13) + nchar(10)		
		SET @MailBody = @MailBody + 'At: ' + isnull(@Facility,'') +  nchar(13) + nchar(10)		

		-- Include in the email body only if fields valued
		if(len(isnull(@ChiefComplaint,'')) > 0)
		begin
			SET @MailBody = @MailBody + 'The chief complaint reported: ' + @ChiefComplaint + '. ' + nchar(13) + nchar(10)	
		end

		if(len(isnull(@EMSNote,'')) > 0)
		begin		
			SET @MailBody = @MailBody + 'Additional notes on visit: ' + @EMSNote + '. ' +  nchar(13) + nchar(10)	
		end

		if( @TriggerType = 'Individual')
		begin
			SET @MailBody = @MailBody + nchar(13) + nchar(10)		
			SET @MailBody = @MailBody + 'You received this notification as a result of individual assignment to this member.' +  nchar(13) + nchar(10)
		end
		else if( @TriggerType = 'Rule')
		begin
			SET @MailBody = @MailBody + nchar(13) + nchar(10)		
			SET @MailBody = @MailBody + 'You received this notification as a result of the following alerting rule: ' + @TriggerName +  nchar(13) + nchar(10)
		end

		SET @MailBody = @MailBody + nchar(13) + nchar(10)
		SET @MailBody = @MailBody + 'If you have any questions about the member, please contact MyVitalData customer support at 888/MVD-DATA (683-3292).' + nchar(13) + nchar(10)	
		SET @MailBody = @MailBody + nchar(13) + nchar(10)
		SET @MailBody = @MailBody + 'Sincerely,' + nchar(13) + nchar(10)		
		SET @MailBody = @MailBody + nchar(13) + nchar(10)
		SET @MailBody = @MailBody + 'MyVitalData.com' + nchar(13) + nchar(10)		
		
		EXEC msdb.dbo.sp_send_dbmail 
		@recipients = @RecipientEmail, 
		@profile_name = 'VD-APP01',
		@blind_copy_recipients = @mvdSupport,
		@body = @MailBody, 
		@subject = @messageSubject

		-- Log emails sent
		insert into MVD_AccessNotifSent (RecipientEmail,RecipientFName,RecipientLName,
			Subject,Body,Type)
		values(@RecipientEmail, '', '', @messageSubject, @MailBody, 'HPAgent')
	END

END