/****** Object:  UserDefinedTableType [dbo].[BroadcastPopulation]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TYPE [dbo].[BroadcastPopulation] AS TABLE(
	[MVDID] [varchar](50) NULL,
	[IsMemberRegistered] [bit] NULL,
	[BroadcastStatusId] [int] NULL
)