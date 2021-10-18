/****** Object:  Table [dbo].[DashboardPCPVisitsForDemo]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[DashboardPCPVisitsForDemo](
	[CustID] [int] NOT NULL,
	[LOB] [varchar](5) NULL,
	[MonthID] [char](6) NOT NULL,
	[MemberTotals] [int] NULL,
	[Year] [int] NULL,
	[Month] [int] NULL,
	[PCPVisits] [int] NOT NULL,
	[PCPVisitsPer1000] [decimal](38, 15) NOT NULL
) ON [PRIMARY]