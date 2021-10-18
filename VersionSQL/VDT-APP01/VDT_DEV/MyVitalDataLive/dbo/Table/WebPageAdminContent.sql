/****** Object:  Table [dbo].[WebPageAdminContent]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[WebPageAdminContent](
	[PageName] [nvarchar](50) NOT NULL,
	[PageMode] [nvarchar](50) NOT NULL,
	[Text] [nvarchar](max) NULL,
	[ModifyDate] [datetime] NULL,
 CONSTRAINT [PK_WebPageAdminContent] PRIMARY KEY CLUSTERED 
(
	[PageName] ASC,
	[PageMode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]