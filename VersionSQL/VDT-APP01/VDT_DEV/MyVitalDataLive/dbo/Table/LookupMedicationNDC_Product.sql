/****** Object:  Table [dbo].[LookupMedicationNDC_Product]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[LookupMedicationNDC_Product](
	[PRODUCTID] [varchar](50) NULL,
	[PRODUCTNDC] [varchar](10) NULL,
	[PRODUCTTYPENAME] [varchar](50) NULL,
	[PROPRIETARYNAME] [varchar](255) NULL,
	[PROPRIETARYNAMESUFFIX] [varchar](255) NULL,
	[NONPROPRIETARYNAME] [varchar](512) NULL,
	[DOSAGEFORMNAME] [varchar](50) NULL,
	[ROUTENAME] [varchar](255) NULL,
	[STARTMARKETINGDATE] [varchar](8) NULL,
	[ENDMARKETINGDATE] [varchar](8) NULL,
	[MARKETINGCATEGORYNAME] [varchar](50) NULL,
	[APPLICATIONNUMBER] [varchar](50) NULL,
	[LABELERNAME] [varchar](255) NULL,
	[SUBSTANCENAME] [varchar](4000) NULL,
	[ACTIVE_NUMERATOR_STRENGTH] [varchar](4000) NULL,
	[ACTIVE_INGRED_UNIT] [varchar](4000) NULL,
	[PHARM_CLASSES] [varchar](4000) NULL,
	[DEASCHEDULE] [varchar](4) NULL,
	[CreateDate] [datetime] NOT NULL
) ON [PRIMARY]

SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [IX_LookupMedicationNDC_Product_1] ON [dbo].[LookupMedicationNDC_Product]
(
	[PRODUCTID] ASC,
	[PRODUCTNDC] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
ALTER TABLE [dbo].[LookupMedicationNDC_Product] ADD  CONSTRAINT [DF_LookupMedicationNDC_Product_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]