/****** Object:  Table [dbo].[HCC_HEDIS_RISK_Map]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[HCC_HEDIS_RISK_Map](
	[HCC] [nvarchar](150) NULL,
	[HEDIS] [nvarchar](50) NULL,
	[Charlson] [nvarchar](100) NULL,
	[Elixhauser] [nvarchar](100) NULL
) ON [PRIMARY]