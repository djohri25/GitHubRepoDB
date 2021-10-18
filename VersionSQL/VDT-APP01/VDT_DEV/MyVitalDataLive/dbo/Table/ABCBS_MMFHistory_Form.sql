/****** Object:  Table [dbo].[ABCBS_MMFHistory_Form]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[ABCBS_MMFHistory_Form](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[MVDID] [varchar](30) NOT NULL,
	[FormDate] [datetime] NOT NULL,
	[FormAuthor] [varchar](100) NOT NULL,
	[CaseID] [varchar](100) NULL,
	[OriginalFormID] [varchar](max) NULL,
	[SectionCompleted] [varchar](max) NULL,
	[ReferralID] [varchar](max) NULL,
	[ReferralDate] [datetime] NULL,
	[CaseConversion] [varchar](max) NULL,
	[NonViableReason] [varchar](max) NULL,
	[ReferralOwner] [varchar](max) NULL,
	[ReferralSource] [varchar](max) NULL,
	[ReferralExternal] [varchar](max) NULL,
	[ReferralReason] [varchar](max) NULL,
	[CaseProgram] [varchar](max) NULL,
	[InProgress] [varchar](max) NULL,
	[ParentReferralID] [varchar](max) NULL,
	[qNonViableReason] [varchar](max) NULL,
	[qViableReason] [varchar](max) NULL,
	[qNonViableReason1] [varchar](max) NULL,
	[q15AssignTo] [varchar](max) NULL,
	[q16CareQ] [varchar](max) NULL,
	[q17CMSpeciality] [varchar](max) NULL,
	[q18User] [varchar](max) NULL,
	[q19AssignedUser] [varchar](max) NULL,
	[q1ConsentRef] [varchar](max) NULL,
	[q2ConsentNonViable] [varchar](max) NULL,
	[q1ConsentofferCM] [varchar](max) NULL,
	[qNoReason] [varchar](max) NULL,
	[q5ConsentMemberManaged] [varchar](max) NULL,
	[q6Consentverbal] [varchar](max) NULL,
	[q2ConsentDate] [datetime] NULL,
	[q8] [varchar](max) NULL,
	[q9followmember] [varchar](max) NULL,
	[q9followmember1] [varchar](max) NULL,
	[q9followmember2] [varchar](max) NULL,
	[q10followmember] [varchar](max) NULL,
	[q10followmember1] [varchar](max) NULL,
	[q10followmember2] [varchar](max) NULL,
	[qPreferredLang] [varchar](max) NULL,
	[qLangOther] [varchar](max) NULL,
	[qPreferredName] [varchar](max) NULL,
	[qContact] [varchar](max) NULL,
	[qBestTime] [varchar](max) NULL,
	[qEmail] [varchar](max) NULL,
	[qPreferredCommunication] [varchar](max) NULL,
	[qVerifyMailAddr] [varchar](max) NULL,
	[qHealthInfo] [varchar](max) NULL,
	[q1CaseCreateDate] [datetime] NULL,
	[q4CaseProgram] [varchar](max) NULL,
	[q1CaseOwner] [varchar](max) NULL,
	[q3CaseManagedBy] [varchar](max) NULL,
	[q5CaseCategory] [varchar](max) NULL,
	[q5CaseType] [varchar](max) NULL,
	[qCaseLevel] [varchar](max) NULL,
	[qCaseOpenSummary] [varchar](max) NULL,
	[qCloseCase] [varchar](max) NULL,
	[q1CaseCloseDate] [datetime] NULL,
	[q2CloseReason] [varchar](max) NULL,
	[qCaseCLoseOverview] [varchar](max) NULL,
	[CarePlanID] [bigint] NULL,
	[AuditableCase] [bit] NULL,
	[LastModifiedDate] [datetime] NULL,
	[qUnableToReachReason] [varchar](max) NULL,
	[q2UnableToReachReason] [varchar](max) NULL,
	[q2MemberCondition] [varchar](max) NULL,
	[q3UnableToReachReason] [varchar](max) NULL,
	[Version] [varchar](3) NULL,
	[q15aAssignTo] [varchar](max) NULL,
	[q16aCareQ] [varchar](max) NULL,
	[q17aCMSpeciality] [varchar](max) NULL,
	[q18aUser] [varchar](max) NULL,
	[q19aAssignedUser] [varchar](max) NULL,
	[qReadyForConsent] [varchar](max) NULL,
	[IsLocked] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_ABCBS_MMFHistory_Form] ON [dbo].[ABCBS_MMFHistory_Form]
(
	[ID] ASC
)
INCLUDE([FormDate],[IsLocked]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
CREATE NONCLUSTERED INDEX [IX_ABCBS_MMFHistory_Form_FormDate] ON [dbo].[ABCBS_MMFHistory_Form]
(
	[FormDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
ALTER TABLE [dbo].[ABCBS_MMFHistory_Form] ADD  DEFAULT (getdate()) FOR [LastModifiedDate]
ALTER TABLE [dbo].[ABCBS_MMFHistory_Form] ADD  DEFAULT ('V1') FOR [Version]
ALTER TABLE [dbo].[ABCBS_MMFHistory_Form] ADD  DEFAULT ('No') FOR [qReadyForConsent]