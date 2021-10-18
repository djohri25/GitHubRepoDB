/****** Object:  Table [API].[Weather]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [API].[Weather](
	[WeatherId] [int] IDENTITY(1,1) NOT NULL,
	[Date] [datetime] NOT NULL,
	[TemperatureC] [int] NOT NULL,
	[TemperatureF] [int] NOT NULL,
	[Summary] [varchar](50) NULL,
 CONSTRAINT [PK_Weather_1] PRIMARY KEY CLUSTERED 
(
	[WeatherId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]