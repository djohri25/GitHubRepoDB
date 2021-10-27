/****** Object:  Table [dbo].[HPAlertNote]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[HPAlertNote](
	[ID] [int] IDENTITY(1,1) NOT NULL,
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
	[DocType] [varchar](100) NULL,
	[ServiceId] [int] NULL,
	[ServiceLocationId] [int] NULL,
	[QuickNoteId] [int] NULL,
 CONSTRAINT [PK_HPAlertNote_ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_HPAlertNote_DateModified] ON [dbo].[HPAlertNote]
(
	[DateModified] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [IX_HPAlertNote_MVDID_ModifiedByType_Active] ON [dbo].[HPAlertNote]
(
	[MVDID] ASC,
	[ModifiedByType] ASC,
	[Active] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [IX_HPALERTNote_MVDIDLinkedFormType] ON [dbo].[HPAlertNote]
(
	[MVDID] ASC,
	[LinkedFormType] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
ALTER TABLE [dbo].[HPAlertNote] ADD  CONSTRAINT [DF__HPAlertNo__Activ__139399E6]  DEFAULT ((1)) FOR [Active]
ALTER TABLE [dbo].[HPAlertNote]  WITH CHECK ADD  CONSTRAINT [FK_AltertNote_Generic_Code_ActionTypeID] FOREIGN KEY([ActionTypeID])
REFERENCES [dbo].[Lookup_Generic_Code] ([CodeID])
ALTER TABLE [dbo].[HPAlertNote] CHECK CONSTRAINT [FK_AltertNote_Generic_Code_ActionTypeID]