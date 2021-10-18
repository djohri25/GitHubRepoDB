/****** Object:  Table [dbo].[DataScienceRenalPrediction]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[DataScienceRenalPrediction](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[MVDID] [nvarchar](30) NOT NULL,
	[PredictionDate] [date] NOT NULL,
	[PropensityValue] [int] NOT NULL,
	[ModelID] [nvarchar](255) NOT NULL
) ON [PRIMARY]