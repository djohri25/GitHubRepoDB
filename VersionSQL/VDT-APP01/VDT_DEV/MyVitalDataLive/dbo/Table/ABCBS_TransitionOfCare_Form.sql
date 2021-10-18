/****** Object:  Table [dbo].[ABCBS_TransitionOfCare_Form]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[ABCBS_TransitionOfCare_Form](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[MVDID] [varchar](20) NOT NULL,
	[FormDate] [datetime] NOT NULL,
	[FormAuthor] [varchar](100) NOT NULL,
	[CaseID] [varchar](100) NULL,
	[q1TransitionDate] [datetime] NULL,
	[q2MemTransitionedFrom] [varchar](max) NULL,
	[q2Other] [varchar](max) NULL,
	[q3MemTransitionedTo] [varchar](max) NULL,
	[q3Other] [varchar](max) NULL,
	[q4VerifiedMember] [varchar](max) NULL,
	[q5MemberRationale] [varchar](max) NULL,
	[q5TransitionDischarge] [varchar](max) NULL,
	[q5DischargeInstructions] [varchar](max) NULL,
	[q6FolowUpAppt] [varchar](max) NULL,
	[q6ApptDate] [datetime] NULL,
	[q6AssistAppt] [varchar](max) NULL,
	[q6AssistApptOther] [varchar](max) NULL,
	[q7Medication] [varchar](max) NULL,
	[q8TakingMedication] [varchar](max) NULL,
	[q9Comment] [varchar](max) NULL,
	[LastModifiedDate] [datetime] NULL,
	[IsLocked] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_ABCBS_TransitionOfCare_Form] ON [dbo].[ABCBS_TransitionOfCare_Form]
(
	[ID] ASC
)
INCLUDE([FormDate],[IsLocked]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
CREATE NONCLUSTERED INDEX [IX_ABCBS_TransitionOfCare_Form_FormDate] ON [dbo].[ABCBS_TransitionOfCare_Form]
(
	[FormDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
ALTER TABLE [dbo].[ABCBS_TransitionOfCare_Form] ADD  DEFAULT (getdate()) FOR [LastModifiedDate]