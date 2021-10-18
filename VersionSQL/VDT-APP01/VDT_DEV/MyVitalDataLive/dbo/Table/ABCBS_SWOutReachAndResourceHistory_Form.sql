/****** Object:  Table [dbo].[ABCBS_SWOutReachAndResourceHistory_Form]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[ABCBS_SWOutReachAndResourceHistory_Form](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[MVDID] [varchar](30) NOT NULL,
	[FormDate] [datetime] NOT NULL,
	[FormAuthor] [varchar](100) NOT NULL,
	[CaseID] [varchar](100) NULL,
	[OriginalFormID] [varchar](max) NULL,
	[Version] [varchar](max) NULL,
	[SectionCompleted] [varchar](max) NULL,
	[qResource1] [varchar](max) NULL,
	[qIntervention1] [varchar](max) NULL,
	[qResource2] [varchar](max) NULL,
	[qIntervention2] [varchar](max) NULL,
	[qResource3] [varchar](max) NULL,
	[qIntervention3] [varchar](max) NULL,
	[qResource4] [varchar](max) NULL,
	[qIntervention4] [varchar](max) NULL,
	[qResource5] [varchar](max) NULL,
	[qIntervention5] [varchar](max) NULL,
	[qResource6] [varchar](max) NULL,
	[qIntervention6] [varchar](max) NULL,
	[qResource7] [varchar](max) NULL,
	[qIntervention7] [varchar](max) NULL,
	[qResource8] [varchar](max) NULL,
	[qIntervention8] [varchar](max) NULL,
	[qResource9] [varchar](max) NULL,
	[qIntervention9] [varchar](max) NULL,
	[qResource10] [varchar](max) NULL,
	[qIntervention10] [varchar](max) NULL,
	[qResource11] [varchar](max) NULL,
	[qIntervention11] [varchar](max) NULL,
	[qResource12] [varchar](max) NULL,
	[qIntervention12] [varchar](max) NULL,
	[qResource13] [varchar](max) NULL,
	[qIntervention13] [varchar](max) NULL,
	[qTotalResources] [varchar](max) NULL,
	[qTotalIntervention] [varchar](max) NULL,
	[qComment] [varchar](max) NULL,
	[qLockForm] [varchar](max) NULL,
	[LastModifiedDate] [datetime] NULL,
	[IsLocked] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_ABCBS_SWOutReachAndResourceHistory_Form] ON [dbo].[ABCBS_SWOutReachAndResourceHistory_Form]
(
	[ID] ASC
)
INCLUDE([FormDate],[IsLocked]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]