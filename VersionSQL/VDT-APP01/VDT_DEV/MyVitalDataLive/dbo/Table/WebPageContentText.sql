/****** Object:  Table [dbo].[WebPageContentText]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[WebPageContentText](
	[PageId] [int] NOT NULL,
	[TextEnglish] [nvarchar](max) NULL,
	[TextSpanish] [nvarchar](max) NULL,
 CONSTRAINT [PK_WebPageContentText_1] PRIMARY KEY CLUSTERED 
(
	[PageId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]