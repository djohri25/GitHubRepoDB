/****** Object:  Table [dbo].[StarMeasures]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[StarMeasures](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](100) NOT NULL,
	[Abbreviation] [varchar](5) NOT NULL,
	[1Star] [int] NULL,
	[2Star] [int] NULL,
	[3Star] [int] NULL,
	[4Star] [int] NULL,
 CONSTRAINT [PK_StarMeasures] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]