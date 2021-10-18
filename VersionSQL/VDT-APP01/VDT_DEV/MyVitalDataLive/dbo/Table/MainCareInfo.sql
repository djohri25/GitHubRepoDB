/****** Object:  Table [dbo].[MainCareInfo]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[MainCareInfo](
	[RecordNumber] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[ICENUMBER] [varchar](15) NOT NULL,
	[LastName] [varchar](50) NULL,
	[FirstName] [varchar](50) NULL,
	[Address1] [varchar](50) NULL,
	[Address2] [varchar](50) NULL,
	[City] [varchar](50) NULL,
	[State] [varchar](50) NULL,
	[Postal] [varchar](50) NULL,
	[PhoneHome] [varchar](10) NULL,
	[PhoneCell] [varchar](10) NULL,
	[PhoneOther] [varchar](10) NULL,
	[CareTypeID] [int] NULL,
	[RelationshipId] [int] NULL,
	[CreationDate] [datetime] NULL,
	[ModifyDate] [datetime] NULL,
	[HVID] [char](36) NULL,
	[ContactType] [varchar](20) NULL,
	[EmailAddress] [varchar](100) NULL,
	[NotifyByEmail] [bit] NULL,
	[NotifyBySMS] [bit] NULL,
	[CreatedBy] [nvarchar](250) NULL,
	[CreatedByOrganization] [varchar](250) NULL,
	[UpdatedBy] [nvarchar](250) NULL,
	[UpdatedByOrganization] [varchar](250) NULL,
	[UpdatedByContact] [nvarchar](64) NULL,
	[Organization] [nvarchar](256) NULL,
	[MiddleName] [nvarchar](50) NULL,
 CONSTRAINT [PK_MainCareInfo] PRIMARY KEY CLUSTERED 
(
	[RecordNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [IX_MainCareInfo] ON [dbo].[MainCareInfo]
(
	[ICENUMBER] ASC,
	[LastName] ASC,
	[FirstName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [IX_MainCareInfo_1] ON [dbo].[MainCareInfo]
(
	[ICENUMBER] ASC,
	[CareTypeID] ASC,
	[RecordNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
ALTER TABLE [dbo].[MainCareInfo] ADD  CONSTRAINT [DF__MainCareI__Notif__1CFC3D38]  DEFAULT ((0)) FOR [NotifyByEmail]
ALTER TABLE [dbo].[MainCareInfo] ADD  CONSTRAINT [DF__MainCareI__Notif__1DF06171]  DEFAULT ((0)) FOR [NotifyBySMS]
ALTER TABLE [dbo].[MainCareInfo]  WITH CHECK ADD  CONSTRAINT [FK_MainCareInfo_LookupCareTypeID] FOREIGN KEY([CareTypeID])
REFERENCES [dbo].[LookupCareTypeID] ([CareTypeID])
ALTER TABLE [dbo].[MainCareInfo] CHECK CONSTRAINT [FK_MainCareInfo_LookupCareTypeID]
ALTER TABLE [dbo].[MainCareInfo]  WITH CHECK ADD  CONSTRAINT [FK_MainCareInfo_MainPersonalDetails] FOREIGN KEY([ICENUMBER])
REFERENCES [dbo].[MainPersonalDetails] ([ICENUMBER])
ON UPDATE CASCADE
ON DELETE CASCADE
ALTER TABLE [dbo].[MainCareInfo] CHECK CONSTRAINT [FK_MainCareInfo_MainPersonalDetails]