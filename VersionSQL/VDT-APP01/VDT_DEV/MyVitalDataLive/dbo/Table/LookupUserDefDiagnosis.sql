/****** Object:  Table [dbo].[LookupUserDefDiagnosis]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[LookupUserDefDiagnosis](
	[Code] [varchar](6) NOT NULL,
	[CodingSystem] [varchar](10) NULL,
	[Description] [varchar](50) NULL,
	[Modified] [datetime] NULL,
	[Created] [datetime] NULL,
	[IsProcessed] [bit] NULL,
	[ProcessedDate] [datetime] NULL,
 CONSTRAINT [PK_LookupUserDefDiagnosis] PRIMARY KEY CLUSTERED 
(
	[Code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_LookupUserDefDiagnosis_IsProcessed] ON [dbo].[LookupUserDefDiagnosis]
(
	[IsProcessed] ASC
)
INCLUDE([Code]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
ALTER TABLE [dbo].[LookupUserDefDiagnosis] ADD  CONSTRAINT [DF_LookupUserDefDiagnosis_Created]  DEFAULT (getutcdate()) FOR [Created]
ALTER TABLE [dbo].[LookupUserDefDiagnosis] ADD  CONSTRAINT [DF_LookupUserDefDiagnosis_IsProcessed]  DEFAULT ((0)) FOR [IsProcessed]