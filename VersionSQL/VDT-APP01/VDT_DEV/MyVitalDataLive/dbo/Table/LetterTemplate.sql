/****** Object:  Table [dbo].[LetterTemplate]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[LetterTemplate](
	[RecordID] [int] IDENTITY(1,1) NOT NULL,
	[LetterType] [int] NULL,
	[LetterName] [varchar](100) NULL,
	[LetterFooter] [nvarchar](max) NULL,
	[LetterLanguage] [nvarchar](max) NULL,
	[CmOrgRegion] [varchar](100) NULL,
	[BrandingName] [varchar](100) NULL,
	[LetterLogoPath] [varchar](300) NULL,
	[LogoPadL] [varchar](10) NULL,
	[LogoPadR] [varchar](10) NULL,
	[LogoPadT] [varchar](10) NULL,
	[LogoPadB] [varchar](10) NULL,
	[MemberType] [varchar](50) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]