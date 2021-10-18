/****** Object:  Table [dbo].[DataScienceMeasurement]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[DataScienceMeasurement](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](255) NULL,
	[Description] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]