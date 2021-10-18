/****** Object:  Table [dbo].[HEDISAuditMeansPercentiles]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[HEDISAuditMeansPercentiles](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[MeasurementYear] [int] NOT NULL,
	[ProductLine] [varchar](50) NOT NULL,
	[ReportingProduct] [varchar](50) NOT NULL,
	[MeasureName] [varchar](10) NOT NULL,
	[SubMeasureName] [varchar](10) NULL,
	[ElementID] [varchar](25) NOT NULL,
	[Description] [varchar](100) NOT NULL,
	[N] [int] NOT NULL,
	[Mean] [decimal](37, 2) NULL,
	[p10] [decimal](37, 2) NULL,
	[p25] [decimal](37, 2) NULL,
	[p50] [decimal](37, 2) NULL,
	[p75] [decimal](37, 2) NULL,
	[p90] [decimal](37, 2) NULL,
	[p95] [decimal](37, 2) NULL,
 CONSTRAINT [PK_HEDISAuditMeansPercentiles_ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [IX_HEDISAuditMeansPercentiles_Year_SubMeasureName] ON [dbo].[HEDISAuditMeansPercentiles]
(
	[MeasurementYear] ASC,
	[SubMeasureName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
SET ANSI_PADDING ON

CREATE UNIQUE NONCLUSTERED INDEX [UK_HEDISAuditMeansPercentiles_MeasurementYear_ProductLine_ReportingProduct_MeasureID_ElementI] ON [dbo].[HEDISAuditMeansPercentiles]
(
	[MeasurementYear] ASC,
	[ProductLine] ASC,
	[ReportingProduct] ASC,
	[MeasureName] ASC,
	[ElementID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]