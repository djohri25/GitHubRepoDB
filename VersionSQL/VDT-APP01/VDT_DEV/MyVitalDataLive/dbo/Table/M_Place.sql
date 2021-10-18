/****** Object:  Table [dbo].[M_Place]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[M_Place](
	[PlaceID] [int] NOT NULL,
	[Address] [nvarchar](50) NOT NULL,
	[City] [nvarchar](50) NOT NULL,
	[State] [nvarchar](50) NOT NULL,
	[ZipCode] [nvarchar](10) NOT NULL,
	[Country] [nvarchar](50) NOT NULL,
	[Phone] [nvarchar](25) NOT NULL,
	[Fax] [nvarchar](25) NOT NULL,
	[Web] [nvarchar](50) NULL,
 CONSTRAINT [PK_Place] PRIMARY KEY CLUSTERED 
(
	[PlaceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]