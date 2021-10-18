/****** Object:  Table [dbo].[ScoreCardCacheForDemo]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[ScoreCardCacheForDemo](
	[testID] [int] NULL,
	[testAbbr] [varchar](50) NULL,
	[testName] [varchar](100) NULL,
	[FullTestName] [varchar](150) NULL,
	[testType] [varchar](50) NULL,
	[PrevYearPerc] [decimal](8, 2) NULL,
	[CurYearToDatePerc] [decimal](8, 2) NULL,
	[CurYearOverall] [decimal](8, 2) NULL,
	[GoalPerc] [decimal](8, 2) NULL,
	[AvgMonthlyDifference] [decimal](8, 2) NULL,
	[QualifyingMemCount] [int] NULL,
	[CompletedMemCount] [int] NULL,
	[DueMemCount] [int] NULL,
	[YearToDateGoalStatus] [int] NULL,
	[CurYearOverallGoalStatus] [int] NULL,
	[PCP_NPI] [varchar](50) NULL,
	[PCP_GroupID] [varchar](50) NULL,
	[CustID] [int] NULL,
	[duration] [int] NULL,
	[MonthID] [char](6) NULL
) ON [PRIMARY]