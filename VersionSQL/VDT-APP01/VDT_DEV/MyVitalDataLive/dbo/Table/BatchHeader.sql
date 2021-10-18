/****** Object:  Table [dbo].[BatchHeader]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[BatchHeader](
	[BatchID] [bigint] NOT NULL,
	[ProcessDateUTC] [datetime] NULL,
	[CustID] [int] NOT NULL,
	[IsProcessed] [bit] NOT NULL
) ON [PRIMARY]