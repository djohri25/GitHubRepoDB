/****** Object:  Table [dbo].[ABCBS_ExcessLoss_Form]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[ABCBS_ExcessLoss_Form](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[MVDID] [varchar](20) NOT NULL,
	[FormDate] [datetime] NOT NULL,
	[FormAuthor] [varchar](100) NOT NULL,
	[CaseID] [varchar](100) NULL,
	[q1PolicyEffectiveDate] [datetime] NULL,
	[q2PolicyTerminationDate] [datetime] NULL,
	[q3DeathDate] [datetime] NULL,
	[q4Group] [varchar](max) NULL,
	[q5SpouseORDependent] [varchar](max) NULL,
	[q6CM] [varchar](max) NULL,
	[q7Claims] [varchar](max) NULL,
	[q8SpouseORDependent] [varchar](max) NULL,
	[q9DateIdentified] [datetime] NULL,
	[q10ReferralSource] [varchar](max) NULL,
	[q11ReferralCriteria] [varchar](max) NULL,
	[q12RiskLevel] [varchar](max) NULL,
	[q13RiskScore] [varchar](max) NULL,
	[q14PrimaryDiagnosis] [varchar](max) NULL,
	[q15DateDiagEst] [datetime] NULL,
	[q16PastSurgeriesCancerBH] [varchar](max) NULL,
	[q17BriefHistory] [varchar](max) NULL,
	[q18CurrTreatmentPlan] [varchar](max) NULL,
	[q19AnticipatedTreatmentPlan] [varchar](max) NULL,
	[q20Facility] [varchar](max) NULL,
	[q21Location] [varchar](max) NULL,
	[q22KeyClinicalIndicators] [varchar](max) NULL,
	[q24EduMaterials] [varchar](max) NULL,
	[q25OutboundcallwithDates] [varchar](max) NULL,
	[q26UnsuccessfulEngagementCalls] [varchar](max) NULL,
	[q27TotalOutBoundcalls] [varchar](max) NULL,
	[q28KeyClinical] [varchar](max) NULL,
	[q29Evidence] [varchar](max) NULL,
	[q30MedList] [varchar](max) NULL,
	[q31DocSocialHistory] [varchar](max) NULL,
	[q32GoalsInterventionsOutcomes] [varchar](max) NULL,
	[q33Colloboration] [varchar](max) NULL,
	[q34Consultations] [varchar](max) NULL,
	[q35ReturntoWorkStatus] [varchar](max) NULL,
	[q36VendorProgram] [varchar](max) NULL,
	[q37Utilization] [varchar](max) NULL,
	[LastModifiedDate] [datetime] NULL,
	[IsLocked] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_ABCBS_ExcessLoss_Form] ON [dbo].[ABCBS_ExcessLoss_Form]
(
	[ID] ASC
)
INCLUDE([FormDate],[IsLocked]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
CREATE NONCLUSTERED INDEX [IX_ABCBS_ExcessLoss_Form_FormDate] ON [dbo].[ABCBS_ExcessLoss_Form]
(
	[FormDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
ALTER TABLE [dbo].[ABCBS_ExcessLoss_Form] ADD  DEFAULT (getdate()) FOR [LastModifiedDate]