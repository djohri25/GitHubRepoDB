/****** Object:  Table [dbo].[MainAssistiveDevices]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[MainAssistiveDevices](
	[RecordNumber] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[ICENUMBER] [varchar](15) NOT NULL,
	[CombinedDeviceID] [int] NULL,
	[CreationDate] [datetime] NULL,
	[ModifyDate] [datetime] NULL,
 CONSTRAINT [PK_MainAssistiveDevices] PRIMARY KEY CLUSTERED 
(
	[RecordNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [DeviceId] ON [dbo].[MainAssistiveDevices]
(
	[CombinedDeviceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [IX_MainAssistiveDevices] ON [dbo].[MainAssistiveDevices]
(
	[ICENUMBER] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
ALTER TABLE [dbo].[MainAssistiveDevices]  WITH CHECK ADD  CONSTRAINT [FK_MainAssistiveDevices_CombinedLookupDeviceID] FOREIGN KEY([CombinedDeviceID])
REFERENCES [dbo].[CombinedLookupDeviceID] ([CombinedDeviceID])
ALTER TABLE [dbo].[MainAssistiveDevices] CHECK CONSTRAINT [FK_MainAssistiveDevices_CombinedLookupDeviceID]
ALTER TABLE [dbo].[MainAssistiveDevices]  WITH CHECK ADD  CONSTRAINT [FK_MainAssistiveDevices_MainPersonalDetails] FOREIGN KEY([ICENUMBER])
REFERENCES [dbo].[MainPersonalDetails] ([ICENUMBER])
ON UPDATE CASCADE
ON DELETE CASCADE
ALTER TABLE [dbo].[MainAssistiveDevices] CHECK CONSTRAINT [FK_MainAssistiveDevices_MainPersonalDetails]