/****** Object:  Table [dbo].[MainLabNote]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[MainLabNote](
	[RecordNumber] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[ICENUMBER] [varchar](15) NULL,
	[ResultID] [int] NULL,
	[Note] [varchar](4000) NULL,
	[CreationDate] [datetime] NULL,
	[CreatedBy] [nvarchar](250) NULL,
	[CreatedByOrganization] [varchar](250) NULL,
	[UpdatedBy] [nvarchar](250) NULL,
	[UpdatedByOrganization] [varchar](250) NULL,
	[UpdatedByContact] [varchar](20) NULL,
	[CreatedByNPI] [varchar](20) NULL,
	[UpdatedByNPI] [varchar](250) NULL,
	[SourceName] [varchar](50) NULL,
	[SequenceNum] [int] NULL,
 CONSTRAINT [PK_MainLabNote] PRIMARY KEY CLUSTERED 
(
	[RecordNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [IX_MainLabNote] ON [dbo].[MainLabNote]
(
	[ICENUMBER] ASC,
	[ResultID] ASC,
	[SourceName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
ALTER TABLE [dbo].[MainLabNote] ADD  CONSTRAINT [DF_Table_1_Created]  DEFAULT (getutcdate()) FOR [CreationDate]