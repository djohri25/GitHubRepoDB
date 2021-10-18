/****** Object:  Table [dbo].[PatientHealthQuestionnaire_Form]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[PatientHealthQuestionnaire_Form](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[MVDID] [varchar](20) NOT NULL,
	[FormDate] [datetime] NOT NULL,
	[FormAuthor] [varchar](20) NOT NULL,
	[CaseID] [varchar](100) NULL,
	[qA1] [varchar](max) NULL,
	[qA2] [varchar](max) NULL,
	[qA3] [varchar](max) NULL,
	[qA4] [varchar](max) NULL,
	[qA5] [varchar](max) NULL,
	[qA6] [varchar](max) NULL,
	[qA7] [varchar](max) NULL,
	[qA8] [varchar](max) NULL,
	[qA9] [varchar](max) NULL,
	[qA10] [varchar](max) NULL,
	[qA11] [varchar](max) NULL,
	[qA12] [varchar](max) NULL,
	[qA13] [varchar](max) NULL,
	[qA14] [varchar](max) NULL,
	[qA15] [varchar](max) NULL,
	[PHQ15total] [varchar](max) NULL,
	[PHQ15_1] [varchar](max) NULL,
	[PHQ15_2] [varchar](max) NULL,
	[qB1] [varchar](max) NULL,
	[qB2] [varchar](max) NULL,
	[qB3] [varchar](max) NULL,
	[qB4] [varchar](max) NULL,
	[qB5] [varchar](max) NULL,
	[qB6] [varchar](max) NULL,
	[qB7] [varchar](max) NULL,
	[GAD7total] [varchar](max) NULL,
	[GAD7_1] [varchar](max) NULL,
	[GAD7_2] [varchar](max) NULL,
	[GAD7_3] [varchar](max) NULL,
	[qC1] [varchar](max) NULL,
	[qC2] [varchar](max) NULL,
	[qC3] [varchar](max) NULL,
	[qC4] [varchar](max) NULL,
	[qC5] [varchar](max) NULL,
	[qD1] [varchar](max) NULL,
	[qD2] [varchar](max) NULL,
	[qD3] [varchar](max) NULL,
	[qD4] [varchar](max) NULL,
	[qD5] [varchar](max) NULL,
	[qD6] [varchar](max) NULL,
	[qD7] [varchar](max) NULL,
	[qD8] [varchar](max) NULL,
	[qD9] [varchar](max) NULL,
	[PHQ9total] [varchar](max) NULL,
	[PHQ9_1] [varchar](max) NULL,
	[PHQ9_2] [varchar](max) NULL,
	[PHQ9_3] [varchar](max) NULL,
	[qE] [varchar](max) NULL,
	[LastModifiedDate] [datetime] NULL,
	[IsLocked] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_PatientHealthQuestionnaire_Form] ON [dbo].[PatientHealthQuestionnaire_Form]
(
	[ID] ASC
)
INCLUDE([FormDate],[IsLocked]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]