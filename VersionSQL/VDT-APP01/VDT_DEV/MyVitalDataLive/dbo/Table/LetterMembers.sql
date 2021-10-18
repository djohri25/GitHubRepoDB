/****** Object:  Table [dbo].[LetterMembers]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[LetterMembers](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[MVDID] [varchar](50) NULL,
	[MemberID] [varchar](20) NULL,
	[MemberLOB] [varchar](50) NULL,
	[MemberGroup] [varchar](50) NULL,
	[MemberType] [varchar](50) NULL,
	[MemberName] [varchar](50) NULL,
	[MemberAddress1] [varchar](100) NULL,
	[MemberAddress2] [varchar](100) NULL,
	[MemberState] [varchar](50) NULL,
	[MemberCity] [varchar](50) NULL,
	[MemberZip] [varchar](50) NULL,
	[LetterType] [int] NULL,
	[LetterDate] [varchar](50) NULL,
	[LetterLanguage] [varchar](50) NULL,
	[LetterDelete] [varchar](5) NULL,
	[CareManagerName] [varchar](50) NULL,
	[CareManagerCredentials] [nvarchar](255) NULL,
	[CareManagerExtension] [varchar](20) NULL,
	[Createdby] [varchar](100) NULL,
	[CreatedDate] [varchar](50) NULL,
	[Modifiedby] [varchar](100) NULL,
	[ModifiedDate] [varchar](50) NULL,
	[Processed] [varchar](5) NULL,
	[ProcessedDate] [varchar](50) NULL,
	[LetterFlag] [varchar](20) NULL,
	[MemberDOB] [varchar](50) NULL,
	[LetterLogoPath] [varchar](300) NULL,
	[LogoPadL] [varchar](10) NULL,
	[LogoPadR] [varchar](10) NULL,
	[LogoPadT] [varchar](10) NULL,
	[LogoPadB] [varchar](10) NULL,
	[MemberCMOrgReg] [varchar](100) NULL,
	[MemberBrandingName] [varchar](100) NULL,
	[CompanyName] [varchar](100) NULL,
	[UserName] [varchar](100) NULL,
	[BatchID] [int] NULL,
	[LetterFooter] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

CREATE CLUSTERED INDEX [IX_LetterMembers] ON [dbo].[LetterMembers]
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [IX_LetterMembers_CreatedDate] ON [dbo].[LetterMembers]
(
	[CreatedDate] ASC,
	[ModifiedDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [IX_LetterMembers_ModifiedDate] ON [dbo].[LetterMembers]
(
	[ModifiedDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]