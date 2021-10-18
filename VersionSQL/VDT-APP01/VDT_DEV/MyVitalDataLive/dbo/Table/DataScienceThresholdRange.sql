/****** Object:  Table [dbo].[DataScienceThresholdRange]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[DataScienceThresholdRange](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[HistoryID] [bigint] NULL,
	[KeyValue] [int] NULL,
	[Description] [nvarchar](255) NULL,
	[MinValue] [float] NULL,
	[MaxValue] [float] NULL
) ON [PRIMARY]