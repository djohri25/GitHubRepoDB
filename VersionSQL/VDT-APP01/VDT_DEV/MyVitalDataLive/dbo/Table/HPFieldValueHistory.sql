/****** Object:  Table [dbo].[HPFieldValueHistory]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[HPFieldValueHistory](
	[ID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[MVDID] [varchar](15) NOT NULL,
	[TableName] [varchar](50) NOT NULL,
	[FieldName] [varchar](50) NOT NULL,
	[FieldValue] [varchar](250) NULL,
	[Created] [datetime] NULL,
 CONSTRAINT [PK_HPFieldValueHistory] PRIMARY KEY CLUSTERED 
(
	[MVDID] ASC,
	[TableName] ASC,
	[FieldName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[HPFieldValueHistory] ADD  CONSTRAINT [DF_HPFieldValueHistory_Created]  DEFAULT (getutcdate()) FOR [Created]