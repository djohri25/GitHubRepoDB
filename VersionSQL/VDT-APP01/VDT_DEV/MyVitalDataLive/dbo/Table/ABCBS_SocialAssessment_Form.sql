/****** Object:  Table [dbo].[ABCBS_SocialAssessment_Form]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[ABCBS_SocialAssessment_Form](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[MVDID] [varchar](20) NOT NULL,
	[FormDate] [datetime] NOT NULL,
	[FormAuthor] [varchar](100) NOT NULL,
	[CaseID] [varchar](100) NULL,
	[qConsultation] [varchar](max) NULL,
	[qConsulationOther] [varchar](max) NULL,
	[qMaritalStatus] [varchar](max) NULL,
	[qVeteran] [varchar](max) NULL,
	[qCareGiver] [varchar](max) NULL,
	[qLanguagesSpoken] [varchar](max) NULL,
	[qGeneralComments] [varchar](max) NULL,
	[qEnoughGroceries] [varchar](max) NULL,
	[qFoodInsecurityComments] [varchar](max) NULL,
	[qStableHousing] [varchar](max) NULL,
	[qStableHousing1] [varchar](max) NULL,
	[qHousingComments] [varchar](max) NULL,
	[qUtilities] [varchar](max) NULL,
	[qUtilitiesComments] [varchar](max) NULL,
	[qBills] [varchar](max) NULL,
	[qBillsComments] [varchar](max) NULL,
	[qfinancial] [varchar](max) NULL,
	[qfinancialComments] [varchar](max) NULL,
	[qAssistance] [varchar](max) NULL,
	[qAssistanceComments] [varchar](max) NULL,
	[qTransportation] [varchar](max) NULL,
	[qTransportationComments] [varchar](max) NULL,
	[qViolence] [varchar](max) NULL,
	[qViolenceComments] [varchar](max) NULL,
	[qCaregiving] [varchar](max) NULL,
	[qCaregivingComments] [varchar](max) NULL,
	[qEducation] [varchar](max) NULL,
	[qEducationComments] [varchar](max) NULL,
	[qEmployment] [varchar](max) NULL,
	[qIncomeSources] [varchar](max) NULL,
	[qIncomeOther] [varchar](max) NULL,
	[qEmploymentComments] [varchar](max) NULL,
	[qHealthBehaviors] [varchar](max) NULL,
	[qAlcohol] [varchar](max) NULL,
	[qOtherDrugs] [varchar](max) NULL,
	[qRecentChanges] [varchar](max) NULL,
	[qExcercise] [varchar](max) NULL,
	[qAssistiveDevices] [varchar](max) NULL,
	[qHealthBehavioursComments] [varchar](max) NULL,
	[qSocialIsolation] [varchar](max) NULL,
	[qSocialIsolationComments] [varchar](max) NULL,
	[qMentalHealthNeed] [varchar](max) NULL,
	[qBHComments] [varchar](max) NULL,
	[qAdvDirectives] [varchar](max) NULL,
	[qAdvDirectiveComments] [varchar](max) NULL,
	[qUrgency] [varchar](max) NULL,
	[qAdditionalQuest] [varchar](max) NULL,
	[qSummary] [varchar](max) NULL,
	[LastModifiedDate] [datetime] NULL,
	[qMajorConcerns] [varchar](max) NULL,
	[Version] [varchar](max) NULL,
	[IsLocked] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_ABCBS_SocialAssessment_Form] ON [dbo].[ABCBS_SocialAssessment_Form]
(
	[ID] ASC
)
INCLUDE([FormDate],[IsLocked]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
CREATE NONCLUSTERED INDEX [IX_ABCBS_SocialAssessment_Form_FormDate] ON [dbo].[ABCBS_SocialAssessment_Form]
(
	[FormDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
ALTER TABLE [dbo].[ABCBS_SocialAssessment_Form] ADD  DEFAULT (getdate()) FOR [LastModifiedDate]