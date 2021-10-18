/****** Object:  Table [dbo].[ABCBS_HEP_OnTheLevel_Form]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[ABCBS_HEP_OnTheLevel_Form](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[MVDID] [varchar](30) NOT NULL,
	[FormDate] [datetime] NOT NULL,
	[FormAuthor] [varchar](100) NOT NULL,
	[CaseID] [varchar](100) NULL,
	[Age] [varchar](max) NULL,
	[q1OnTheLevel] [datetime] NULL,
	[q2OnTheLevel] [datetime] NULL,
	[q3OnTheLevel] [datetime] NULL,
	[q4OnTheLevel] [datetime] NULL,
	[q5OnTheLevel] [datetime] NULL,
	[q6OnTheLevel] [datetime] NULL,
	[q7OnTheLevel] [datetime] NULL,
	[q8OnTheLevel] [datetime] NULL,
	[q9OnTheLevel] [datetime] NULL,
	[q10OnTheLevel] [datetime] NULL,
	[q11OnTheLevel] [datetime] NULL,
	[q12OnTheLevel] [datetime] NULL,
	[qReferralSource] [varchar](max) NULL,
	[q1OtherSource] [varchar](max) NULL,
	[qNameOfParent] [varchar](max) NULL,
	[qNameofDoctor] [varchar](max) NULL,
	[qChildDiabetes] [varchar](max) NULL,
	[qTypeofDiabetes] [varchar](max) NULL,
	[qChildGoneToHosp] [varchar](max) NULL,
	[qFoodDiet] [varchar](max) NULL,
	[qBloodGlucose] [varchar](max) NULL,
	[qTreatmentforBP] [varchar](max) NULL,
	[qSickTreatment] [varchar](max) NULL,
	[qInsulinShot] [varchar](max) NULL,
	[qSchoolDiabetesTreatment] [varchar](max) NULL,
	[DiabetesPills] [varchar](max) NULL,
	[qBracelet] [varchar](max) NULL,
	[OtherTreatment] [varchar](max) NULL,
	[NoneTreatment] [varchar](max) NULL,
	[qImmunization] [varchar](max) NULL,
	[qParentSmoke] [varchar](max) NULL,
	[qsmoke1] [varchar](max) NULL,
	[qsmoke2] [varchar](max) NULL,
	[qHighestBloodSugar] [varchar](max) NULL,
	[qHighestBloodSugar1] [varchar](max) NULL,
	[qLowestBloodSugar] [varchar](max) NULL,
	[qLowestBloodSugar1] [varchar](max) NULL,
	[qAvgBloodSugar] [varchar](max) NULL,
	[qAvgBloodSugar1] [varchar](max) NULL,
	[qHgbA1c] [varchar](max) NULL,
	[qDoeschildSmoke] [varchar](max) NULL,
	[qEyeExam] [varchar](max) NULL,
	[qFeetNHandExam] [varchar](max) NULL,
	[qlipids] [varchar](max) NULL,
	[q14] [varchar](max) NULL,
	[q15] [varchar](max) NULL,
	[q15a] [varchar](max) NULL,
	[q15b] [varchar](max) NULL,
	[q16] [varchar](max) NULL,
	[qDaysToSchool] [varchar](max) NULL,
	[qSchoolMissed] [varchar](max) NULL,
	[qChildExercise] [varchar](max) NULL,
	[qScale1] [varchar](max) NULL,
	[qScale2] [varchar](max) NULL,
	[qScale3] [varchar](max) NULL,
	[InfoRegSelfMgmt] [varchar](max) NULL,
	[comments] [varchar](max) NULL,
	[TotalScore] [varchar](max) NULL,
	[LastModifiedDate] [datetime] NULL,
	[IsLocked] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_ABCBS_HEP_OnTheLevel_Form] ON [dbo].[ABCBS_HEP_OnTheLevel_Form]
(
	[ID] ASC
)
INCLUDE([FormDate],[IsLocked]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
CREATE NONCLUSTERED INDEX [IX_ABCBS_HEP_OnTheLevel_Form_FormDate] ON [dbo].[ABCBS_HEP_OnTheLevel_Form]
(
	[FormDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
ALTER TABLE [dbo].[ABCBS_HEP_OnTheLevel_Form] ADD  DEFAULT (getdate()) FOR [LastModifiedDate]