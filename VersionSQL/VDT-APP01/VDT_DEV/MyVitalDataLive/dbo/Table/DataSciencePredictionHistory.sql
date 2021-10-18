/****** Object:  Table [dbo].[DataSciencePredictionHistory]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[DataSciencePredictionHistory](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[CustomerID] [bigint] NULL,
	[PredictionDate] [date] NULL,
	[Description] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]