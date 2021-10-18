/****** Object:  Table [dbo].[ABCBS_HEP_CatchAir_Form]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[ABCBS_HEP_CatchAir_Form](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[MVDID] [varchar](30) NOT NULL,
	[FormDate] [datetime] NOT NULL,
	[FormAuthor] [varchar](100) NOT NULL,
	[CaseID] [varchar](100) NULL,
	[Age] [varchar](max) NULL,
	[q1CatchAir] [datetime] NULL,
	[q2CatchAir] [datetime] NULL,
	[q3CatchAir] [datetime] NULL,
	[q4CatchAir] [datetime] NULL,
	[q5CatchAir] [datetime] NULL,
	[q6CatchAir] [datetime] NULL,
	[q7CatchAir] [datetime] NULL,
	[q8CatchAir] [datetime] NULL,
	[q9CatchAir] [datetime] NULL,
	[q10CatchAir] [datetime] NULL,
	[q11CatchAir] [datetime] NULL,
	[q12CatchAir] [datetime] NULL,
	[qReferralSource] [varchar](max) NULL,
	[q1OtherSource] [varchar](max) NULL,
	[qNameOfParent] [varchar](max) NULL,
	[qNameofDoctor] [varchar](max) NULL,
	[qChildAsthma] [varchar](max) NULL,
	[qChildGoneToHosp] [varchar](max) NULL,
	[qDaysToSchool] [varchar](max) NULL,
	[qSchoolMissed] [varchar](max) NULL,
	[qAAPTreatment] [varchar](max) NULL,
	[qSchoolAAPTreatment] [varchar](max) NULL,
	[qchildwears] [varchar](max) NULL,
	[qTriggersIdentified] [varchar](max) NULL,
	[qPreventiveMedicine] [varchar](max) NULL,
	[qRescue] [varchar](max) NULL,
	[qMaskSpacer1] [varchar](max) NULL,
	[qMaskSpacer2] [varchar](max) NULL,
	[qPeakFlowMeter] [varchar](max) NULL,
	[qLowestPeak] [varchar](max) NULL,
	[qHighestPeak] [varchar](max) NULL,
	[qAsthmaDiary] [varchar](max) NULL,
	[qSpirometry] [varchar](max) NULL,
	[qChildImmunization] [varchar](max) NULL,
	[qChildReceiveFlu] [varchar](max) NULL,
	[qParentSmoke] [varchar](max) NULL,
	[qChildSmoke] [varchar](max) NULL,
	[qChildProtectedFromSmoke] [varchar](max) NULL,
	[qChildAsthmaWhileSmoke] [varchar](max) NULL,
	[qChildAsthmaVisittoHealthCare] [varchar](max) NULL,
	[q14] [varchar](max) NULL,
	[q15] [varchar](max) NULL,
	[q15a] [varchar](max) NULL,
	[q15b] [varchar](max) NULL,
	[q16] [varchar](max) NULL,
	[qChildExercise] [varchar](max) NULL,
	[qPhysicalActivity] [varchar](max) NULL,
	[qScale1] [varchar](max) NULL,
	[qScale2] [varchar](max) NULL,
	[qAsthmaControlTreatment] [varchar](max) NULL,
	[InfoRegSelfMgmt] [varchar](max) NULL,
	[comments] [varchar](max) NULL,
	[TotalScore] [varchar](max) NULL,
	[LastModifiedDate] [datetime] NULL,
	[IsLocked] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_ABCBS_HEP_CatchAir_Form] ON [dbo].[ABCBS_HEP_CatchAir_Form]
(
	[ID] ASC
)
INCLUDE([FormDate],[IsLocked]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
CREATE NONCLUSTERED INDEX [IX_ABCBS_HEP_CatchAir_Form_FormDate] ON [dbo].[ABCBS_HEP_CatchAir_Form]
(
	[FormDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]