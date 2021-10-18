/****** Object:  Table [dbo].[Consult_Form]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Consult_Form](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[MVDID] [varchar](20) NOT NULL,
	[FormDate] [datetime] NOT NULL,
	[FormAuthor] [varchar](100) NOT NULL,
	[CaseID] [varchar](100) NULL,
	[SectionCompleted] [varchar](max) NULL,
	[q1ConsultDate] [datetime] NULL,
	[qAccumulators] [varchar](max) NULL,
	[qsecondaryInsurance] [varchar](max) NULL,
	[Language] [varchar](max) NULL,
	[PCPInfo] [varchar](max) NULL,
	[qSpecialistContactInfo] [varchar](max) NULL,
	[q14HealthInfo] [varchar](max) NULL,
	[q14a] [varchar](max) NULL,
	[q15CallTimings] [varchar](max) NULL,
	[q16SocialWorker] [varchar](max) NULL,
	[phoneNumber] [varchar](max) NULL,
	[q19CMPhone1] [varchar](max) NULL,
	[q19CMEmail] [varchar](max) NULL,
	[q19CMLocation] [varchar](max) NULL,
	[q19CMSup] [varchar](max) NULL,
	[UrgencyLevel] [varchar](max) NULL,
	[q20ConsultType] [varchar](max) NULL,
	[q22pharmaConsult] [varchar](max) NULL,
	[q22PharmaclinicalNote] [varchar](max) NULL,
	[q23MedDirConsult] [varchar](max) NULL,
	[q23Diagnosis] [varchar](max) NULL,
	[q23Diagnosis1] [varchar](max) NULL,
	[q23MedDirclinicalNote] [varchar](max) NULL,
	[q24Work] [varchar](max) NULL,
	[q24WorkCall] [varchar](max) NULL,
	[q24WorkConsult] [varchar](max) NULL,
	[q24WorkNeeds] [varchar](max) NULL,
	[q24WorkclinicalNote] [varchar](max) NULL,
	[q25SpecialityConsult] [varchar](max) NULL,
	[q26Program] [varchar](max) NULL,
	[q27Program] [varchar](max) NULL,
	[q28Program] [varchar](max) NULL,
	[q29Program] [varchar](max) NULL,
	[q30SpecialityConsult] [varchar](max) NULL,
	[q30Speciality] [varchar](max) NULL,
	[q31Other] [varchar](max) NULL,
	[q32CMNote] [varchar](max) NULL,
	[q33Diet] [varchar](max) NULL,
	[q34Other] [varchar](max) NULL,
	[q35Summary] [varchar](max) NULL,
	[q36DietNote] [varchar](max) NULL,
	[q1ConsultResponseDate] [datetime] NULL,
	[ResponseUrgencyLevel] [varchar](max) NULL,
	[q3Response] [varchar](max) NULL,
	[LastModifiedDate] [datetime] NULL,
	[qMDInfo] [varchar](max) NULL,
	[q23MedDirConsultNew] [varchar](max) NULL,
	[q23DiagnosisNew] [varchar](max) NULL,
	[q23MedDirConsultRequest] [varchar](max) NULL,
	[q23MedDirBenefits] [varchar](max) NULL,
	[q23MedDirBenefits1] [varchar](max) NULL,
	[q23MedDirExceptionNote] [varchar](max) NULL,
	[q23MedDirExtensionDiscipline] [varchar](max) NULL,
	[q23MedDirLOBBenefit] [varchar](max) NULL,
	[q23MedDirHowmuchBenefit] [varchar](max) NULL,
	[q23MedDirVisitDaysRequested] [varchar](max) NULL,
	[q23MedDirCurrentDiag] [varchar](max) NULL,
	[q23MedDirPastMedHistory] [varchar](max) NULL,
	[q23MedDirBMI] [varchar](max) NULL,
	[q23MedDirBMINum] [varchar](max) NULL,
	[q23MedDirSurgeriesRelated] [varchar](max) NULL,
	[qSWPhnNumber] [varchar](max) NULL,
	[qSWPrimaryDiag] [varchar](max) NULL,
	[qMedDirConsultResponse] [varchar](max) NULL,
	[Version] [varchar](max) NULL,
	[q24WorkConsultV2] [varchar](max) NULL,
	[IsLocked] [varchar](max) NULL,
	[q23LimitedBenefitTherapy] [varchar](max) NULL,
	[q23MedDirBMINA] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_Consult_Form] ON [dbo].[Consult_Form]
(
	[ID] ASC
)
INCLUDE([FormDate],[IsLocked]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
CREATE NONCLUSTERED INDEX [IX_Consult_Form_FormDate] ON [dbo].[Consult_Form]
(
	[FormDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
ALTER TABLE [dbo].[Consult_Form] ADD  CONSTRAINT [DF__Consult_F__LastM__32EDE05C]  DEFAULT (getdate()) FOR [LastModifiedDate]