/****** Object:  Table [dbo].[MoveImportHistory_Temp]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[MoveImportHistory_Temp](
	[ID] [int] NOT NULL,
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
	[Processed] [nvarchar](20) NULL,
 CONSTRAINT [PK_MoveImportHistory_Temp] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]