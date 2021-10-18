/****** Object:  Table [dbo].[ABCBS_Bariatric_Form]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[ABCBS_Bariatric_Form](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[MVDID] [varchar](30) NOT NULL,
	[FormDate] [datetime] NOT NULL,
	[FormAuthor] [varchar](100) NOT NULL,
	[CaseID] [varchar](100) NULL,
	[Version] [varchar](max) NULL,
	[SectionCompleted] [varchar](max) NULL,
	[qEnrollmentDate] [datetime] NULL,
	[qEligibilityDate] [datetime] NULL,
	[qStatusInProgram] [varchar](max) NULL,
	[qWeight] [varchar](max) NULL,
	[qHeightFeet] [varchar](max) NULL,
	[qHeightInches] [varchar](max) NULL,
	[qBMI] [varchar](max) NULL,
	[qSurgeryDate] [datetime] NULL,
	[qSurgeonName] [varchar](max) NULL,
	[qFacilityStatus] [varchar](max) NULL,
	[qFacilityName] [varchar](max) NULL,
	[qSurgeryType] [varchar](max) NULL,
	[qCurrentWeight] [varchar](max) NULL,
	[qCurrentBMI] [varchar](max) NULL,
	[qCompletedProgram] [varchar](max) NULL,
	[LastModifiedDate] [datetime] NULL,
	[IsLocked] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_ABCBS_Bariatric_Form] ON [dbo].[ABCBS_Bariatric_Form]
(
	[ID] ASC
)
INCLUDE([FormDate],[IsLocked]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]