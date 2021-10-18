/****** Object:  Table [dbo].[HCC_ICD9_2014]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[HCC_ICD9_2014](
	[Obs] [varchar](20) NULL,
	[ICD9] [varchar](20) NULL,
	[ICD9Label] [varchar](200) NULL,
	[FY2011Valid] [varchar](100) NULL,
	[FY2012Valid] [varchar](100) NULL,
	[FY2013Valid] [varchar](100) NULL,
	[FY2014Valid] [varchar](100) NULL,
	[FY2014MCEAgeCond] [varchar](60) NULL,
	[FY2014MCESexCond] [varchar](60) NULL,
	[CCAgeSplit] [varchar](60) NULL,
	[CCSexSplit] [varchar](60) NULL,
	[CC] [varchar](10) NULL,
	[AdditionalCC] [varchar](10) NULL,
	[Footnote] [varchar](10) NULL
) ON [PRIMARY]