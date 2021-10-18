/****** Object:  Table [dbo].[LookupPhyseraVirtualVisit]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[LookupPhyseraVirtualVisit](
	[StoreID] [varchar](5) NULL,
	[Company] [varchar](255) NULL,
	[Address] [varchar](255) NULL,
	[City] [varchar](255) NULL,
	[ZIP] [varchar](5) NULL,
	[StateCD] [varchar](2) NULL
) ON [PRIMARY]