/****** Object:  Table [dbo].[HPAlertNoteLetters]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[HPAlertNoteLetters](
	[ID] [int] NOT NULL,
	[AlertID] [int] NULL,
	[Note] [varchar](max) NULL,
	[AlertStatusID] [int] NULL,
	[DateCreated] [datetime] NULL,
	[CreatedBy] [varchar](50) NULL,
	[DateModified] [datetime] NULL,
	[ModifiedBy] [varchar](50) NULL,
	[CreatedByCompany] [varchar](50) NULL,
	[ModifiedByCompany] [varchar](50) NULL,
	[MVDID] [varchar](30) NULL,
	[CreatedByType] [varchar](50) NULL,
	[ModifiedByType] [varchar](50) NULL,
	[Active] [bit] NULL,
	[SendToHP] [bit] NULL,
	[SendToPCP] [bit] NULL,
	[SendToNurture] [bit] NULL,
	[SendToNone] [bit] NULL,
	[LinkedFormType] [varchar](50) NULL,
	[LinkedFormID] [int] NULL,
	[NoteTypeID] [int] NULL,
	[ActionTypeID] [int] NULL,
	[DueDate] [datetime] NULL,
	[CompletedDate] [datetime] NULL,
	[NoteTimestampId] [int] NULL,
	[NoteSourceId] [int] NULL,
	[SendToMyVitalDataMobile] [bit] NULL,
	[SendToOHIT] [bit] NULL,
	[SendToState] [bit] NULL,
	[SendToDMVendor] [bit] NULL,
	[CaseID] [varchar](100) NULL,
	[IsDelete] [bit] NULL,
	[SessionID] [varchar](max) NULL,
	[DocType] [varchar](100) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]