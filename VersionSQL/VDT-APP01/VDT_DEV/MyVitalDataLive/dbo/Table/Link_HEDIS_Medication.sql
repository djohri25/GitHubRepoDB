/****** Object:  Table [dbo].[Link_HEDIS_Medication]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Link_HEDIS_Medication](
	[ID] [int] NOT NULL,
	[ndc_code] [nvarchar](11) NULL,
	[brand_name] [nvarchar](50) NULL,
	[generic_product_name] [nvarchar](100) NULL,
	[route] [nvarchar](50) NULL,
	[Description] [varchar](100) NULL,
	[category] [nvarchar](50) NULL,
	[drug_id] [nvarchar](50) NULL,
	[TestID] [int] NULL,
	[TableName] [varchar](20) NULL,
	[created] [smalldatetime] NULL,
	[PackageSize] [varchar](50) NULL,
	[Unit] [varchar](50) NULL
) ON [PRIMARY]

CREATE UNIQUE CLUSTERED INDEX [IX_Link_Hedis_Med_0] ON [dbo].[Link_HEDIS_Medication]
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [IX_NCI_Link_HEDIS_Med_1] ON [dbo].[Link_HEDIS_Medication]
(
	[ndc_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [NonClusteredIndex-20170308-131854] ON [dbo].[Link_HEDIS_Medication]
(
	[ndc_code] ASC
)
INCLUDE([brand_name],[generic_product_name],[Description]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]