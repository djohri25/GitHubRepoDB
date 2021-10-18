/****** Object:  Table [dbo].[MainMedicationPayments]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[MainMedicationPayments](
	[RecordNumber] [int] IDENTITY(1,1) NOT NULL,
	[ICENUMBER] [varchar](30) NULL,
	[FillDate] [datetime] NULL,
	[RXClaimNumber] [varchar](60) NULL,
	[BilledAmount] [decimal](18, 2) NULL,
	[PlanPaidAmount] [decimal](18, 2) NULL,
	[PatientPaidAmount] [decimal](18, 2) NULL,
	[CLAIM_TYPE] [varchar](10) NULL,
	[CreateDate] [datetime] NULL,
	[UpdateDate] [datetime] NULL,
 CONSTRAINT [PK_MainMedicationPayments_ID] PRIMARY KEY CLUSTERED 
(
	[RecordNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_MainMedicationPayments_FillDate] ON [dbo].[MainMedicationPayments]
(
	[FillDate] ASC
)
INCLUDE([ICENUMBER],[BilledAmount]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [IX_MainMedicationPayments_IceNumber] ON [dbo].[MainMedicationPayments]
(
	[ICENUMBER] ASC
)
INCLUDE([FillDate],[BilledAmount]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [IX_MainMedicationPayments_RXClaimNumber] ON [dbo].[MainMedicationPayments]
(
	[RXClaimNumber] ASC
)
INCLUDE([RecordNumber],[PlanPaidAmount]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
ALTER TABLE [dbo].[MainMedicationPayments] ADD  DEFAULT (getutcdate()) FOR [CreateDate]