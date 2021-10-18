/****** Object:  Table [dbo].[ABCBS_FEPDMEnrollment_Form]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[ABCBS_FEPDMEnrollment_Form](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[MVDID] [varchar](30) NOT NULL,
	[FormDate] [datetime] NOT NULL,
	[FormAuthor] [varchar](100) NOT NULL,
	[CaseID] [varchar](100) NULL,
	[qMemberStatus] [varchar](max) NULL,
	[qFEPDM] [datetime] NULL,
	[PrimaryCondition] [varchar](max) NULL,
	[qComorbidities] [varchar](max) NULL,
	[qPlanstratification] [varchar](max) NULL,
	[qMemGoals] [varchar](max) NULL,
	[qRefSource] [varchar](max) NULL,
	[qFEPRefDate] [datetime] NULL,
	[qFEPDMComment] [varchar](max) NULL,
	[qMemAdded] [varchar](max) NULL,
	[qNetworkProvider] [varchar](max) NULL,
	[LastModifiedDate] [datetime] NULL,
	[IsLocked] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_ABCBS_FEPDMEnrollment_Form] ON [dbo].[ABCBS_FEPDMEnrollment_Form]
(
	[ID] ASC
)
INCLUDE([FormDate],[IsLocked]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
CREATE NONCLUSTERED INDEX [IX_ABCBS_FEPDMEnrollment_Form_FormDate] ON [dbo].[ABCBS_FEPDMEnrollment_Form]
(
	[FormDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
ALTER TABLE [dbo].[ABCBS_FEPDMEnrollment_Form] ADD  CONSTRAINT [DF__ABCBS_FEP__LastM__1839EA20]  DEFAULT (getdate()) FOR [LastModifiedDate]