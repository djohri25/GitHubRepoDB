/****** Object:  Table [dbo].[FIPS]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[FIPS](
	[CompositeKey] [nvarchar](10) NOT NULL,
	[FIPSStateCode] [nvarchar](2) NULL,
	[StateAlphaCode] [nvarchar](2) NULL,
	[FIPSCountyCode] [nvarchar](3) NULL,
	[NameCounty] [nvarchar](25) NULL,
	[FIPSPlaceCode] [nvarchar](5) NULL,
	[ClassCode] [nvarchar](2) NULL,
	[PlaceName] [nvarchar](100) NULL,
	[ZipCode] [nvarchar](5) NULL,
	[Status] [bit] NULL,
	[Last_Update] [datetime] NULL,
 CONSTRAINT [PK_FIPS] PRIMARY KEY CLUSTERED 
(
	[CompositeKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]