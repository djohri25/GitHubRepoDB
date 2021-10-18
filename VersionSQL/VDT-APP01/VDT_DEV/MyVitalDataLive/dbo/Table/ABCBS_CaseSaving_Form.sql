/****** Object:  Table [dbo].[ABCBS_CaseSaving_Form]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[ABCBS_CaseSaving_Form](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[MVDID] [varchar](20) NOT NULL,
	[FormDate] [datetime] NOT NULL,
	[FormAuthor] [varchar](100) NOT NULL,
	[CaseID] [varchar](100) NULL,
	[qCaseID] [varchar](max) NULL,
	[FromDate] [datetime] NULL,
	[ToDate] [datetime] NULL,
	[ActualCost] [varchar](max) NULL,
	[ProjectedCost] [varchar](max) NULL,
	[TotalSavings] [varchar](max) NULL,
	[SavingsType] [varchar](max) NULL,
	[SavingsTypeOther] [varchar](max) NULL,
	[Category] [varchar](max) NULL,
	[comments] [varchar](max) NULL,
	[LastModifiedDate] [datetime] NULL,
	[IsLocked] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_ABCBS_CaseSaving_Form_FormDate] ON [dbo].[ABCBS_CaseSaving_Form]
(
	[FormDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
ALTER TABLE [dbo].[ABCBS_CaseSaving_Form] ADD  DEFAULT (getdate()) FOR [LastModifiedDate]