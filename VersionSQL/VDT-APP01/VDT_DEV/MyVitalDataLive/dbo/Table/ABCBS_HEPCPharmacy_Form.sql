/****** Object:  Table [dbo].[ABCBS_HEPCPharmacy_Form]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[ABCBS_HEPCPharmacy_Form](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[MVDID] [varchar](20) NOT NULL,
	[FormDate] [datetime] NOT NULL,
	[FormAuthor] [varchar](100) NOT NULL,
	[CaseID] [varchar](100) NULL,
	[q1CMContact] [varchar](max) NULL,
	[q2DateOfMemberContact] [datetime] NULL,
	[q3PrescriptionDrugAwareness] [varchar](max) NULL,
	[q4MemberDrugReady] [varchar](max) NULL,
	[q5WillingToAdhere] [varchar](max) NULL,
	[q6CMParticipation] [varchar](max) NULL,
	[q7MedicationNames] [varchar](max) NULL,
	[q8FinancialResponsibility] [varchar](max) NULL,
	[q9FinancialBarriers] [varchar](max) NULL,
	[q9DescribeFinancialBarriers] [varchar](max) NULL,
	[q10CMNotifyPharmacy] [varchar](max) NULL,
	[q11PharmacyNotifyDate] [datetime] NULL,
	[q12Comments] [varchar](max) NULL,
	[LastModifiedDate] [datetime] NULL,
	[IsLocked] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_ABCBS_HEPCPharmacy_Form] ON [dbo].[ABCBS_HEPCPharmacy_Form]
(
	[ID] ASC
)
INCLUDE([FormDate],[IsLocked]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
CREATE NONCLUSTERED INDEX [IX_ABCBS_HEPCPharmacy_Form_FormDate] ON [dbo].[ABCBS_HEPCPharmacy_Form]
(
	[FormDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
ALTER TABLE [dbo].[ABCBS_HEPCPharmacy_Form] ADD  DEFAULT (getdate()) FOR [LastModifiedDate]