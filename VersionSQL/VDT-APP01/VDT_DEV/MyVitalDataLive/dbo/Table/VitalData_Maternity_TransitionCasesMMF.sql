/****** Object:  Table [dbo].[VitalData_Maternity_TransitionCasesMMF]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[VitalData_Maternity_TransitionCasesMMF](
	[member_id] [varchar](50) NULL,
	[HRAScore] [varchar](50) NULL,
	[CCACaseId] [varchar](50) NULL,
	[EnrollDate] [varchar](50) NULL,
	[PregnancyDueDate] [varchar](50) NULL,
	[GestationAtEnrollment] [varchar](50) NULL,
	[ReferralSource] [varchar](50) NULL,
	[ReferralReason] [varchar](50) NULL,
	[CaseProgram] [varchar](50) NULL,
	[ViableReferral] [varchar](50) NULL,
	[AssignUser] [varchar](50) NULL,
	[ContactedSuccessfully] [varchar](50) NULL,
	[OfferedCM] [varchar](50) NULL,
	[ChronicConditions] [varchar](50) NULL,
	[Consented] [varchar](50) NULL,
	[ConsentDate] [varchar](50) NULL,
	[CaseChronicConditions] [varchar](50) NULL,
	[CaseCategory] [varchar](50) NULL,
	[CaseType] [varchar](50) NULL,
	[CaseLevel] [varchar](50) NULL,
	[CaseClosed] [varchar](50) NULL,
	[AssignToUserOrCareQ] [varchar](50) NULL,
	[CaseOpenSummary] [varchar](50) NULL
) ON [PRIMARY]