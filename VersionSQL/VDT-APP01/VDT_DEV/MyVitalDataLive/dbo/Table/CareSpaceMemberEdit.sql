/****** Object:  Table [dbo].[CareSpaceMemberEdit]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[CareSpaceMemberEdit](
	[RecordNumber] [int] IDENTITY(1,1) NOT NULL,
	[ICENUMBER] [varchar](30) NULL,
	[LastName] [varchar](50) NOT NULL,
	[FirstName] [varchar](50) NOT NULL,
	[MiddleName] [nvarchar](50) NULL,
	[Address1] [varchar](128) NULL,
	[Address2] [varchar](128) NULL,
	[City] [varchar](50) NULL,
	[State] [varchar](2) NULL,
	[PostalCode] [varchar](5) NULL,
	[HomePhone] [varchar](10) NULL,
	[CellPhone] [varchar](10) NULL,
	[WorkPhone] [varchar](10) NULL,
	[FaxPhone] [varchar](10) NULL,
	[Email] [varchar](100) NULL,
	[Language] [varchar](50) NULL,
	[Ethnicity] [varchar](50) NULL,
	[Housing] [varchar](50) NULL,
	[CreatedBy] [varchar](250) NULL,
	[UpdatedBy] [varchar](250) NULL,
	[CreationDate] [datetime] NULL,
	[ModifyDate] [datetime] NULL,
	[Source] [varchar](60) NULL,
	[Type] [varchar](60) NULL,
	[StartDate] [date] NULL,
	[EndDate] [date] NULL,
	[IsPrimary] [bit] NULL,
 CONSTRAINT [PK_CareSpaceMemberEdit] PRIMARY KEY CLUSTERED 
(
	[RecordNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_CareSpaceMemberEdit_CreationDate] ON [dbo].[CareSpaceMemberEdit]
(
	[CreationDate] ASC,
	[ModifyDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
CREATE NONCLUSTERED INDEX [IX_CareSpaceMemberEdit_ModifyDate] ON [dbo].[CareSpaceMemberEdit]
(
	[ModifyDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
ALTER TABLE [dbo].[CareSpaceMemberEdit] ADD  DEFAULT (getutcdate()) FOR [CreationDate]