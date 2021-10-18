/****** Object:  Table [dbo].[DataScienceCostPrediction]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[DataScienceCostPrediction](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[MVDID] [nvarchar](30) NOT NULL,
	[PredictionDate] [date] NOT NULL,
	[TopTenPercentValue] [int] NOT NULL,
	[DecileValue] [int] NOT NULL,
	[BracketValue] [int] NOT NULL,
	[ModelID] [nvarchar](255) NOT NULL,
	[PredCost] [decimal](18, 2) NOT NULL
) ON [PRIMARY]