/****** Object:  Table [dbo].[MainLabRequest]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[MainLabRequest](
	[RecordNumber] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[ICENUMBER] [varchar](15) NULL,
	[OrderID] [varchar](50) NULL,
	[OrderName] [varchar](200) NULL,
	[OrderCode] [varchar](20) NULL,
	[OrderCodingSystem] [varchar](50) NULL,
	[RequestDate] [datetime] NULL,
	[OrderingPhysicianFirstName] [varchar](50) NULL,
	[OrderingPhysicianLastName] [varchar](50) NULL,
	[OrderingPhysicianID] [varchar](50) NULL,
	[ProcedureName] [varchar](200) NULL,
	[ProcedureCode] [varchar](20) NULL,
	[ProcedureCodingSystem] [varchar](50) NULL,
	[CreationDate] [datetime] NULL,
	[CreatedBy] [nvarchar](250) NULL,
	[CreatedByOrganization] [varchar](250) NULL,
	[UpdatedBy] [nvarchar](250) NULL,
	[UpdatedByOrganization] [varchar](250) NULL,
	[UpdatedByContact] [nvarchar](64) NULL,
	[CreatedByNPI] [varchar](20) NULL,
	[UpdatedByNPI] [varchar](20) NULL,
	[SourceName] [varchar](50) NULL,
 CONSTRAINT [PK_MainLabRequest] PRIMARY KEY CLUSTERED 
(
	[RecordNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [IX_MainLabRequest_ICENUMBER] ON [dbo].[MainLabRequest]
(
	[ICENUMBER] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [IX_MainLabRequest_ICENUMBER_OrderID] ON [dbo].[MainLabRequest]
(
	[ICENUMBER] ASC,
	[OrderID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
ALTER TABLE [dbo].[MainLabRequest] ADD  CONSTRAINT [DF_MainObservationRequest_CreationDate]  DEFAULT (getutcdate()) FOR [CreationDate]
ALTER TABLE [dbo].[MainLabRequest]  WITH CHECK ADD  CONSTRAINT [FK_MainLabRequest_MainPersonalDetails] FOREIGN KEY([ICENUMBER])
REFERENCES [dbo].[MainPersonalDetails] ([ICENUMBER])
ON DELETE CASCADE
ALTER TABLE [dbo].[MainLabRequest] CHECK CONSTRAINT [FK_MainLabRequest_MainPersonalDetails]