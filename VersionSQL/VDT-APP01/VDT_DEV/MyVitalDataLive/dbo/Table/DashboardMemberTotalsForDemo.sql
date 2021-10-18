/****** Object:  Table [dbo].[DashboardMemberTotalsForDemo]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[DashboardMemberTotalsForDemo](
	[CustID] [int] NOT NULL,
	[LOB] [varchar](5) NULL,
	[MonthID] [int] NOT NULL,
	[MemberTotals] [int] NULL,
	[NewMembers] [int] NULL,
	[LostMembers] [int] NULL
) ON [PRIMARY]