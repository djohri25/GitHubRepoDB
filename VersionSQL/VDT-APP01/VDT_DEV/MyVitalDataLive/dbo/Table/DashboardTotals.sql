/****** Object:  Table [dbo].[DashboardTotals]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[DashboardTotals](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[CustID] [int] NOT NULL,
	[MonthID] [char](6) NOT NULL,
	[ClaimsProcessedMonthlyTotal] [int] NULL,
	[ClaimsProcessedYearlyTotal] [int] NULL,
	[AvgUserLoginMonthlyTotal] [int] NULL,
	[AvgUserLoginYearlyTotal] [int] NULL,
	[DocumentsCreatedMonthlyTotal] [int] NULL,
	[DocumentsCreatedYearlyTotal] [int] NULL,
	[EDVisitsMonthlyTotal] [int] NULL,
	[EDVisitsYearlyTotal] [int] NULL,
	[NotesCreatedMonthlyTotal] [int] NULL,
	[NotesCreatedYearlyTotal] [int] NULL,
	[PageAccessMonthlyTotal] [int] NULL,
	[PageAccessYearlyTotal] [int] NULL,
	[UserLoginsMonthlyTotal] [int] NULL,
	[UserLoginsYearlyTotal] [int] NULL,
	[PCPVisitsMonthlyTotal] [int] NULL,
	[PCPVisitsYearlyTotal] [int] NULL,
	[DateCreated] [datetime] NOT NULL,
	[DateModified] [datetime] NOT NULL,
 CONSTRAINT [PK_DashboardTotals_ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

SET ANSI_PADDING ON

CREATE UNIQUE NONCLUSTERED INDEX [IX_DashboardTotals_CustID_MonthID] ON [dbo].[DashboardTotals]
(
	[CustID] ASC,
	[MonthID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
ALTER TABLE [dbo].[DashboardTotals] ADD  CONSTRAINT [DF_DashboardTotals_DateCreated]  DEFAULT (getdate()) FOR [DateCreated]
ALTER TABLE [dbo].[DashboardTotals] ADD  CONSTRAINT [DF_DashboardTotals_DateModified]  DEFAULT (getdate()) FOR [DateModified]