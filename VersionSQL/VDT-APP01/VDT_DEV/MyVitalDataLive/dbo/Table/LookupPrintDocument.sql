/****** Object:  Table [dbo].[LookupPrintDocument]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[LookupPrintDocument](
	[ID] [int] NOT NULL,
	[OrderId] [int] NULL,
	[Description] [nvarchar](50) NULL,
	[Link] [nvarchar](200) NULL,
	[DescriptionSpanish] [nvarchar](100) NULL,
 CONSTRAINT [PK_LookupPrintDocument] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]