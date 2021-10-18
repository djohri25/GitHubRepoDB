/****** Object:  Table [dbo].[LetterTemplate]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[LetterTemplate](
	[LetterType] [int] NULL,
	[LetterName] [varchar](100) NULL,
	[LetterFooter] [nvarchar](max) NULL,
	[LetterLanguage] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]