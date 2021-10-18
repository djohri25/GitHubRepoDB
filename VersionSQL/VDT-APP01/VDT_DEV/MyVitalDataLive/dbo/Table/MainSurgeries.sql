/****** Object:  Table [dbo].[MainSurgeries]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[MainSurgeries](
	[RecordNumber] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[ICENUMBER] [varchar](15) NULL,
	[YearDate] [datetime] NULL,
	[Condition] [varchar](50) NULL,
	[Treatment] [varchar](150) NULL,
	[Code] [varchar](20) NULL,
	[CodingSystem] [varchar](50) NULL,
	[HVID] [char](36) NULL,
	[CreationDate] [datetime] NULL,
	[ModifyDate] [datetime] NULL,
	[HVFlag] [tinyint] NOT NULL,
	[ReadOnly] [bit] NULL,
	[CreatedBy] [nvarchar](250) NULL,
	[CreatedByOrganization] [varchar](250) NULL,
	[UpdatedBy] [nvarchar](250) NULL,
	[UpdatedByOrganization] [varchar](250) NULL,
	[UpdatedByContact] [nvarchar](64) NULL,
	[CreatedByNPI] [varchar](100) NULL,
	[UpdatedByNPI] [varchar](100) NULL,
	[RevCode] [varchar](20) NULL,
	[BillType] [varchar](3) NULL,
	[POS] [varchar](5) NULL,
	[DRGCode] [varchar](5) NULL,
	[DischargeStatus] [varchar](10) NULL,
	[AdmissionDate] [datetime] NULL,
	[DischargeDate] [datetime] NULL,
	[ClaimID] [int] NULL,
	[LineNumber] [int] NULL,
 CONSTRAINT [PK_MainSurgeries] PRIMARY KEY CLUSTERED 
(
	[RecordNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [IX_MainSurgeries] ON [dbo].[MainSurgeries]
(
	[ICENUMBER] ASC,
	[Code] ASC
)
INCLUDE([RecordNumber],[YearDate]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [IX_NCI_MainSurgeries_ICE_date] ON [dbo].[MainSurgeries]
(
	[ICENUMBER] ASC
)
INCLUDE([YearDate],[Treatment]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
ALTER TABLE [dbo].[MainSurgeries] ADD  CONSTRAINT [DF_MainSurgeries_HVFlag]  DEFAULT ((0)) FOR [HVFlag]
ALTER TABLE [dbo].[MainSurgeries] ADD  CONSTRAINT [DF_MainSurgeries_ReadOnly]  DEFAULT ((0)) FOR [ReadOnly]
ALTER TABLE [dbo].[MainSurgeries]  WITH NOCHECK ADD  CONSTRAINT [FK_MainSurgeries_MainPersonalDetails] FOREIGN KEY([ICENUMBER])
REFERENCES [dbo].[MainPersonalDetails] ([ICENUMBER])
ON DELETE CASCADE
ALTER TABLE [dbo].[MainSurgeries] NOCHECK CONSTRAINT [FK_MainSurgeries_MainPersonalDetails]