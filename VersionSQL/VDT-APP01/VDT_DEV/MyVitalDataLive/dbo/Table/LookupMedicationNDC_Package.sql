/****** Object:  Table [dbo].[LookupMedicationNDC_Package]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[LookupMedicationNDC_Package](
	[PRODUCTID] [varchar](50) NULL,
	[PRODUCTNDC] [varchar](10) NULL,
	[NDCPACKAGECODE] [varchar](12) NULL,
	[PACKAGEDESCRIPTION] [varchar](1000) NULL,
	[NDC11_Formatted] [varchar](13) NULL,
	[NDC11] [varchar](11) NULL,
	[CreateDate] [datetime] NOT NULL
) ON [PRIMARY]

SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [IX_LookupMedicationNDC_Package_1] ON [dbo].[LookupMedicationNDC_Package]
(
	[PRODUCTID] ASC,
	[PRODUCTNDC] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [IX_LookupMedicationNDC_Package_NDC11] ON [dbo].[LookupMedicationNDC_Package]
(
	[NDC11] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
ALTER TABLE [dbo].[LookupMedicationNDC_Package] ADD  CONSTRAINT [DF_LookupMedicationNDC_Package_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]