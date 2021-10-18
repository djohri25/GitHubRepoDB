/****** Object:  Table [dbo].[WebPageContentTextBackup]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[WebPageContentTextBackup](
	[PageId] [int] NOT NULL,
	[Text] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]