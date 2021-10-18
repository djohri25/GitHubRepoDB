/****** Object:  Table [dbo].[Lookup_AbuseTreatmentCodes]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Lookup_AbuseTreatmentCodes](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Treatment_Cd] [varchar](100) NULL,
	[Description] [nvarchar](1000) NULL,
	[Cust_IDs] [nvarchar](50) NULL
) ON [PRIMARY]