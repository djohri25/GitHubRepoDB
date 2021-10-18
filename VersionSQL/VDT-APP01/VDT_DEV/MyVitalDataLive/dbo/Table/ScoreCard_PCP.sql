/****** Object:  Table [dbo].[ScoreCard_PCP]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[ScoreCard_PCP](
	[testID] [int] NULL,
	[testAbbr] [varchar](10) NULL,
	[testName] [varchar](300) NULL,
	[FullTestName] [varchar](300) NULL,
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
	[duration] [varchar](50) NULL,
	[MonthID] [char](6) NULL,
	[Created] [datetime] NULL
) ON [PRIMARY]

SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [IX_ScoreCard_PCP_CustID_MonthID] ON [dbo].[ScoreCard_PCP]
(
	[CustID] ASC,
	[MonthID] ASC
)
INCLUDE([testID],[testAbbr]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
ALTER TABLE [dbo].[ScoreCard_PCP] ADD  CONSTRAINT [DF_ScoreCard_PCP_Created]  DEFAULT (getdate()) FOR [Created]