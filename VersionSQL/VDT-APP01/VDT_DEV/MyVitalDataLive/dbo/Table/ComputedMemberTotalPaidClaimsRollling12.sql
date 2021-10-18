/****** Object:  Table [dbo].[ComputedMemberTotalPaidClaimsRollling12]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[ComputedMemberTotalPaidClaimsRollling12](
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

CREATE CLUSTERED INDEX [IC_ComputedMemberTotalPaidClaimsRollling12_ID] ON [dbo].[ComputedMemberTotalPaidClaimsRollling12]
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [IC_ComputedMemberTotalPaidClaimsRollling12_MVDID_MemberID] ON [dbo].[ComputedMemberTotalPaidClaimsRollling12]
(
	[MVDID] ASC,
	[MemberID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [IX_ComputedMemberTotalPaidClaimsRollling12_CustID_MonthID] ON [dbo].[ComputedMemberTotalPaidClaimsRollling12]
(
	[CustID] ASC,
	[MonthID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [IX_ComputedMemberTotalPaidClaimsRollling12_MemberID] ON [dbo].[ComputedMemberTotalPaidClaimsRollling12]
(
	[MemberID] ASC,
	[MonthID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]