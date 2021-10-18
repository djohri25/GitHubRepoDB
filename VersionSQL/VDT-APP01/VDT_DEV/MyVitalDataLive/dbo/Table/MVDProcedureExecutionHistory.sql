/****** Object:  Table [dbo].[MVDProcedureExecutionHistory]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[MVDProcedureExecutionHistory](
	[ProcedureName] [nvarchar](255) NULL,
	[ExecutionDatetime] [datetime] NULL
) ON [PRIMARY]