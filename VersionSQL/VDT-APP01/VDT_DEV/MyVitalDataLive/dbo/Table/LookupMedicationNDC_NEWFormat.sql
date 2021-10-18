/****** Object:  Table [dbo].[LookupMedicationNDC_NEWFormat]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[LookupMedicationNDC_NEWFormat](
	[LABELERCODE] [nvarchar](max) NULL,
	[PRODUCTCODE] [nvarchar](max) NULL,
	[PRODUCTNDC] [nvarchar](max) NULL,
	[PRODUCTTYPENAME] [nvarchar](max) NULL,
	[PROPRIETARYNAME] [nvarchar](max) NULL,
	[PROPRIETARYNAMESUFFIX] [nvarchar](max) NULL,
	[NONPROPRIETARYNAME] [nvarchar](max) NULL,
	[DOSAGEFORMNAME] [nvarchar](max) NULL,
	[ROUTENAME] [nvarchar](max) NULL,
	[STARTMARKETINGDATE] [nvarchar](max) NULL,
	[ENDMARKETINGDATE] [nvarchar](max) NULL,
	[MARKETINGCATEGORYNAME] [nvarchar](max) NULL,
	[APPLICATIONNUMBER] [nvarchar](max) NULL,
	[LABELERNAME] [nvarchar](max) NULL,
	[SUBSTANCENAME] [nvarchar](max) NULL,
	[ACTIVE_NUMERATOR_STRENGTH] [nvarchar](max) NULL,
	[ACTIVE_INGRED_UNIT] [nvarchar](max) NULL,
	[PHARM_CLASSES] [nvarchar](max) NULL,
	[DEASCHEDULE] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]