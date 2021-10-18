/****** Object:  Table [dbo].[Lookup_DRLink_NPI_to_CustID]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Lookup_DRLink_NPI_to_CustID](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[NPI] [varchar](50) NULL,
	[Cust_ID] [int] NULL
) ON [PRIMARY]