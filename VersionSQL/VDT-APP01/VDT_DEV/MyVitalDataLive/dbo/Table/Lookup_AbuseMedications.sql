/****** Object:  Table [dbo].[Lookup_AbuseMedications]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Lookup_AbuseMedications](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Prod_Id] [nvarchar](100) NULL,
	[Prod_Name] [nvarchar](50) NULL,
	[Cust_IDs] [nvarchar](50) NULL
) ON [PRIMARY]