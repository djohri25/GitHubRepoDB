/****** Object:  Table [dbo].[DashboardAverageAgeForDemo]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[DashboardAverageAgeForDemo](
	[CustID] [int] NOT NULL,
	[LOB] [varchar](5) NULL,
	[MonthID] [char](6) NOT NULL,
	[AverageAge] [decimal](8, 2) NULL,
	[Pct Under3] [decimal](5, 4) NULL,
	[Pct Age3-10] [decimal](5, 4) NULL,
	[Pct Age11-17] [decimal](5, 4) NULL,
	[Pct Age18-26] [decimal](5, 4) NULL,
	[Pct Age27-50] [decimal](5, 4) NULL,
	[Pct Over50] [decimal](5, 4) NULL
) ON [PRIMARY]