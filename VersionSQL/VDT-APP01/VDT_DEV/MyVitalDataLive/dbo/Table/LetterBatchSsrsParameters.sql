/****** Object:  Table [dbo].[LetterBatchSsrsParameters]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[LetterBatchSsrsParameters](
	[DBNAME] [varchar](30) NULL,
	[Customer] [varchar](4) NULL,
	[LetterGroup] [varchar](7) NULL,
	[LOB] [varchar](7) NULL,
	[DateRangeType] [varchar](6) NULL,
	[ClientsLocalTime] [datetime] NULL,
	[BrandingName] [varchar](50) NULL,
	[CmOrgReg] [varchar](500) NULL,
	[LetterFileName] [varchar](1000) NULL
) ON [PRIMARY]