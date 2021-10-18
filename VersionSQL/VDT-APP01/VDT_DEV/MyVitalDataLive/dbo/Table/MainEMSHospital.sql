/****** Object:  Table [dbo].[MainEMSHospital]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[MainEMSHospital](
	[ID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
	[Address] [nvarchar](50) NULL,
	[City] [nvarchar](50) NULL,
	[State] [nvarchar](50) NULL,
	[Zip] [nchar](10) NULL,
	[ContactName] [nvarchar](50) NOT NULL,
	[ContactEmail] [nvarchar](500) NOT NULL,
	[ContactPhone] [nvarchar](10) NULL,
	[Website] [nvarchar](50) NULL,
	[IP] [nvarchar](20) NOT NULL,
	[ApprovedDate] [datetime] NULL,
	[Active] [bit] NULL,
	[CredentialsRequired] [bit] NULL,
	[AutoApprove] [bit] NULL,
	[Modified] [datetime] NULL,
	[Created] [datetime] NULL,
	[MinorsAge] [int] NULL,
	[NPI] [varchar](10) NULL,
	[RestrictedEmailDomains] [varchar](500) NULL,
	[RequiresDetailConfirmation] [bit] NOT NULL,
	[Category] [varchar](50) NULL,
 CONSTRAINT [PK_MainEMSHospital_1] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[MainEMSHospital] ADD  CONSTRAINT [DF_MainEMSHospital_Active]  DEFAULT ((0)) FOR [Active]
ALTER TABLE [dbo].[MainEMSHospital] ADD  CONSTRAINT [DF_MainEMSHospital_CredentialsRequired]  DEFAULT ((1)) FOR [CredentialsRequired]
ALTER TABLE [dbo].[MainEMSHospital] ADD  CONSTRAINT [DF_MainEMSHospital_AutoApprove]  DEFAULT ((0)) FOR [AutoApprove]
ALTER TABLE [dbo].[MainEMSHospital] ADD  CONSTRAINT [DF_MainEMSHospital_Created]  DEFAULT (getutcdate()) FOR [Created]
ALTER TABLE [dbo].[MainEMSHospital] ADD  CONSTRAINT [DF_MainEMSHospital_MinorsAge]  DEFAULT ((0)) FOR [MinorsAge]
ALTER TABLE [dbo].[MainEMSHospital] ADD  CONSTRAINT [DF_MainEMSHospital_RequireDetailConfirmation]  DEFAULT ((1)) FOR [RequiresDetailConfirmation]
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-- =============================================
-- Author:		SW
-- Create date: 5/28/2008
-- Description:	Send notification that a new registration
--		request has been submitted
-- =============================================
CREATE TRIGGER [dbo].[MainEMSHospital_SENDNOTIFICATION] 
   ON  [dbo].[MainEMSHospital]
   AFTER INSERT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	declare	@Name varchar(50),
		@Address varchar(50),
		@City varchar(50),
		@State varchar(50),
		@Zip varchar(10),
		@ContactName varchar(50),
		@ContactEmail varchar(50),
		@ContactPhone varchar(10),
		@Website varchar(50),
		@IP varchar(20),
		@Active bit

	IF ((SELECT COUNT(*) FROM INSERTED) > 0)
	BEGIN
		SELECT @Name=Name, @Address=Address, @City=City, @State=State, @Zip=Zip, @ContactName=ContactName, 
			@ContactEmail=ContactEmail, @ContactPhone=ContactPhone, @Website=Website, @IP=IP, @Active = Active
		FROM INSERTED

		-- Send email only when the request comes from the HospitalRegistration page
		-- or from MVD Admin too when @active argument is 0
		if(@Active is null or @active=0 )
		begin
			DECLARE	@MailBody varchar(max), @RecipientEmail varchar(1000), @messageSubject varchar(60)
			declare @DBName  varchar(50)
			
			set @DBName = db_name()

			if( @DBName = 'MyVitalDataLive')
			begin
				select @messageSubject = 'MyVitalData Hospital Registration Request',		
					@RecipientEmail='esicard@vitaldatatech.com'
			end
			if( @DBName = 'MyVitalDataDemo')
			begin
				select @messageSubject = 'DEMO: MyVitalData Hospital Registration Request',		
					@RecipientEmail='qa@vitaldatatech.com'		
			end
			else if(@DBName = 'MyVitalDataTest1')
			begin
				select @messageSubject = 'TEST_1: MyVitalData Hospital Registration Request',		
					@RecipientEmail='qa@vitaldatatech.com'				
			end
			else if(@DBName = 'MyVitalDataTest2')
			begin
				select @messageSubject = 'TEST_2: MyVitalData Hospital Registration Request',		
					@RecipientEmail='qa@vitaldatatech.com'				
			end
			else if(@DBName = 'MyVitalDataDev')
			begin
				select @messageSubject = 'DEV: MyVitalData Hospital Registration Request',		
					@RecipientEmail='qa@vitaldatatech.com'				
			end
			else
			begin
				select @messageSubject = 'MyVitalData Hospital Registration Request',		
					@RecipientEmail='qa@vitaldatatech.com'		
			end



			SET @MailBody = 'Dear MyVitalData Administrator,' + nchar(13) + nchar(10)		
			SET @MailBody = @MailBody + nchar(13) + nchar(10)
			SET @MailBody = @MailBody + 'This email is to inform you that '

			SET @MailBody = @MailBody + 'a new request from a hospital has been submitted and the request needs to be registered into MyVitalData system.'+ nchar(13) + nchar(10)
			SET @MailBody = @MailBody + nchar(13) + nchar(10)
			SET @MailBody = @MailBody + 'Hospital/Provider Name: ' + @Name + nchar(13) + nchar(10)
			SET @MailBody = @MailBody + 'Address: ' + @Address +  nchar(13) + nchar(10)		
			SET @MailBody = @MailBody + 'City: ' + @City +  nchar(13) + nchar(10)		
			SET @MailBody = @MailBody + 'State: ' + @State +  nchar(13) + nchar(10)		
			SET @MailBody = @MailBody + 'Zip: ' + @Zip +  nchar(13) + nchar(10)		
			SET @MailBody = @MailBody + 'Contact Name: ' + @ContactName +  nchar(13) + nchar(10)		
			SET @MailBody = @MailBody + 'Contact Email: ' + @ContactEmail +  nchar(13) + nchar(10)		
			SET @MailBody = @MailBody + 'Contact Phone: ' + @ContactPhone +  nchar(13) + nchar(10)		
			SET @MailBody = @MailBody + 'Website: ' + @Website +  nchar(13) + nchar(10)		
			SET @MailBody = @MailBody + 'IP: ' + @IP +  nchar(13) + nchar(10)		
			SET @MailBody = @MailBody + nchar(13) + nchar(10)
			SET @MailBody = @MailBody + 'Thank you' + nchar(13) + nchar(10)				

			EXEC msdb.dbo.sp_send_dbmail @recipients = @RecipientEmail, @profile_name = 'VD-APP01', @body = @MailBody, @subject = @MessageSubject
		end
	END
END

ALTER TABLE [dbo].[MainEMSHospital] ENABLE TRIGGER [MainEMSHospital_SENDNOTIFICATION]