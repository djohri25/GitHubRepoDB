/****** Object:  Table [dbo].[CFR_JobHistory]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[CFR_JobHistory](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[CFR_proc_name] [varchar](100) NULL,
	[cached_time] [datetime] NULL,
	[last_execution_time] [datetime] NULL,
	[total_elapsed_time] [bigint] NULL,
	[avg_elapsed_time] [bigint] NULL,
	[last_elapsed_time] [bigint] NULL,
	[execution_count] [bigint] NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]