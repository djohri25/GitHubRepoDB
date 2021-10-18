/****** Object:  Table [dbo].[HCC_ICD10_2015]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[HCC_ICD10_2015](
	[Obs] [varchar](20) NULL,
	[ICD10] [varchar](20) NULL,
	[ICD10Label] [varchar](200) NULL,
	[FY2016Valid] [varchar](100) NULL,
	[FY2016MCEAgeCond] [varchar](60) NULL,
	[FY2016MCESexCond] [varchar](60) NULL,
	[CCAgeSplit] [varchar](60) NULL,
	[CCSexSplit] [varchar](60) NULL,
	[CC] [varchar](10) NULL,
	[AdditionalCC] [varchar](10) NULL,
	[Footnote] [varchar](10) NULL
) ON [PRIMARY]