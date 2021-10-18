/****** Object:  Table [dbo].[ABCBSFormHealthCheck]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[ABCBSFormHealthCheck](
	[FormID] [bigint] NULL,
	[FormName] [nvarchar](255) NULL,
	[Num] [bigint] NULL,
	[NumUnique] [bigint] NULL,
	[NumOrphans] [bigint] NULL
) ON [PRIMARY]