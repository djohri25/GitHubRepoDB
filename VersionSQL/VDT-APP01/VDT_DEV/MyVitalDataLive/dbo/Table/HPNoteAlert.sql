/****** Object:  Table [dbo].[HPNoteAlert]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[HPNoteAlert](
	[ID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[AgentID] [nvarchar](50) NULL,
	[AlertDate] [datetime] NULL,
	[Customer] [nvarchar](50) NULL,
	[MVDID] [nvarchar](20) NULL,
	[StatusID] [int] NULL,
	[SourceRecordID] [int] NULL,
	[DateCreated] [datetime] NULL,
	[DateModified] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](64) NULL,
	[TriggerType] [varchar](50) NULL,
	[TriggerID] [int] NULL,
	[RecipientType] [varchar](50) NULL,
	[RecipientCustID] [int] NULL,
	[SourceName] [varchar](50) NULL,
	[CreatedBy] [varchar](50) NULL,
	[HPMemberID] [varchar](50) NULL,
 CONSTRAINT [PK_HPNoteAlert] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[HPNoteAlert] ADD  CONSTRAINT [DF_HPNoteAlert_DateCreated]  DEFAULT (getutcdate()) FOR [DateCreated]
ALTER TABLE [dbo].[HPNoteAlert] ADD  CONSTRAINT [DF_HPNoteAlert_DateModified]  DEFAULT (getutcdate()) FOR [DateModified]