/****** Object:  Table [dbo].[MainMedicationHistory]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[MainMedicationHistory](
	[RecordNumber] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[ICENUMBER] [varchar](15) NULL,
	[FillDate] [datetime] NULL,
	[PrescribedBy] [varchar](50) NULL,
	[DrugId] [varchar](1) NULL,
	[RxDrug] [varchar](100) NULL,
	[Code] [varchar](20) NULL,
	[CodingSystem] [varchar](50) NULL,
	[RxPharmacy] [varchar](100) NULL,
	[CreationDate] [datetime] NULL,
	[ImportRecordID] [int] NULL,
	[CreatedBy] [varchar](250) NULL,
	[CreatedByOrganization] [varchar](250) NULL,
	[CreatedByContact] [varchar](50) NULL,
	[CreatedByNPI] [varchar](20) NULL,
	[DaysSupply] [int] NULL,
 CONSTRAINT [PK_MainMedicationHistory] PRIMARY KEY NONCLUSTERED 
(
	[RecordNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

SET ANSI_PADDING ON

CREATE CLUSTERED INDEX [IX_MainMedicationHistory] ON [dbo].[MainMedicationHistory]
(
	[ICENUMBER] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
CREATE NONCLUSTERED INDEX [IX_MainMedicationHistory_1] ON [dbo].[MainMedicationHistory]
(
	[ImportRecordID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
ALTER TABLE [dbo].[MainMedicationHistory] ADD  CONSTRAINT [DF_MainMedicationHistory_CreationDate]  DEFAULT (getutcdate()) FOR [CreationDate]
ALTER TABLE [dbo].[MainMedicationHistory]  WITH CHECK ADD  CONSTRAINT [FK_MainMedicationHistory_LookupDrugType] FOREIGN KEY([DrugId])
REFERENCES [dbo].[LookupDrugType] ([DrugId])
ALTER TABLE [dbo].[MainMedicationHistory] CHECK CONSTRAINT [FK_MainMedicationHistory_LookupDrugType]
ALTER TABLE [dbo].[MainMedicationHistory]  WITH NOCHECK ADD  CONSTRAINT [FK_MainMedicationHistory_MainPersonalDetails] FOREIGN KEY([ICENUMBER])
REFERENCES [dbo].[MainPersonalDetails] ([ICENUMBER])
ON DELETE CASCADE
ALTER TABLE [dbo].[MainMedicationHistory] NOCHECK CONSTRAINT [FK_MainMedicationHistory_MainPersonalDetails]