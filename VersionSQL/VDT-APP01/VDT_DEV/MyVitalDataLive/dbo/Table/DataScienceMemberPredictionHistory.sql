/****** Object:  Table [dbo].[DataScienceMemberPredictionHistory]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[DataScienceMemberPredictionHistory](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[CustomerID] [bigint] NULL,
	[MVDID] [nvarchar](30) NULL,
	[PredictionHistoryID] [bigint] NULL,
	[MeasurementID] [bigint] NULL,
	[Value] [float] NULL
) ON [PRIMARY]

SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [IX_DataScienceMemberPredictionHistory_MVDID] ON [dbo].[DataScienceMemberPredictionHistory]
(
	[MVDID] ASC,
	[PredictionHistoryID] ASC,
	[MeasurementID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [IX_DataScienceMemberPredictionHistory_MVDID_MeasurementID] ON [dbo].[DataScienceMemberPredictionHistory]
(
	[MVDID] ASC,
	[MeasurementID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
CREATE NONCLUSTERED INDEX [IX_DataScienceMemberPredictionHistory_PredictionHistoryID] ON [dbo].[DataScienceMemberPredictionHistory]
(
	[PredictionHistoryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]