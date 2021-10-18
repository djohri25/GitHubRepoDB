/****** Object:  Table [dbo].[LookupCountyName]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[LookupCountyName](
	[st] [varchar](50) NULL,
	[county_name] [varchar](50) NULL,
	[geo_region_cd] [varchar](50) NULL,
	[fips_county_cd] [varchar](50) NULL,
	[rbms_county_cd] [varchar](50) NULL,
	[region_st_cd] [varchar](50) NULL,
	[medicare_st_county_cd] [varchar](50) NULL,
	[medicare_county_cd] [varchar](50) NULL,
	[audit_key] [varchar](50) NULL,
	[LoadDate] [datetime] NULL,
	[recordID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
 CONSTRAINT [PK_LookupCountyName] PRIMARY KEY CLUSTERED 
(
	[recordID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]