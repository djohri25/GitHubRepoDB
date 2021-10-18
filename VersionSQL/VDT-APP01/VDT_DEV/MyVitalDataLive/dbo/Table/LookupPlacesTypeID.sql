/****** Object:  Table [dbo].[LookupPlacesTypeID]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[LookupPlacesTypeID](
	[PlacesTypeID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[PlacesTypeName] [varchar](50) NULL,
	[PlacesTypeNameSpanish] [nvarchar](100) NULL,
 CONSTRAINT [PK_LookupPlacesTypeID] PRIMARY KEY CLUSTERED 
(
	[PlacesTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]