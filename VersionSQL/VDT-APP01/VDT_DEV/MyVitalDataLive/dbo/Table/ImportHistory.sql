/****** Object:  Table [dbo].[ImportHistory]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[ImportHistory](
	[ID] [bigint] IDENTITY(1000000000,1) NOT FOR REPLICATION NOT NULL,
	[MVDID] [nvarchar](20) NULL,
	[ImportRecordID] [int] NULL,
	[HPAssignedID] [varchar](50) NULL,
	[MVDRecordID] [int] NULL,
	[Action] [char](1) NULL,
	[RecordType] [varchar](50) NULL,
	[Customer] [varchar](50) NULL,
	[SourceName] [varchar](50) NULL,
	[DBName] [nvarchar](20) NULL,
	[Created] [datetime] NULL,
 CONSTRAINT [PK_Import_History_New2] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[ImportHistory] ADD  CONSTRAINT [DF_ImportHistory_Created_New2]  DEFAULT (getutcdate()) FOR [Created]