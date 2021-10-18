/****** Object:  Table [dbo].[DataScienceSUDPrediction]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[DataScienceSUDPrediction](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[MVDID] [nvarchar](30) NOT NULL,
	[PredictionDate] [date] NOT NULL,
	[PropensityValue] [int] NOT NULL,
	[ModelID] [nvarchar](255) NOT NULL
) ON [PRIMARY]

SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [IX_DataScienceSUDPrediction_MVDID] ON [dbo].[DataScienceSUDPrediction]
(
	[MVDID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]