/****** Object:  Table [dbo].[LookupDeviceID]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[LookupDeviceID](
	[DeviceID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[DeviceName] [varchar](50) NULL,
	[DeviceNameSpanish] [varchar](100) NULL,
 CONSTRAINT [PK_LookupDeviceID] PRIMARY KEY CLUSTERED 
(
	[DeviceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]