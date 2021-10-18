/****** Object:  Table [dbo].[ABCBS_InterdisciplinaryTeam_Form]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[ABCBS_InterdisciplinaryTeam_Form](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[MVDID] [varchar](20) NOT NULL,
	[FormDate] [datetime] NOT NULL,
	[FormAuthor] [varchar](100) NOT NULL,
	[CaseID] [varchar](100) NULL,
	[qDiscipline] [varchar](max) NULL,
	[qMedDir] [varchar](max) NULL,
	[qMeetingType] [varchar](max) NULL,
	[qClinicalSynopsis] [varchar](max) NULL,
	[qDiscussion] [varchar](max) NULL,
	[qDetermination] [varchar](max) NULL,
	[qFollowUpDoc] [varchar](max) NULL,
	[q163Date] [datetime] NULL,
	[qTime] [varchar](max) NULL,
	[qContactPerson] [varchar](max) NULL,
	[qAttemptToReach] [varchar](max) NULL,
	[qMedDirCMName] [varchar](max) NULL,
	[qMedDirComments] [varchar](max) NULL,
	[qPTP] [varchar](max) NULL,
	[qPTPClinicalSynopsis] [varchar](max) NULL,
	[qPTPDiscussion] [varchar](max) NULL,
	[qPTPDetermination] [varchar](max) NULL,
	[qPTPFollowUpDoc] [varchar](max) NULL,
	[q165Date] [datetime] NULL,
	[qPTPTime] [varchar](max) NULL,
	[qPTPContactPerson] [varchar](max) NULL,
	[qPTPAttemptToReach] [varchar](max) NULL,
	[qPTPComments] [varchar](max) NULL,
	[qContactType] [varchar](max) NULL,
	[qPharmacist] [varchar](max) NULL,
	[PharmacyComments] [varchar](max) NULL,
	[qDateInterventionCompleted] [datetime] NULL,
	[qSpecificNeed] [varchar](max) NULL,
	[qSW1] [varchar](max) NULL,
	[qSW2] [varchar](max) NULL,
	[qSW3] [varchar](max) NULL,
	[qSW4] [varchar](max) NULL,
	[qSW5] [varchar](max) NULL,
	[qSW6] [varchar](max) NULL,
	[qSW7] [varchar](max) NULL,
	[qSW8] [varchar](max) NULL,
	[qSW9] [varchar](max) NULL,
	[qSW10] [varchar](max) NULL,
	[qSW11] [varchar](max) NULL,
	[qSW12] [varchar](max) NULL,
	[qSW13] [varchar](max) NULL,
	[ResourcesRef] [varchar](max) NULL,
	[qLanguageServices] [varchar](max) NULL,
	[qSWDescription] [varchar](max) NULL,
	[LastModifiedDate] [datetime] NULL,
	[qSWCollaboration] [varchar](max) NULL,
	[qSWComment] [varchar](max) NULL,
	[Version] [varchar](max) NULL,
	[IsLocked] [varchar](max) NULL,
	[qMajorConcerns] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_ABCBS_InterdisciplinaryTeam_Form] ON [dbo].[ABCBS_InterdisciplinaryTeam_Form]
(
	[ID] ASC
)
INCLUDE([FormDate],[IsLocked]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
CREATE NONCLUSTERED INDEX [IX_ABCBS_InterdisciplinaryTeam_Form_FormDate] ON [dbo].[ABCBS_InterdisciplinaryTeam_Form]
(
	[FormDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
ALTER TABLE [dbo].[ABCBS_InterdisciplinaryTeam_Form] ADD  DEFAULT (getdate()) FOR [LastModifiedDate]