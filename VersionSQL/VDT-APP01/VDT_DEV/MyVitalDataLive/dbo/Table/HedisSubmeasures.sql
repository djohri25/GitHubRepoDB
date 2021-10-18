/****** Object:  Table [dbo].[HedisSubmeasures]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[HedisSubmeasures](
	[ID] [int] NOT NULL,
	[MeasureID] [int] NULL,
	[Name] [varchar](100) NOT NULL,
	[Abbreviation] [varchar](50) NOT NULL,
	[MeasurementStart] [varchar](4) NULL,
	[MeasurementEnd] [varchar](4) NULL,
 CONSTRAINT [PK_HedisSubmeasures] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]