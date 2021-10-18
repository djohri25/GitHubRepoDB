/****** Object:  Table [dbo].[LookupCPT]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[LookupCPT](
	[Code] [nvarchar](10) NOT NULL,
	[Description1] [nvarchar](1000) NULL,
	[Description2] [nvarchar](max) NULL,
	[Type] [nchar](50) NULL,
	[Label] [varchar](160) NULL,
	[LabelID] [int] NULL,
 CONSTRAINT [PK_HP_SV1] PRIMARY KEY CLUSTERED 
(
	[Code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]