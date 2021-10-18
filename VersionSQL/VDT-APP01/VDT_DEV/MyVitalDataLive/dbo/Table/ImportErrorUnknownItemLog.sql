/****** Object:  Table [dbo].[ImportErrorUnknownItemLog]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[ImportErrorUnknownItemLog](
	[ID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[ClaimRecordID] [nvarchar](50) NULL,
	[ItemCode] [nvarchar](50) NULL,
	[ItemType] [nvarchar](50) NULL,
	[MVDId] [varchar](20) NULL,
	[DBName] [varchar](20) NULL,
	[Created] [datetime] NULL,
	[IsProcessed] [bit] NULL,
 CONSTRAINT [PK_ImportUnknownDiagnosis] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [IX_ImportErrorUnknownItemLog_Code_Type] ON [dbo].[ImportErrorUnknownItemLog]
(
	[ItemCode] ASC,
	[ItemType] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
ALTER TABLE [dbo].[ImportErrorUnknownItemLog] ADD  CONSTRAINT [DF_ImportUnknownDiagnosis_Created]  DEFAULT (getutcdate()) FOR [Created]
ALTER TABLE [dbo].[ImportErrorUnknownItemLog] ADD  CONSTRAINT [DF_ImportErrorUnknownItemLog_IsProcessed]  DEFAULT ((0)) FOR [IsProcessed]