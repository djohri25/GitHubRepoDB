/****** Object:  Table [dbo].[mvdSProcExecutionInfo]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[mvdSProcExecutionInfo](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[name] [nvarchar](100) NULL,
	[UserName] [varchar](500) NULL,
	[UserID] [nvarchar](100) NULL,
	[CustomerID] [int] NULL,
	[ProductID] [int] NULL,
	[start_time] [datetime] NULL,
	[end_time] [datetime] NULL
) ON [PRIMARY]