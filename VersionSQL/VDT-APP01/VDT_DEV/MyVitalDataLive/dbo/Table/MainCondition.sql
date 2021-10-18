/****** Object:  Table [dbo].[MainCondition]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[MainCondition](
	[RecordNumber] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[ICENUMBER] [varchar](15) NOT NULL,
	[ConditionId] [int] NULL,
	[OtherName] [nvarchar](1000) NULL,
	[Code] [varchar](20) NULL,
	[CodingSystem] [varchar](50) NULL,
	[ReportDate] [datetime] NULL,
	[CreationDate] [datetime] NULL,
	[CreatedBy] [nvarchar](250) NULL,
	[CreatedByOrganization] [varchar](250) NULL,
	[UpdatedBy] [nvarchar](250) NULL,
	[UpdatedByOrganization] [varchar](250) NULL,
	[UpdatedByContact] [nvarchar](64) NULL,
	[CreatedByNPI] [varchar](100) NULL,
	[UpdatedByNPI] [varchar](100) NULL,
	[HVID] [char](36) NULL,
	[HVFlag] [tinyint] NOT NULL,
	[ReadOnly] [bit] NULL,
	[ModifyDate] [datetime] NULL,
	[LabDataRefID] [int] NULL,
	[LabDataSourceName] [varchar](50) NULL,
	[CodeFirst3]  AS (left([Code],(3))),
	[RevCode] [varchar](20) NULL,
	[BillType] [varchar](3) NULL,
	[POS] [varchar](5) NULL,
	[DRGCode] [varchar](5) NULL,
	[IsPrincipal] [bit] NULL,
	[DischargeStatus] [varchar](10) NULL,
	[AdmissionDate] [datetime] NULL,
	[DischargeDate] [datetime] NULL,
	[ClaimID] [int] NULL,
 CONSTRAINT [PK_MainCondition] PRIMARY KEY CLUSTERED 
(
	[RecordNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [IX_MainCondition_Code] ON [dbo].[MainCondition]
(
	[Code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
SET ARITHABORT ON
SET CONCAT_NULL_YIELDS_NULL ON
SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
SET NUMERIC_ROUNDABORT OFF

CREATE NONCLUSTERED INDEX [IX_MainCondition_CodeFirst3] ON [dbo].[MainCondition]
(
	[CodeFirst3] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
CREATE NONCLUSTERED INDEX [IX_MainCondition_DD] ON [dbo].[MainCondition]
(
	[DischargeDate] ASC
)
INCLUDE([ICENUMBER],[ReportDate],[BillType],[POS],[AdmissionDate],[ClaimID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [IX_MainCondition_ICENUMBER] ON [dbo].[MainCondition]
(
	[ICENUMBER] ASC
)
INCLUDE([Code],[RecordNumber]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [IX_MainCondition_OtherName] ON [dbo].[MainCondition]
(
	[OtherName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
CREATE NONCLUSTERED INDEX [IX_MainCondition_ReportDate_INCLUDE_ICENUMBER_Code] ON [dbo].[MainCondition]
(
	[ReportDate] ASC
)
INCLUDE([ICENUMBER],[Code]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
CREATE NONCLUSTERED INDEX [IX_NCI_MainCondition_DD] ON [dbo].[MainCondition]
(
	[ClaimID] ASC,
	[DischargeDate] ASC
)
INCLUDE([ICENUMBER],[ReportDate],[BillType],[POS],[AdmissionDate]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
CREATE NONCLUSTERED INDEX [IX_NCI_MainCondition_ISPrincipal_MVIDCodeDate] ON [dbo].[MainCondition]
(
	[IsPrincipal] ASC
)
INCLUDE([ICENUMBER],[Code],[ReportDate]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
CREATE NONCLUSTERED INDEX [IX_NCI_MainCondition_Report_DischargeDates] ON [dbo].[MainCondition]
(
	[ReportDate] ASC,
	[DischargeDate] ASC
)
INCLUDE([ICENUMBER],[BillType],[POS],[AdmissionDate]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
CREATE NONCLUSTERED INDEX [IX_NCI_MainCondition_ReportDate_ICENUm] ON [dbo].[MainCondition]
(
	[ReportDate] ASC
)
INCLUDE([ICENUMBER]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
ALTER TABLE [dbo].[MainCondition] ADD  CONSTRAINT [DF_MainCondition_CreationDate]  DEFAULT (getutcdate()) FOR [CreationDate]
ALTER TABLE [dbo].[MainCondition] ADD  CONSTRAINT [DF_MainCondition_HVFlag]  DEFAULT ((0)) FOR [HVFlag]
ALTER TABLE [dbo].[MainCondition] ADD  CONSTRAINT [DF_MainCondition_ReadOnly]  DEFAULT ((0)) FOR [ReadOnly]
ALTER TABLE [dbo].[MainCondition] ADD  CONSTRAINT [DF_MainCondition_DateModified]  DEFAULT (getutcdate()) FOR [ModifyDate]
ALTER TABLE [dbo].[MainCondition]  WITH NOCHECK ADD  CONSTRAINT [FK_MainCondition_MainPersonalDetails] FOREIGN KEY([ICENUMBER])
REFERENCES [dbo].[MainPersonalDetails] ([ICENUMBER])
ON UPDATE CASCADE
ON DELETE CASCADE
ALTER TABLE [dbo].[MainCondition] NOCHECK CONSTRAINT [FK_MainCondition_MainPersonalDetails]