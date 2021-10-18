/****** Object:  Table [dbo].[HedisMeasures]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[HedisMeasures](
	[ID] [int] NOT NULL,
	[Name] [varchar](100) NOT NULL,
	[Abbreviation] [varchar](5) NOT NULL,
 CONSTRAINT [PK_HedisMeasures_ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]