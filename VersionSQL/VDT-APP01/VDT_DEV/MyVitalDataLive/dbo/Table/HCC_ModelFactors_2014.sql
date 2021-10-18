/****** Object:  Table [dbo].[HCC_ModelFactors_2014]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[HCC_ModelFactors_2014](
	[Model] [varchar](20) NULL,
	[Variable] [varchar](60) NULL,
	[RiskScoreUsed] [varchar](5) NULL,
	[PlatinumLevel] [decimal](10, 3) NULL,
	[GoldLevel] [decimal](10, 3) NULL,
	[SilverLevel] [decimal](10, 3) NULL,
	[BronzeLevel] [decimal](10, 3) NULL,
	[CatastrophicLevel] [decimal](10, 3) NULL
) ON [PRIMARY]