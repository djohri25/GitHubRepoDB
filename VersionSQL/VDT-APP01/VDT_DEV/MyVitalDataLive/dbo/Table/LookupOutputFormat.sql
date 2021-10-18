/****** Object:  Table [dbo].[LookupOutputFormat]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[LookupOutputFormat](
	[ID] [int] NOT NULL,
	[Name] [varchar](50) NULL,
	[FileExtension] [varchar](4) NULL,
 CONSTRAINT [PK_Lookup_OutputFormat] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]