/****** Object:  Table [dbo].[AddresLatLonGeoCodeMaster]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[AddresLatLonGeoCodeMaster](
	[SummaryQuery] [nvarchar](255) NULL,
	[ResultsAddress] [nvarchar](255) NULL,
	[Lat] [nvarchar](255) NULL,
	[Lon] [nvarchar](255) NULL,
	[BlockFIPS] [nvarchar](255) NULL,
	[rownumber] [bigint] NULL
) ON [PRIMARY]