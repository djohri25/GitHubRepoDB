/****** Object:  Table [dbo].[DeployedMobileDevices]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[DeployedMobileDevices](
	[RecordNumber] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[ICEGROUP] [varchar](15) NOT NULL,
	[DeviceID] [varchar](50) NOT NULL,
	[DeviceKey] [uniqueidentifier] NOT NULL,
	[Enabled] [bit] NOT NULL,
	[DateCreated] [datetime] NOT NULL,
	[DateAccessed] [datetime] NOT NULL,
 CONSTRAINT [PK_DeployedMobileApps] PRIMARY KEY CLUSTERED 
(
	[RecordNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[DeployedMobileDevices] ADD  CONSTRAINT [DF_DeployedMobileDevices_IsActive]  DEFAULT ((1)) FOR [Enabled]
ALTER TABLE [dbo].[DeployedMobileDevices] ADD  CONSTRAINT [DF_DeployedMobileApps_DateCreated]  DEFAULT (getutcdate()) FOR [DateCreated]
ALTER TABLE [dbo].[DeployedMobileDevices] ADD  CONSTRAINT [DF_DeployedMobileApps_DateAccessed]  DEFAULT (getutcdate()) FOR [DateAccessed]