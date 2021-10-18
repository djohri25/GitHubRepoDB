/****** Object:  Table [dbo].[ComputedMemberTotalPendedClaimsRollling12]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[ComputedMemberTotalPendedClaimsRollling12](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[MVDID] [varchar](30) NOT NULL,
	[MemberID] [varchar](30) NOT NULL,
	[LOB] [varchar](100) NULL,
	[PlanGroup] [varchar](100) NULL,
	[MonthID] [varchar](6) NOT NULL,
	[MeasureMonthStart] [date] NOT NULL,
	[MeasureMonthEnd] [date] NOT NULL,
	[TotalPaidAmount] [decimal](18, 2) NOT NULL,
	[HighDollarClaim] [bit] NULL,
	[CustID] [int] NOT NULL,
	[CreateDate] [datetime] NOT NULL
) ON [PRIMARY]