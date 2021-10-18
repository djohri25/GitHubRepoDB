/****** Object:  Table [dbo].[LookUp_CountyRegion]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[LookUp_CountyRegion](
	[State_Code] [varchar](2) NOT NULL,
	[County_Name] [varchar](max) NOT NULL,
	[Geo_Region_Code] [int] NULL,
	[FIPS_County_Code] [int] NULL,
	[Region_Name] [varchar](max) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]