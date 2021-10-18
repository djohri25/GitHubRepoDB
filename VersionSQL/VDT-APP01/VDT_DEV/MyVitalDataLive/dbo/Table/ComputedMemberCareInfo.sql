/****** Object:  Table [dbo].[ComputedMemberCareInfo]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[ComputedMemberCareInfo](
	[RecordNumber] [int] NOT NULL,
	[ICENUMBER] [varchar](30) NOT NULL,
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
	[MiddleName] [nvarchar](50) NULL
) ON [PRIMARY]

SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [IC_ComputedMemberAllergies_ICENUMBER] ON [dbo].[ComputedMemberCareInfo]
(
	[ICENUMBER] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]