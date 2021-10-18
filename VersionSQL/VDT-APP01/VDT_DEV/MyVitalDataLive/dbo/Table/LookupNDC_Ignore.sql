/****** Object:  Table [dbo].[LookupNDC_Ignore]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[LookupNDC_Ignore](
	[NDC] [varchar](15) NOT NULL,
	[Name] [varchar](100) NULL,
 CONSTRAINT [PK_LookupNDC_Ignore] PRIMARY KEY CLUSTERED 
(
	[NDC] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]