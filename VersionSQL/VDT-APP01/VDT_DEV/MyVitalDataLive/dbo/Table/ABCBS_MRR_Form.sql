/****** Object:  Table [dbo].[ABCBS_MRR_Form]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[ABCBS_MRR_Form](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[MVDID] [varchar](20) NOT NULL,
	[FormDate] [datetime] NOT NULL,
	[FormAuthor] [varchar](100) NOT NULL,
	[CaseID] [varchar](100) NULL,
	[q1LOB] [varchar](max) NULL,
	[q2MemberLOB] [varchar](max) NULL,
	[q3DateOfService] [varchar](max) NULL,
	[q4ProviderName] [varchar](max) NULL,
	[q5ProviderAddress] [varchar](max) NULL,
	[q6ProviderNPI] [varchar](max) NULL,
	[q7ProviderFaxNumber] [varchar](max) NULL,
	[q8RelevantDiagnosisCodes] [varchar](max) NULL,
	[q9InformationNeeded] [varchar](max) NULL,
	[q10RecurringClinical] [varchar](max) NULL,
	[q11Recurrance] [varchar](max) NULL,
	[q12Other] [varchar](max) NULL,
	[q13RequestExpireDate] [datetime] NULL,
	[q14Comments] [varchar](max) NULL,
	[LastModifiedDate] [datetime] NULL,
	[IsLocked] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_ABCBS_MRR_Form] ON [dbo].[ABCBS_MRR_Form]
(
	[ID] ASC
)
INCLUDE([FormDate],[IsLocked]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
CREATE NONCLUSTERED INDEX [IX_ABCBS_MRR_Form_FormDate] ON [dbo].[ABCBS_MRR_Form]
(
	[FormDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
ALTER TABLE [dbo].[ABCBS_MRR_Form] ADD  DEFAULT (getdate()) FOR [LastModifiedDate]