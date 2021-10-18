/****** Object:  Table [dbo].[ABCBS_Transplant_Form]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[ABCBS_Transplant_Form](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[MVDID] [varchar](20) NOT NULL,
	[FormDate] [datetime] NOT NULL,
	[FormAuthor] [varchar](100) NOT NULL,
	[CaseID] [varchar](100) NULL,
	[qTransplantStage] [varchar](max) NULL,
	[qLastCall] [varchar](max) NULL,
	[qEvaluation] [varchar](max) NULL,
	[qComplete] [varchar](max) NULL,
	[qInfections] [varchar](max) NULL,
	[qInfections1] [varchar](max) NULL,
	[qCoordinator] [varchar](max) NULL,
	[qLoseGain] [varchar](max) NULL,
	[qHealthLifeStyle] [varchar](max) NULL,
	[qTobaccoCessation] [varchar](max) NULL,
	[qTobaccoCessation1] [varchar](max) NULL,
	[qSignsOfDepression] [varchar](max) NULL,
	[qRefToNewDir] [varchar](max) NULL,
	[qSignsOfDepressionComments] [varchar](max) NULL,
	[qLabTests] [varchar](max) NULL,
	[qResults] [varchar](max) NULL,
	[qVisitToPhysician] [datetime] NULL,
	[qVisitToCenter] [datetime] NULL,
	[qResults1] [varchar](max) NULL,
	[qConcerns] [varchar](max) NULL,
	[qTimeFrame] [varchar](max) NULL,
	[qCommentsPreStage] [varchar](max) NULL,
	[qAdmitToCenter] [datetime] NULL,
	[qReceiveTransplant] [datetime] NULL,
	[qfeeling] [varchar](max) NULL,
	[qComplications] [varchar](max) NULL,
	[qfeeling1] [varchar](max) NULL,
	[qGlobalConcerns] [varchar](max) NULL,
	[qGlobalTimeFrame] [varchar](max) NULL,
	[qCommentsGlobalStage] [varchar](max) NULL,
	[q1PostStage] [varchar](max) NULL,
	[qPostIssues] [varchar](max) NULL,
	[qHelps] [varchar](max) NULL,
	[qSpokeToDoctor] [varchar](max) NULL,
	[qPainIssues] [varchar](max) NULL,
	[qMedicationChanges] [varchar](max) NULL,
	[q1Changes] [varchar](max) NULL,
	[qObtainMedication] [varchar](max) NULL,
	[qInterventionsChanges] [varchar](max) NULL,
	[qLabsDrawn] [varchar](max) NULL,
	[qActivityLevel] [varchar](max) NULL,
	[qnextAppt] [datetime] NULL,
	[qAnyQuestions] [varchar](max) NULL,
	[qDescribeQuestion] [varchar](max) NULL,
	[qAssessFreq] [varchar](max) NULL,
	[LastModifiedDate] [datetime] NULL,
	[IsLocked] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_ABCBS_Transplant_Form] ON [dbo].[ABCBS_Transplant_Form]
(
	[ID] ASC
)
INCLUDE([FormDate],[IsLocked]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
CREATE NONCLUSTERED INDEX [IX_ABCBS_Transplant_Form_FormDate] ON [dbo].[ABCBS_Transplant_Form]
(
	[FormDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
ALTER TABLE [dbo].[ABCBS_Transplant_Form] ADD  DEFAULT (getdate()) FOR [LastModifiedDate]