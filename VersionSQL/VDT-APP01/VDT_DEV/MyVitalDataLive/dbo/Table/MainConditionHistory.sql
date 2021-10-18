/****** Object:  Table [dbo].[MainConditionHistory]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[MainConditionHistory](
	[RecordNumber] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[ICENUMBER] [varchar](15) NOT NULL,
	[ConditionId] [int] NULL,
	[OtherName] [nvarchar](50) NULL,
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
	[Taxonomy] [varchar](50) NULL,
 CONSTRAINT [PK_MainConditionHistory_NEW] PRIMARY KEY CLUSTERED 
(
	[RecordNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [IX_MainConditionHistory_NEW] ON [dbo].[MainConditionHistory]
(
	[ICENUMBER] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
ALTER TABLE [dbo].[MainConditionHistory] ADD  CONSTRAINT [DF_MainConditionHistory_NEW_CreationDate]  DEFAULT (getutcdate()) FOR [CreationDate]
ALTER TABLE [dbo].[MainConditionHistory] ADD  CONSTRAINT [DF_MainConditionHistory_NEW_HVFlag]  DEFAULT ((0)) FOR [HVFlag]
ALTER TABLE [dbo].[MainConditionHistory] ADD  CONSTRAINT [DF_MainConditionHistory_NEW_ReadOnly]  DEFAULT ((0)) FOR [ReadOnly]
ALTER TABLE [dbo].[MainConditionHistory] ADD  CONSTRAINT [DF_MainConditionHistory_NEW_DateModified]  DEFAULT (getutcdate()) FOR [ModifyDate]
ALTER TABLE [dbo].[MainConditionHistory]  WITH NOCHECK ADD  CONSTRAINT [FK_MainConditionHistory_NEW_MainPersonalDetails] FOREIGN KEY([ICENUMBER])
REFERENCES [dbo].[MainPersonalDetails] ([ICENUMBER])
ON UPDATE CASCADE
ON DELETE CASCADE
ALTER TABLE [dbo].[MainConditionHistory] NOCHECK CONSTRAINT [FK_MainConditionHistory_NEW_MainPersonalDetails]