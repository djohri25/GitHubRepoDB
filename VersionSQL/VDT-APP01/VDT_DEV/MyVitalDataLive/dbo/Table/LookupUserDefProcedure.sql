/****** Object:  Table [dbo].[LookupUserDefProcedure]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[LookupUserDefProcedure](
	[Code] [varchar](15) NOT NULL,
	[CodingSystem] [varchar](10) NULL,
	[Description] [varchar](100) NULL,
	[Modified] [datetime] NULL,
	[Created] [datetime] NULL,
	[IsProcessed] [bit] NULL,
	[ProcessedDate] [datetime] NULL,
 CONSTRAINT [PK_LookupUserDefProcedure] PRIMARY KEY CLUSTERED 
(
	[Code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_LookupUserDefProcedure_IsProcessed] ON [dbo].[LookupUserDefProcedure]
(
	[IsProcessed] ASC
)
INCLUDE([Code]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
ALTER TABLE [dbo].[LookupUserDefProcedure] ADD  CONSTRAINT [DF_LookupUserDefProcedure_Created]  DEFAULT (getutcdate()) FOR [Created]
ALTER TABLE [dbo].[LookupUserDefProcedure] ADD  CONSTRAINT [DF_LookupUserDefProcedure_IsProcessed]  DEFAULT ((0)) FOR [IsProcessed]