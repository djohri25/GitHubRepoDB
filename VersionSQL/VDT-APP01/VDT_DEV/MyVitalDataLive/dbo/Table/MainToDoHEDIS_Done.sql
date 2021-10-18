/****** Object:  Table [dbo].[MainToDoHEDIS_Done]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[MainToDoHEDIS_Done](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[SourceRecordID] [int] NULL,
	[MemberID] [varchar](20) NOT NULL,
	[Major] [nvarchar](300) NOT NULL,
	[Minor] [nvarchar](100) NOT NULL,
	[Source] [varchar](50) NULL,
	[Created] [datetime] NULL,
	[TestLookupID] [int] NULL,
	[ArchivedDate] [datetime] NULL,
	[PerformedByNPI] [varchar](50) NULL,
	[ProcedureCode] [varchar](20) NULL,
	[ProcedureCodingSystem] [varchar](20) NULL,
	[ProcedureSourceID] [int] NULL,
	[MVDID] [varchar](20) NULL,
	[TestCompletionDate] [datetime] NULL,
	[EpisodeDate] [datetime] NULL,
 CONSTRAINT [PK_MainToDoHEDIS_Done] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [IX_MainToDoHEDIS_Done_Lookup_Source] ON [dbo].[MainToDoHEDIS_Done]
(
	[TestLookupID] ASC,
	[Source] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
CREATE NONCLUSTERED INDEX [IX_MainToDoHEDIS_Done_LookupID] ON [dbo].[MainToDoHEDIS_Done]
(
	[TestLookupID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
ALTER TABLE [dbo].[MainToDoHEDIS_Done] ADD  CONSTRAINT [DF__MainToDoH__Archi__05107065]  DEFAULT (getutcdate()) FOR [ArchivedDate]