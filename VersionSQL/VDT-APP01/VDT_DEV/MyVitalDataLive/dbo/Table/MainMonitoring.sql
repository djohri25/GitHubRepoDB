/****** Object:  Table [dbo].[MainMonitoring]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[MainMonitoring](
	[RecordNumber] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[ICENUMBER] [varchar](15) NULL,
	[MonitoringId] [int] NULL,
	[BaseLine] [varchar](50) NULL,
	[Goal] [varchar](50) NULL,
	[CreationDate] [datetime] NULL,
	[ModifyDate] [datetime] NULL,
 CONSTRAINT [PK_MainMonitoring] PRIMARY KEY CLUSTERED 
(
	[RecordNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[MainMonitoring]  WITH CHECK ADD  CONSTRAINT [FK_MainMonitoring_LookingMonitoring] FOREIGN KEY([MonitoringId])
REFERENCES [dbo].[LookupMonitoring] ([MonitoringId])
ALTER TABLE [dbo].[MainMonitoring] CHECK CONSTRAINT [FK_MainMonitoring_LookingMonitoring]
ALTER TABLE [dbo].[MainMonitoring]  WITH CHECK ADD  CONSTRAINT [FK_MainMonitoring_MainPersonalDetails] FOREIGN KEY([ICENUMBER])
REFERENCES [dbo].[MainPersonalDetails] ([ICENUMBER])
ON DELETE CASCADE
ALTER TABLE [dbo].[MainMonitoring] CHECK CONSTRAINT [FK_MainMonitoring_MainPersonalDetails]