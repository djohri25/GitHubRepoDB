/****** Object:  Table [dbo].[Claim_Diag_Costs]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Claim_Diag_Costs](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ClaimNumber] [varchar](100) NULL,
	[ServiceDate] [datetime] NULL,
	[ParentCode] [varchar](100) NULL,
	[ParentCodeDesc] [varchar](300) NULL,
	[ChildCodes] [varchar](max) NULL,
	[Outpatient$] [decimal](18, 2) NULL,
	[InPatient$] [decimal](18, 2) NULL,
	[Emergency$] [decimal](18, 2) NULL,
	[RX$] [decimal](18, 2) NULL,
	[LAB$] [decimal](18, 2) NULL,
	[Other$] [decimal](18, 2) NULL,
	[Created] [datetime] NULL,
	[MVDID] [varchar](30) NULL,
	[MonthID] [varchar](6) NULL,
 CONSTRAINT [PK_Claim_Diag_Costs] PRIMARY KEY NONCLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

SET ANSI_PADDING ON

CREATE CLUSTERED INDEX [IX_CI_Claim_Diag_Costs_ClaimNumber] ON [dbo].[Claim_Diag_Costs]
(
	[ClaimNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [IX_NCI_Claim_Diag_Costs_Claim_Dates] ON [dbo].[Claim_Diag_Costs]
(
	[ClaimNumber] ASC,
	[ServiceDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [IX_NCI_Claim_Diag_Costs_Code] ON [dbo].[Claim_Diag_Costs]
(
	[ParentCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
CREATE NONCLUSTERED INDEX [IX_NCI_Claim_Diag_Costs_DateIncludesRestall] ON [dbo].[Claim_Diag_Costs]
(
	[ServiceDate] ASC
)
INCLUDE([ParentCode],[ParentCodeDesc],[Outpatient$],[InPatient$],[Emergency$],[RX$],[LAB$],[Other$],[MVDID],[MonthID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [IX_NCI_Claim_Diag_Costs_MVDID_MONTHID] ON [dbo].[Claim_Diag_Costs]
(
	[MVDID] ASC,
	[MonthID] ASC
)
INCLUDE([Outpatient$],[InPatient$],[Emergency$],[RX$],[LAB$],[Other$]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [IX_NCI_Claim_Diag_Costs_ParentCOde_Amounts] ON [dbo].[Claim_Diag_Costs]
(
	[ParentCode] ASC
)
INCLUDE([Outpatient$],[InPatient$],[Emergency$],[RX$],[LAB$],[Other$]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
ALTER TABLE [dbo].[Claim_Diag_Costs] ADD  DEFAULT (getdate()) FOR [Created]