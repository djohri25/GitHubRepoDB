/****** Object:  Procedure [dbo].[SendMailAccountSetupReminder]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 12/13/2010
-- Description:	Set reminder to MVD new customers to complete
--	new account form
-- 06/08/2017	Marc De Luca	Changed @recipients
-- =============================================
CREATE PROCEDURE [dbo].[SendMailAccountSetupReminder]
AS
BEGIN
	SET NOCOUNT ON;

    declare @ID int, @email varchar(50),@transactionID varchar(50), 
		@newAccountURL varchar(1000), @NoticeLimit datetime

	declare @temp table (ID int,email varchar(50),transactionID varchar(50), newAccountURL varchar(1000))

	declare @mvdSupport varchar(50), @messageSubject varchar(100), @dbname varchar(50),@MailBody varchar(max)

	select @mvdSupport = 'alerts@vitaldatatech.com',
		@NoticeLimit = DATEADD(minute,-10,getutcdate())     -- Send email if account wasn't created within 10 minutes

	set @messageSubject = ISNULL(dbo.Get_EmailPrefix(),'') + 'MyVitalData account setup is almost completed'

	update MVD_SubscriptionOrder set IsAccountCreated = 1
	where Email in(
			select email from AccountActivation where [Type] = 'A' and Delta = -1
		)

	insert into @temp (ID,email,transactionID,newAccountURL)
	select ID,email,transactionID,newAccountURL
	from MVD_SubscriptionOrder
	where IsAccountCreated = 0 and IsReminderEmailSent = 0 
		and ISNULL(email,'') <> '' and ISNULL(newAccountURL,'') <> '' 
		and Created < @NoticeLimit

	while exists(select top 1 ID from @temp)
	begin
		select top 1 @ID = ID,@email = email,@transactionID = transactionID,@newAccountURL = NewAccountURL
		from @temp

		set @MailBody = ''
		SET @MailBody = @MailBody + 'Dear MyVitalData Customer,' + nchar(13) + nchar(10)		
		SET @MailBody = @MailBody + nchar(13) + nchar(10)
		SET @MailBody = @MailBody + 'Your payment has been processed.' + nchar(13) + nchar(10)		
		SET @MailBody = @MailBody + nchar(13) + nchar(10)
		SET @MailBody = @MailBody + 'To complete creation of your account please click the link below and follow instructions on page:';		
		SET @MailBody = @MailBody + nchar(13) + nchar(10)
		SET @MailBody = @MailBody + @newAccountURL
		SET @MailBody = @MailBody + nchar(13) + nchar(10) + nchar(13) + nchar(10)
		SET @MailBody = @MailBody + 'For assistance please call 888-MVD-DATA (888-683-3282)'
		SET @MailBody = @MailBody + nchar(13) + nchar(10) + nchar(13) + nchar(10)
		SET @MailBody = @MailBody + 'Sincerely,' + nchar(13) + nchar(10)		
		SET @MailBody = @MailBody + 'MyVitalData.com'

		EXEC msdb.dbo.sp_send_dbmail 
		@recipients = @email, 
		@profile_name = 'VD-APP01',
		@blind_copy_recipients = @mvdSupport,
		@body = @MailBody, 
		@subject = @messageSubject
		
		update MVD_SubscriptionOrder set IsReminderEmailSent = 1 where ID = @ID
					
		delete from @temp where ID = @ID
	end
END