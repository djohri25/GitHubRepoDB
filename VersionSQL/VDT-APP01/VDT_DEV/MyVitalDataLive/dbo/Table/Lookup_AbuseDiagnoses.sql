/****** Object:  Table [dbo].[Lookup_AbuseDiagnoses]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Lookup_AbuseDiagnoses](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ICD_Cd] [nvarchar](100) NULL,
	[ICD_Name] [nvarchar](200) NULL,
	[Cust_IDs] [nvarchar](50) NULL
) ON [PRIMARY]