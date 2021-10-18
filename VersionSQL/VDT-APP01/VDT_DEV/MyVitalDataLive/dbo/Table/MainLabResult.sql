/****** Object:  Table [dbo].[MainLabResult]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[MainLabResult](
	[RecordNumber] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[ICENUMBER] [varchar](15) NULL,
	[OrderID] [varchar](50) NULL,
	[ResultID] [int] NULL,
	[ResultName] [varchar](200) NULL,
	[Code] [varchar](20) NULL,
	[CodingSystem] [varchar](50) NULL,
	[ResultValue] [varchar](200) NULL,
	[ResultUnits] [varchar](50) NULL,
	[RangeLow] [varchar](50) NULL,
	[RangeHigh] [varchar](50) NULL,
	[RangeAlpha] [varchar](50) NULL,
	[AbnormalFlag] [varchar](50) NULL,
	[ReportedDate] [datetime] NULL,
	[Notes] [varchar](4000) NULL,
	[CreationDate] [datetime] NULL,
	[CreatedBy] [nvarchar](250) NULL,
	[CreatedByOrganization] [varchar](250) NULL,
	[UpdatedBy] [nvarchar](250) NULL,
	[UpdatedByOrganization] [varchar](250) NULL,
	[UpdatedByContact] [nvarchar](64) NULL,
	[CreatedByNPI] [varchar](20) NULL,
	[UpdatedByNPI] [varchar](20) NULL,
	[SourceName] [varchar](50) NULL,
 CONSTRAINT [PK_MainLabResult] PRIMARY KEY CLUSTERED 
(
	[RecordNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [IX_MainLabResult_Code] ON [dbo].[MainLabResult]
(
	[Code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [IX_MainLabResult_ICENUMBER] ON [dbo].[MainLabResult]
(
	[ICENUMBER] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [IX_MainLabResult_ICENUMBER_OrderID] ON [dbo].[MainLabResult]
(
	[ICENUMBER] ASC,
	[OrderID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
ALTER TABLE [dbo].[MainLabResult] ADD  CONSTRAINT [DF_MainLabResult_CreationDate]  DEFAULT (getutcdate()) FOR [CreationDate]
ALTER TABLE [dbo].[MainLabResult]  WITH CHECK ADD  CONSTRAINT [FK_MainLabResult_MainPersonalDetails] FOREIGN KEY([ICENUMBER])
REFERENCES [dbo].[MainPersonalDetails] ([ICENUMBER])
ON DELETE CASCADE
ALTER TABLE [dbo].[MainLabResult] CHECK CONSTRAINT [FK_MainLabResult_MainPersonalDetails]