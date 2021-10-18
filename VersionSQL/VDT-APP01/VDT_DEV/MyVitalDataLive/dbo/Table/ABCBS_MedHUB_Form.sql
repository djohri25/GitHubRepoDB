/****** Object:  Table [dbo].[ABCBS_MedHUB_Form]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[ABCBS_MedHUB_Form](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[MVDID] [varchar](20) NOT NULL,
	[FormDate] [datetime] NOT NULL,
	[FormAuthor] [varchar](100) NOT NULL,
	[CaseID] [varchar](100) NULL,
	[Addr1] [varchar](max) NULL,
	[Addr2] [varchar](max) NULL,
	[Addr3] [varchar](max) NULL,
	[q2Phone] [varchar](max) NULL,
	[q3MainCondtion] [varchar](max) NULL,
	[q4SubCondition1] [varchar](max) NULL,
	[q5Topic1] [varchar](max) NULL,
	[q6Topic2] [varchar](max) NULL,
	[q7MainCondtion2] [varchar](max) NULL,
	[q8SubCondition2] [varchar](max) NULL,
	[q9Topic1] [varchar](max) NULL,
	[q10Topic2] [varchar](max) NULL,
	[q11Other] [varchar](max) NULL,
	[q12Comments] [varchar](max) NULL,
	[LastModifiedDate] [datetime] NULL,
	[IsLocked] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_ABCBS_MedHUB_Form] ON [dbo].[ABCBS_MedHUB_Form]
(
	[ID] ASC
)
INCLUDE([FormDate],[IsLocked]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
CREATE NONCLUSTERED INDEX [IX_ABCBS_MedHUB_Form_FormDate] ON [dbo].[ABCBS_MedHUB_Form]
(
	[FormDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
ALTER TABLE [dbo].[ABCBS_MedHUB_Form] ADD  DEFAULT (getdate()) FOR [LastModifiedDate]