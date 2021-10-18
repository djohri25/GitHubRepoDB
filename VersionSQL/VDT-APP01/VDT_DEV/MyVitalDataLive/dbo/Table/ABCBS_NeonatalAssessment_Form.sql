/****** Object:  Table [dbo].[ABCBS_NeonatalAssessment_Form]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[ABCBS_NeonatalAssessment_Form](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[MVDID] [varchar](20) NOT NULL,
	[FormDate] [datetime] NOT NULL,
	[FormAuthor] [varchar](100) NOT NULL,
	[CaseID] [varchar](100) NULL,
	[q1MomInMaternityProgram] [varchar](max) NULL,
	[qParentFullName] [varchar](max) NULL,
	[qParentHomePhone] [varchar](max) NULL,
	[qParentCellPhone] [varchar](max) NULL,
	[qDOB1] [datetime] NULL,
	[qAdmitting] [varchar](max) NULL,
	[qBabyGestationalAge] [varchar](max) NULL,
	[qBabyBirthWeight] [varchar](max) NULL,
	[qBabyApgarScore] [varchar](max) NULL,
	[qBabyApgarScore1] [varchar](max) NULL,
	[qO2Needs] [varchar](max) NULL,
	[qTypeOfBed] [varchar](max) NULL,
	[qBabyFeed] [varchar](max) NULL,
	[qVolumeofFeed] [varchar](max) NULL,
	[qBreastMilk] [varchar](max) NULL,
	[qwhatPlace] [varchar](max) NULL,
	[qRecentHUS] [varchar](max) NULL,
	[qRecentCXR] [varchar](max) NULL,
	[qSignificantTest] [varchar](max) NULL,
	[qTransfusions] [varchar](max) NULL,
	[LastModifiedDate] [datetime] NULL,
	[IsLocked] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_ABCBS_NeonatalAssessment_Form] ON [dbo].[ABCBS_NeonatalAssessment_Form]
(
	[ID] ASC
)
INCLUDE([FormDate],[IsLocked]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
CREATE NONCLUSTERED INDEX [IX_ABCBS_NeonatalAssessment_Form_FormDate] ON [dbo].[ABCBS_NeonatalAssessment_Form]
(
	[FormDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
ALTER TABLE [dbo].[ABCBS_NeonatalAssessment_Form] ADD  DEFAULT (getdate()) FOR [LastModifiedDate]