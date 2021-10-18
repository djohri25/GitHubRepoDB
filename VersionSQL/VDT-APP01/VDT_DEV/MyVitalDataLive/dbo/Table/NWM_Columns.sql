/****** Object:  Table [dbo].[NWM_Columns]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[NWM_Columns](
	[Program] [varchar](500) NULL,
	[Source Facility] [varchar](500) NULL,
	[Destination Facility] [varchar](500) NULL,
	[Destination type] [varchar](500) NULL,
	[Admit Date   Time] [varchar](500) NULL,
	[Discharge Date   Time] [varchar](500) NULL,
	[Discharge To Location] [varchar](500) NULL,
	[Discharge Disposition] [varchar](500) NULL,
	[Projected LOS] [varchar](500) NULL,
	[Actual LOS] [varchar](500) NULL,
	[Last MDS date] [varchar](500) NULL,
	[Last MDS type] [varchar](500) NULL,
	[MDS RUG] [varchar](500) NULL,
	[Rule Type] [varchar](500) NULL,
	[Last2MVDID] [varchar](50) NULL
) ON [PRIMARY]