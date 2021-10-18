/****** Object:  Table [dbo].[CFR_JobHistory_Merge2]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[CFR_JobHistory_Merge2](
	[ID] [int] NOT NULL,
	[ProcedureName] [varchar](128) NULL,
	[CustID] [int] NULL,
	[RuleID] [int] NULL,
	[ProductID] [int] NULL,
	[OwnerGroup] [int] NULL,
	[StartTime] [datetime] NULL,
	[EndTime] [datetime] NULL,
	[Records] [int] NULL,
	[Comment] [varchar](1000) NULL
) ON [PRIMARY]