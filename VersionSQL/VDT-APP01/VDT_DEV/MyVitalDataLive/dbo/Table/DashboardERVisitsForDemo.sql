/****** Object:  Table [dbo].[DashboardERVisitsForDemo]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[DashboardERVisitsForDemo](
	[CustID] [int] NOT NULL,
	[LOB] [varchar](5) NULL,
	[MonthID] [char](6) NOT NULL,
	[MemberTotals] [int] NULL,
	[Year] [int] NULL,
	[Month] [int] NULL,
	[ERVisits] [int] NOT NULL,
	[ERVisitsPer1000] [decimal](38, 15) NULL,
	[HospitalAdmits] [int] NOT NULL,
	[AdmissionsFromERPer1000] [decimal](38, 15) NULL
) ON [PRIMARY]