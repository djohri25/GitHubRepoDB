/****** Object:  Table [dbo].[DashboardTotalsByTin]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[DashboardTotalsByTin](
	[CustID] [int] NOT NULL,
	[TIN] [varchar](15) NULL,
	[LOB] [varchar](5) NULL,
	[MonthID] [char](6) NOT NULL,
	[MemberTotals] [int] NOT NULL,
	[NewMembers] [int] NOT NULL,
	[LostMembers] [int] NOT NULL,
	[ERVisits] [int] NOT NULL,
	[ERVisitsPer1000] [decimal](38, 15) NOT NULL,
	[HospitalAdmits] [int] NOT NULL,
	[AdmissionsFromERPer1000] [decimal](38, 15) NOT NULL,
	[Age] [decimal](38, 15) NULL,
	[Under3] [int] NULL,
	[Age3to10] [int] NULL,
	[Age11to17] [int] NULL,
	[Age18to26] [int] NULL,
	[Age27to50] [int] NULL,
	[Over50] [int] NULL,
	[PCPVisits] [int] NULL,
	[PCPVisitsPer1000] [decimal](38, 15) NULL,
	[DateModified] [datetime] NOT NULL
) ON [PRIMARY]

SET ANSI_PADDING ON

CREATE UNIQUE CLUSTERED INDEX [IX_DashboardTotalsByTin_CustID_TIN_LOB_MonthID] ON [dbo].[DashboardTotalsByTin]
(
	[CustID] ASC,
	[TIN] ASC,
	[LOB] ASC,
	[MonthID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
ALTER TABLE [dbo].[DashboardTotalsByTin] ADD  CONSTRAINT [DF_DashboardTotalsByTin_MemberTotals]  DEFAULT ((0)) FOR [MemberTotals]
ALTER TABLE [dbo].[DashboardTotalsByTin] ADD  CONSTRAINT [DF_DashboardTotalsByTin_NewMembers]  DEFAULT ((0)) FOR [NewMembers]
ALTER TABLE [dbo].[DashboardTotalsByTin] ADD  CONSTRAINT [DF_DashboardTotalsByTin_LostMembers]  DEFAULT ((0)) FOR [LostMembers]
ALTER TABLE [dbo].[DashboardTotalsByTin] ADD  CONSTRAINT [DF_DashboardTotalsByTin_ERVisits]  DEFAULT ((0)) FOR [ERVisits]
ALTER TABLE [dbo].[DashboardTotalsByTin] ADD  CONSTRAINT [DF_DashboardTotalsByTin_ERVisitsPer1000]  DEFAULT ((0)) FOR [ERVisitsPer1000]
ALTER TABLE [dbo].[DashboardTotalsByTin] ADD  CONSTRAINT [DF_DashboardTotalsByTin_HospitalAdmits]  DEFAULT ((0)) FOR [HospitalAdmits]
ALTER TABLE [dbo].[DashboardTotalsByTin] ADD  CONSTRAINT [DF_DashboardTotalsByTin_AdmissionsFromERPer1000]  DEFAULT ((0)) FOR [AdmissionsFromERPer1000]
ALTER TABLE [dbo].[DashboardTotalsByTin] ADD  CONSTRAINT [DF_DashboardTotalsByTin_DateModified]  DEFAULT (getdate()) FOR [DateModified]