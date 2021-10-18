/****** Object:  Table [dbo].[MainClaimsHeader]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[MainClaimsHeader](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[CustID] [int] NULL,
	[ClaimNumber] [varchar](50) NOT NULL,
	[Created] [datetime] NULL,
	[Updated] [datetime] NULL,
	[BillType] [varchar](10) NULL,
	[FormType] [varchar](10) NULL,
	[AdjustmentCode] [varchar](10) NULL,
	[AdmissionSource] [varchar](10) NULL,
	[AdmittingType] [varchar](10) NULL,
	[EmergencyIndicator] [varchar](10) NULL,
	[NetworkIndicator] [varchar](10) NULL,
	[AdmissionDate] [varchar](30) NULL,
	[DischargeDate] [varchar](30) NULL,
	[DischargeStatus] [varchar](10) NULL,
	[TotalBilledAmount] [decimal](18, 2) NULL,
	[TotalAllowedAmount] [decimal](18, 2) NULL,
	[TotalPaidAmount] [decimal](18, 2) NULL,
	[TotalDiscountAmount] [decimal](18, 2) NULL,
	[TotalCopayAmount] [decimal](18, 2) NULL,
	[TotalCOBAmount] [decimal](18, 2) NULL,
	[TotalWithHoldAmount] [decimal](18, 2) NULL,
	[TotalDedAmount] [decimal](18, 2) NULL,
	[TotalCoinsAmount] [decimal](18, 2) NULL,
	[TotalRefundAmount] [decimal](18, 2) NULL,
 CONSTRAINT [IX_MainClaimsHeader] PRIMARY KEY NONCLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

CREATE CLUSTERED INDEX [IX_CI_MainClaimsHeader_ID] ON [dbo].[MainClaimsHeader]
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
CREATE NONCLUSTERED INDEX [IX_NCI_MainCLaims_CUstID] ON [dbo].[MainClaimsHeader]
(
	[CustID] ASC
)
INCLUDE([ID],[ClaimNumber]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [IX_NCI_MainClaims_CustID_Claim] ON [dbo].[MainClaimsHeader]
(
	[CustID] ASC,
	[ClaimNumber] ASC
)
INCLUDE([BillType],[FormType],[AdjustmentCode],[AdmissionSource],[AdmittingType],[EmergencyIndicator],[NetworkIndicator],[AdmissionDate],[DischargeDate],[DischargeStatus]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [IX_NCI_MainClaims_CustID_CLaim_ID] ON [dbo].[MainClaimsHeader]
(
	[CustID] ASC,
	[ClaimNumber] ASC,
	[ID] ASC
)
INCLUDE([BillType],[DischargeStatus]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]