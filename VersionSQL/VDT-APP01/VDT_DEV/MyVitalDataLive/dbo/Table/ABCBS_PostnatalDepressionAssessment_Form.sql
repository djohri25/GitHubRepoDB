/****** Object:  Table [dbo].[ABCBS_PostnatalDepressionAssessment_Form]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[ABCBS_PostnatalDepressionAssessment_Form](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[MVDID] [varchar](30) NOT NULL,
	[FormDate] [datetime] NOT NULL,
	[FormAuthor] [varchar](100) NOT NULL,
	[CaseID] [varchar](100) NULL,
	[qLaughandFunny] [varchar](max) NULL,
	[q2LookedForward] [varchar](max) NULL,
	[q3BlamedMyself] [varchar](max) NULL,
	[q4Anxious] [varchar](max) NULL,
	[q5Scared] [varchar](max) NULL,
	[q6Topofme] [varchar](max) NULL,
	[q7UnHappy] [varchar](max) NULL,
	[q8Sad] [varchar](max) NULL,
	[q9Crying] [varchar](max) NULL,
	[q10Harming] [varchar](max) NULL,
	[TotalScore] [varchar](max) NULL,
	[LastModifiedDate] [datetime] NULL,
	[IsLocked] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_ABCBS_PostnatalDepressionAssessment_Form] ON [dbo].[ABCBS_PostnatalDepressionAssessment_Form]
(
	[ID] ASC
)
INCLUDE([FormDate],[IsLocked]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]