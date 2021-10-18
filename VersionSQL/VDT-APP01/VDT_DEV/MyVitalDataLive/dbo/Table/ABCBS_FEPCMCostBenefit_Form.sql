/****** Object:  Table [dbo].[ABCBS_FEPCMCostBenefit_Form]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[ABCBS_FEPCMCostBenefit_Form](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[MVDID] [varchar](30) NOT NULL,
	[FormDate] [datetime] NOT NULL,
	[FormAuthor] [varchar](100) NOT NULL,
	[CaseID] [varchar](100) NULL,
	[CaseList] [varchar](max) NULL,
	[qCaseStatus] [varchar](max) NULL,
	[qGenDiagnosis] [varchar](max) NULL,
	[qSpecificDiagnosis] [varchar](max) NULL,
	[qPertinentMedicalHistroy] [varchar](max) NULL,
	[qIssuesIdentified] [varchar](max) NULL,
	[qIssuesIdentifiedOther] [varchar](max) NULL,
	[qIntervention] [varchar](max) NULL,
	[qInterventionOther] [varchar](max) NULL,
	[qCaseSavings] [varchar](max) NULL,
	[qInterventionOutComes] [varchar](max) NULL,
	[qInterventionOutComesOther] [varchar](max) NULL,
	[qBenefits] [varchar](max) NULL,
	[qFBOptionExist] [varchar](max) NULL,
	[qFBApplies] [varchar](max) NULL,
	[qFBORTCStartDate] [datetime] NULL,
	[qFBORTCEndDate] [datetime] NULL,
	[qFBOSNFStartDate] [datetime] NULL,
	[qFBOSNFEndDate] [datetime] NULL,
	[qFBOPTStartDate] [datetime] NULL,
	[qFBOPTEndDate] [datetime] NULL,
	[FBOPTVisits] [varchar](max) NULL,
	[qFBOSTStartDate] [datetime] NULL,
	[qFBOSTEndDate] [datetime] NULL,
	[FBOSTVisits] [varchar](max) NULL,
	[qFBOOccoupationalTStartDate] [datetime] NULL,
	[qFBOOccoupationalTEndDate] [datetime] NULL,
	[FBOOccoupationalTVisits] [varchar](max) NULL,
	[qFBOSNVStartDate] [datetime] NULL,
	[qFBOSNVEndDate] [datetime] NULL,
	[FBOSNVVisits] [varchar](max) NULL,
	[qFBOtherText] [varchar](max) NULL,
	[qFBOtherStartDate] [datetime] NULL,
	[qFBOtherEndDate] [datetime] NULL,
	[FBOtherVisits] [varchar](max) NULL,
	[FBOtherVisits1] [varchar](max) NULL,
	[LastModifiedDate] [datetime] NULL,
	[IsLocked] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_ABCBS_FEPCMCostBenefit_Form] ON [dbo].[ABCBS_FEPCMCostBenefit_Form]
(
	[ID] ASC
)
INCLUDE([FormDate],[IsLocked]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
CREATE NONCLUSTERED INDEX [IX_ABCBS_FEPCMCostBenefit_Form_FormDate] ON [dbo].[ABCBS_FEPCMCostBenefit_Form]
(
	[FormDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
ALTER TABLE [dbo].[ABCBS_FEPCMCostBenefit_Form] ADD  DEFAULT (getdate()) FOR [LastModifiedDate]