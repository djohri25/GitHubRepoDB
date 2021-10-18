/****** Object:  Table [dbo].[SubMonitoring]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[SubMonitoring](
	[RecordNumber] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[ICENUMBER] [varchar](15) NULL,
	[MonitoringId] [int] NULL,
	[MonitoringDate] [datetime] NULL,
	[MonitoringResult] [varchar](50) NULL,
	[CreationDate] [datetime] NULL,
	[ModifyDate] [datetime] NULL,
	[HVID] [char](36) NULL,
	[HVFlag] [tinyint] NOT NULL,
	[ReadOnly] [bit] NULL,
	[CreatedBy] [nvarchar](250) NULL,
	[CreatedByOrganization] [varchar](250) NULL,
	[UpdatedBy] [nvarchar](250) NULL,
	[UpdatedByOrganization] [varchar](250) NULL,
 CONSTRAINT [PK_SubMonitoring] PRIMARY KEY CLUSTERED 
(
	[RecordNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[SubMonitoring] ADD  CONSTRAINT [DF_SubMonitoring_CreationDate]  DEFAULT (getutcdate()) FOR [CreationDate]
ALTER TABLE [dbo].[SubMonitoring] ADD  CONSTRAINT [DF_SubMonitoring_ModifyDate]  DEFAULT (getutcdate()) FOR [ModifyDate]
ALTER TABLE [dbo].[SubMonitoring] ADD  CONSTRAINT [DF_SubMonitoring_HVFlag]  DEFAULT ((0)) FOR [HVFlag]
ALTER TABLE [dbo].[SubMonitoring] ADD  CONSTRAINT [DF_SubMonitoring_ReadOnly]  DEFAULT ((0)) FOR [ReadOnly]
ALTER TABLE [dbo].[SubMonitoring]  WITH CHECK ADD  CONSTRAINT [FK_SubMonitoring_LookupMonitoring] FOREIGN KEY([MonitoringId])
REFERENCES [dbo].[LookupMonitoring] ([MonitoringId])
ALTER TABLE [dbo].[SubMonitoring] CHECK CONSTRAINT [FK_SubMonitoring_LookupMonitoring]
ALTER TABLE [dbo].[SubMonitoring]  WITH CHECK ADD  CONSTRAINT [FK_SubMonitoring_MainPersonalDetails] FOREIGN KEY([ICENUMBER])
REFERENCES [dbo].[MainPersonalDetails] ([ICENUMBER])
ON DELETE CASCADE
ALTER TABLE [dbo].[SubMonitoring] CHECK CONSTRAINT [FK_SubMonitoring_MainPersonalDetails]