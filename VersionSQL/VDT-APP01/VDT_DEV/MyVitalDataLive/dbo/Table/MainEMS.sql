/****** Object:  Table [dbo].[MainEMS]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[MainEMS](
	[PrimaryKey] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[Email] [varchar](50) NULL,
	[Password] [varchar](50) NULL,
	[Active] [bit] NULL,
	[IsSpecial] [bit] NULL,
	[LastName] [varchar](50) NULL,
	[FirstName] [varchar](50) NULL,
	[Company] [varchar](50) NULL,
	[CompanyID] [int] NULL,
	[Phone] [varchar](10) NULL,
	[Address1] [varchar](50) NULL,
	[Address2] [varchar](50) NULL,
	[City] [varchar](50) NULL,
	[State] [varchar](5) NULL,
	[Zip] [varchar](10) NULL,
	[WebUrl] [varchar](100) NULL,
	[StateLicense] [varchar](30) NULL,
	[DriversLicense] [varchar](10) NULL,
	[SSN] [varchar](10) NULL,
	[Fax] [varchar](10) NULL,
	[CreationDate] [datetime] NULL,
	[ModifyDate] [datetime] NULL,
	[LastLogin] [datetime] NULL,
	[SecureQu] [int] NULL,
	[SecureAn] [varchar](50) NULL,
	[Username] [varchar](50) NULL,
	[SecurityQ1] [int] NULL,
	[SecurityA1] [varchar](50) NULL,
	[SecurityQ2] [int] NULL,
	[SecurityA2] [varchar](50) NULL,
	[SecurityQ3] [int] NULL,
	[SecurityA3] [varchar](50) NULL,
 CONSTRAINT [PK_MainEMS] PRIMARY KEY CLUSTERED 
(
	[PrimaryKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [IX_MainEMS_Username] ON [dbo].[MainEMS]
(
	[Username] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
ALTER TABLE [dbo].[MainEMS] ADD  CONSTRAINT [DF_MainEMS_Active]  DEFAULT ((0)) FOR [Active]
ALTER TABLE [dbo].[MainEMS] ADD  CONSTRAINT [DF_MainEMS_IsSpecial]  DEFAULT ((0)) FOR [IsSpecial]
ALTER TABLE [dbo].[MainEMS] ADD  CONSTRAINT [DF_MainEMS_CreationDate]  DEFAULT (getutcdate()) FOR [CreationDate]
ALTER TABLE [dbo].[MainEMS] ADD  CONSTRAINT [DF_MainEMS_ModifyDate]  DEFAULT (getutcdate()) FOR [ModifyDate]
ALTER TABLE [dbo].[MainEMS] ADD  CONSTRAINT [DF_MainEMS_LastLogin]  DEFAULT (getutcdate()) FOR [LastLogin]
ALTER TABLE [dbo].[MainEMS]  WITH CHECK ADD  CONSTRAINT [FK_MainEMS_MainEMSHospital] FOREIGN KEY([CompanyID])
REFERENCES [dbo].[MainEMSHospital] ([ID])
ALTER TABLE [dbo].[MainEMS] CHECK CONSTRAINT [FK_MainEMS_MainEMSHospital]