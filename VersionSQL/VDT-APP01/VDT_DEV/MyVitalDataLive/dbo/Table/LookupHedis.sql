/****** Object:  Table [dbo].[LookupHedis]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[LookupHedis](
	[ID] [int] NOT NULL,
	[TestID] [int] NULL,
	[Name] [varchar](100) NULL,
	[Abbreviation] [varchar](50) NULL,
	[TestType] [varchar](50) NULL,
	[MeasuramentYearStart] [date] NULL,
	[MeasuramentYearEnd] [date] NULL,
 CONSTRAINT [PK_LookupHedis] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [IX_LookupHedis_Abv] ON [dbo].[LookupHedis]
(
	[Abbreviation] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]