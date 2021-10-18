/****** Object:  Table [dbo].[LookupUserDefMedication]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[LookupUserDefMedication](
	[Code] [varchar](15) NOT NULL,
	[Description] [varchar](100) NULL,
	[Strength] [varchar](10) NULL,
	[Unit] [varchar](50) NULL,
	[Type] [varchar](10) NULL,
	[Modified] [datetime] NULL,
	[Created] [datetime] NULL,
	[IsProcessed] [bit] NULL,
	[ProcessedDate] [datetime] NULL,
 CONSTRAINT [PK_LookupUserDefMedication] PRIMARY KEY CLUSTERED 
(
	[Code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_LookupUserDefMedication_IsProcessed] ON [dbo].[LookupUserDefMedication]
(
	[IsProcessed] ASC
)
INCLUDE([Code]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
ALTER TABLE [dbo].[LookupUserDefMedication] ADD  CONSTRAINT [DF_LookupUserDefMedication_Created]  DEFAULT (getutcdate()) FOR [Created]
ALTER TABLE [dbo].[LookupUserDefMedication] ADD  CONSTRAINT [DF_LookupUserDefMedication_IsProcessed]  DEFAULT ((0)) FOR [IsProcessed]