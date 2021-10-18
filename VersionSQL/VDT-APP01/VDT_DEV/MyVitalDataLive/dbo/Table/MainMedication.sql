/****** Object:  Table [dbo].[MainMedication]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[MainMedication](
	[RecordNumber] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[ICENUMBER] [varchar](15) NULL,
	[StartDate] [datetime] NULL,
	[StopDate] [datetime] NULL,
	[RefillDate] [datetime] NULL,
	[PrescribedBy] [varchar](50) NULL,
	[DrugId] [varchar](1) NULL,
	[RxDrug] [varchar](100) NULL,
	[Code] [varchar](20) NULL,
	[CodingSystem] [varchar](50) NULL,
	[RxPharmacy] [varchar](100) NULL,
	[HowMuch] [varchar](50) NULL,
	[HowOften] [varchar](50) NULL,
	[WhyTaking] [varchar](50) NULL,
	[HVID] [char](36) NULL,
	[CreationDate] [datetime] NULL,
	[ModifyDate] [datetime] NULL,
	[ApproxDate] [bit] NULL,
	[HVFlag] [tinyint] NOT NULL,
	[ReadOnly] [bit] NULL,
	[CreatedBy] [nvarchar](250) NULL,
	[CreatedByOrganization] [varchar](250) NULL,
	[UpdatedBy] [nvarchar](250) NULL,
	[UpdatedByOrganization] [varchar](250) NULL,
	[UpdatedByContact] [nvarchar](64) NULL,
	[CreatedByNPI] [varchar](20) NULL,
	[UpdatedByNPI] [varchar](20) NULL,
	[Strength] [nvarchar](50) NULL,
	[Route] [nvarchar](50) NULL,
	[NDC_Last8]  AS (left([Code],(8))),
	[NDC_First9]  AS (left([Code],(9))),
	[DaysSupply] [int] NULL,
	[GPI] [varchar](100) NULL,
	[RXClaimNumber] [varchar](100) NULL,
 CONSTRAINT [PK_MainMedication] PRIMARY KEY CLUSTERED 
(
	[RecordNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [IX_MainMedication] ON [dbo].[MainMedication]
(
	[ICENUMBER] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [IX_MainMedication_1] ON [dbo].[MainMedication]
(
	[ICENUMBER] ASC,
	[RxDrug] ASC
)
INCLUDE([Code]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
CREATE NONCLUSTERED INDEX [IX_MainMedication_StartDate_ICENUMBER] ON [dbo].[MainMedication]
(
	[StartDate] ASC
)
INCLUDE([ICENUMBER]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
ALTER TABLE [dbo].[MainMedication] ADD  CONSTRAINT [DF_MainMedication_CreationDate]  DEFAULT (getutcdate()) FOR [CreationDate]
ALTER TABLE [dbo].[MainMedication] ADD  CONSTRAINT [DF_MainMedication_ModifyDate]  DEFAULT (getutcdate()) FOR [ModifyDate]
ALTER TABLE [dbo].[MainMedication] ADD  CONSTRAINT [DF__MainMedic__Appro__64B7E415]  DEFAULT ((0)) FOR [ApproxDate]
ALTER TABLE [dbo].[MainMedication] ADD  CONSTRAINT [DF_MainMedication_ReadOnly]  DEFAULT ((0)) FOR [HVFlag]
ALTER TABLE [dbo].[MainMedication] ADD  CONSTRAINT [DF_MainMedication_ReadOnly_1]  DEFAULT ((0)) FOR [ReadOnly]
ALTER TABLE [dbo].[MainMedication]  WITH CHECK ADD  CONSTRAINT [FK_MainMedication_LookupDrugType] FOREIGN KEY([DrugId])
REFERENCES [dbo].[LookupDrugType] ([DrugId])
ALTER TABLE [dbo].[MainMedication] CHECK CONSTRAINT [FK_MainMedication_LookupDrugType]
ALTER TABLE [dbo].[MainMedication]  WITH NOCHECK ADD  CONSTRAINT [FK_MainMedication_MainPersonalDetails] FOREIGN KEY([ICENUMBER])
REFERENCES [dbo].[MainPersonalDetails] ([ICENUMBER])
ON DELETE CASCADE
ALTER TABLE [dbo].[MainMedication] NOCHECK CONSTRAINT [FK_MainMedication_MainPersonalDetails]