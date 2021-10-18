/****** Object:  Table [dbo].[Lookup_Zipcode]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Lookup_Zipcode](
	[zip] [varchar](50) NOT NULL,
	[type] [varchar](50) NOT NULL,
	[decommissioned] [int] NOT NULL,
	[primary_city] [varchar](max) NOT NULL,
	[acceptable_cities] [varchar](max) NULL,
	[unacceptable_cities] [varchar](max) NULL,
	[state] [varchar](50) NOT NULL,
	[county] [varchar](50) NULL,
	[timezone] [varchar](50) NULL,
	[area_codes] [varchar](50) NULL,
	[world_region] [varchar](50) NULL,
	[country] [varchar](50) NULL,
	[latitude] [float] NULL,
	[longitude] [float] NULL,
	[irs_estimated_population_2015] [int] NULL,
 CONSTRAINT [PK_lookup_zipcode] PRIMARY KEY CLUSTERED 
(
	[zip] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]