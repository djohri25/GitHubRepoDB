/****** Object:  Table [dbo].[LookupMonthlyMemberOverviewParameters]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[LookupMonthlyMemberOverviewParameters](
	[ID] [bigint] NOT NULL,
	[DBNAME] [varchar](100) NULL,
	[CM_ORG_REGION] [varchar](50) NULL,
	[CompanyKey] [varchar](50) NULL,
	[CompanyName] [varchar](100) NULL,
	[FileName] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]