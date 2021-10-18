/****** Object:  Table [dbo].[dash_caseage]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[dash_caseage](
	[id] [bigint] NOT NULL,
	[CaseOwner] [varchar](max) NULL,
	[CaseProgram] [varchar](max) NULL,
	[CaseCategory] [varchar](max) NULL,
	[CaseType] [varchar](max) NULL,
	[CaseLevel] [varchar](max) NULL,
	[FollowMember] [varchar](3) NOT NULL,
	[ConsentDate] [datetime] NULL,
	[CaseAge] [int] NULL,
	[CmOrgRegion] [varchar](50) NULL,
	[LOB] [varchar](255) NULL,
	[company_name] [varchar](100) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]