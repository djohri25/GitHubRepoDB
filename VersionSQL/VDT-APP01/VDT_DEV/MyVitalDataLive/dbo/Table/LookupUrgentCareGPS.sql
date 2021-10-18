/****** Object:  Table [dbo].[LookupUrgentCareGPS]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[LookupUrgentCareGPS](
	[UrgentCareCenters_ID] [int] IDENTITY(1,1) NOT NULL,
	[Cust_ID] [int] NOT NULL,
	[County] [nvarchar](255) NULL,
	[ProviderName] [nvarchar](255) NULL,
	[Group] [nvarchar](255) NULL,
	[Address] [nvarchar](255) NULL,
	[City] [nvarchar](255) NULL,
	[State] [nvarchar](255) NULL,
	[Zip] [nvarchar](255) NULL,
	[Phone] [nvarchar](255) NULL,
	[HoursOfOperation] [nvarchar](255) NULL,
	[SeeAdultsAfterHrs] [nvarchar](255) NULL,
	[Latitude] [float] NULL,
	[Longitude] [float] NULL,
	[CreationDate] [datetime] NOT NULL,
	[ModifyDate] [datetime] NULL
) ON [PRIMARY]

ALTER TABLE [dbo].[LookupUrgentCareGPS] ADD  CONSTRAINT [DF_LookupUrgentCareGPS_CreationDate]  DEFAULT (getutcdate()) FOR [CreationDate]
ALTER TABLE [dbo].[LookupUrgentCareGPS] ADD  CONSTRAINT [DF_LookupUrgentCareGPS_ModifyDate]  DEFAULT (getutcdate()) FOR [ModifyDate]