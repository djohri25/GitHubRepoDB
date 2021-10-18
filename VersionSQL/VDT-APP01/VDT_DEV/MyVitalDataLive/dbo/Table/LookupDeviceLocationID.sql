/****** Object:  Table [dbo].[LookupDeviceLocationID]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[LookupDeviceLocationID](
	[DeviceLocationID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[DeviceLocationName] [varchar](50) NULL,
	[DeviceLocationNameSpanish] [varchar](100) NULL,
 CONSTRAINT [PK_LookupDeviceLocationID] PRIMARY KEY CLUSTERED 
(
	[DeviceLocationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]