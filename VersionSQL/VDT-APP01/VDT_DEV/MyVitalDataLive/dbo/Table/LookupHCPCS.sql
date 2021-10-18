/****** Object:  Table [dbo].[LookupHCPCS]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[LookupHCPCS](
	[Code] [nvarchar](5) NOT NULL,
	[Status] [nvarchar](1) NULL,
	[AbbreviatedDescription] [varchar](75) NULL,
	[Description] [nvarchar](1100) NULL,
	[DescriptionCont] [nvarchar](1000) NULL,
	[MedicareCoverage] [nvarchar](35) NULL,
	[Type] [nchar](50) NULL,
 CONSTRAINT [PK_LookupHCPCS] PRIMARY KEY CLUSTERED 
(
	[Code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]