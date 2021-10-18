/****** Object:  Table [dbo].[EligMonth]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[EligMonth](
	[monthid] [nvarchar](255) NULL,
	[LOB] [varchar](2) NULL,
	[CompanyKey] [int] NULL,
	[CmOrgRegion] [varchar](50) NULL,
	[MemCount] [int] NULL
) ON [PRIMARY]