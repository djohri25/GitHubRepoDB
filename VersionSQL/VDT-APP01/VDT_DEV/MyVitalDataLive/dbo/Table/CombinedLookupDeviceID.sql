/****** Object:  Table [dbo].[CombinedLookupDeviceID]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[CombinedLookupDeviceID](
	[CombinedDeviceID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[DeviceID] [int] NULL,
	[DeviceLocationID] [int] NULL,
 CONSTRAINT [PK_LookupCombinedDeviceID] PRIMARY KEY CLUSTERED 
(
	[CombinedDeviceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[CombinedLookupDeviceID]  WITH CHECK ADD  CONSTRAINT [FK_CombinedLookupDeviceID_LookupDeviceID] FOREIGN KEY([DeviceID])
REFERENCES [dbo].[LookupDeviceID] ([DeviceID])
ALTER TABLE [dbo].[CombinedLookupDeviceID] CHECK CONSTRAINT [FK_CombinedLookupDeviceID_LookupDeviceID]
ALTER TABLE [dbo].[CombinedLookupDeviceID]  WITH CHECK ADD  CONSTRAINT [FK_CombinedLookupDeviceID_LookupDeviceLocationID] FOREIGN KEY([DeviceLocationID])
REFERENCES [dbo].[LookupDeviceLocationID] ([DeviceLocationID])
ALTER TABLE [dbo].[CombinedLookupDeviceID] CHECK CONSTRAINT [FK_CombinedLookupDeviceID_LookupDeviceLocationID]