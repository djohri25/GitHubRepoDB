/****** Object:  Table [dbo].[LookupHospitalListGPS]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[LookupHospitalListGPS](
	[Cust_ID] [int] NULL,
	[HospitalName] [nvarchar](255) NULL,
	[HospitalGroup] [nvarchar](255) NULL,
	[Address] [nvarchar](255) NULL,
	[City] [nvarchar](255) NULL,
	[State] [nvarchar](255) NULL,
	[ZIP] [nvarchar](255) NULL,
	[County] [nvarchar](255) NULL,
	[Phone] [nvarchar](255) NULL,
	[ERNumber] [nvarchar](255) NULL,
	[HoursOfOperation] [nvarchar](255) NULL,
	[Latitude] [float] NULL,
	[Longitude] [float] NULL,
	[CreationDate] [datetime] NULL,
	[ModifyDate] [datetime] NULL,
	[Hospital_ID] [int] NOT NULL
) ON [PRIMARY]