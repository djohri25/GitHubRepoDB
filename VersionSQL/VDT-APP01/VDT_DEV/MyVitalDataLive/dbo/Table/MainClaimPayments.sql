/****** Object:  Table [dbo].[MainClaimPayments]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[MainClaimPayments](
	[RecordNumber] [int] IDENTITY(1,1) NOT NULL,
	[ClaimID] [int] NULL,
	[LineNum] [int] NULL,
	[PaidDate] [date] NULL,
	[ReceivedDate] [date] NULL,
	[SubmittedAmount] [decimal](18, 2) NULL,
	[AllowableAmount] [decimal](18, 2) NULL,
	[TotalAmountPaid] [decimal](18, 2) NULL,
	[DiscountAmount] [decimal](18, 2) NULL,
	[CopaymentAmount] [decimal](18, 2) NULL,
	[COBAmount] [decimal](18, 2) NULL,
	[CoinsuranceAmount] [decimal](18, 2) NULL,
	[RefundAmount] [decimal](18, 2) NULL,
	[ClaimStatus] [varchar](10) NULL,
	[Created] [datetime] NULL,
	[Updated] [datetime] NULL,
 CONSTRAINT [IX_MainCLaimPayments] PRIMARY KEY CLUSTERED 
(
	[RecordNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_NCI_MainClaimsPayments_Claim_Line_Dates] ON [dbo].[MainClaimPayments]
(
	[ClaimID] ASC,
	[LineNum] ASC,
	[PaidDate] ASC,
	[ReceivedDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
CREATE NONCLUSTERED INDEX [IX_NCI_MainClaimsPayments_Line] ON [dbo].[MainClaimPayments]
(
	[LineNum] ASC
)
INCLUDE([RecordNumber],[ClaimID],[PaidDate],[ReceivedDate],[SubmittedAmount],[AllowableAmount],[TotalAmountPaid],[DiscountAmount],[CopaymentAmount],[COBAmount],[CoinsuranceAmount],[RefundAmount],[ClaimStatus],[Created],[Updated]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
ALTER TABLE [dbo].[MainClaimPayments] ADD  CONSTRAINT [DF_MainClaimPayments_Created]  DEFAULT (getutcdate()) FOR [Created]