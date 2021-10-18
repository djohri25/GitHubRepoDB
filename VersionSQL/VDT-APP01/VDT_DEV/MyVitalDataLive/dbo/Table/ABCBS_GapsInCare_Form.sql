/****** Object:  Table [dbo].[ABCBS_GapsInCare_Form]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[ABCBS_GapsInCare_Form](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[MVDID] [varchar](20) NOT NULL,
	[FormDate] [datetime] NOT NULL,
	[FormAuthor] [varchar](100) NOT NULL,
	[CaseID] [varchar](100) NULL,
	[q1MemAltPhNumber] [varchar](max) NULL,
	[q2MemEmail] [varchar](max) NULL,
	[q3ChronicCond] [varchar](max) NULL,
	[q4CurrentGapsToDiscuss] [varchar](max) NULL,
	[q5PrimaryCare] [varchar](max) NULL,
	[q6LastAppt] [datetime] NULL,
	[q7TimeRange] [varchar](max) NULL,
	[q8FollowUpAppt] [datetime] NULL,
	[q9FollowUpComment] [varchar](max) NULL,
	[q10DiagnosisComment] [varchar](max) NULL,
	[q11TreatmentOrMedComment] [varchar](max) NULL,
	[q12Specialist] [varchar](max) NULL,
	[q13LastAppt] [datetime] NULL,
	[q14TimeRange] [varchar](max) NULL,
	[q15FollowUpAppt] [datetime] NULL,
	[q16FollowUpComment] [varchar](max) NULL,
	[q17DiagnosisComment] [varchar](max) NULL,
	[q18TreatmentOrMedComment] [varchar](max) NULL,
	[q19SpecialistTreating] [varchar](max) NULL,
	[q20ManageCond] [varchar](max) NULL,
	[q21] [varchar](max) NULL,
	[q22] [varchar](max) NULL,
	[q23ReachPCP] [varchar](max) NULL,
	[q24FamiliarClinic] [varchar](max) NULL,
	[q25Barrier] [varchar](max) NULL,
	[q26Concern] [varchar](max) NULL,
	[q27Correspondence] [varchar](max) NULL,
	[q28CorrespondenceSent] [varchar](max) NULL,
	[GAPSComments] [varchar](max) NULL,
	[LastModifiedDate] [datetime] NULL,
	[IsLocked] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_ABCBS_GapsInCare_Form] ON [dbo].[ABCBS_GapsInCare_Form]
(
	[ID] ASC
)
INCLUDE([FormDate],[IsLocked]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
CREATE NONCLUSTERED INDEX [IX_ABCBS_GapsInCare_Form_FormDate] ON [dbo].[ABCBS_GapsInCare_Form]
(
	[FormDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
ALTER TABLE [dbo].[ABCBS_GapsInCare_Form] ADD  DEFAULT (getdate()) FOR [LastModifiedDate]