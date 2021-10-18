/****** Object:  Table [dba].[IndexDefragLog]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dba].[IndexDefragLog](
	[indexDefrag_id] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[databaseID] [int] NOT NULL,
	[databaseName] [nvarchar](128) NOT NULL,
	[objectID] [int] NOT NULL,
	[objectName] [nvarchar](128) NOT NULL,
	[indexID] [int] NOT NULL,
	[indexName] [nvarchar](128) NOT NULL,
	[partitionNumber] [smallint] NOT NULL,
	[fragmentation] [float] NOT NULL,
	[page_count] [int] NOT NULL,
	[dateTimeStart] [datetime] NOT NULL,
	[durationSeconds] [int] NOT NULL,
 CONSTRAINT [PK_indexDefragLog] PRIMARY KEY CLUSTERED 
(
	[indexDefrag_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]