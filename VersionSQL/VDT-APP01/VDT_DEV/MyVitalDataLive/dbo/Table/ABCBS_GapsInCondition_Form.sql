/****** Object:  Table [dbo].[ABCBS_GapsInCondition_Form]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[ABCBS_GapsInCondition_Form](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[MVDID] [varchar](30) NOT NULL,
	[FormDate] [datetime] NOT NULL,
	[FormAuthor] [varchar](100) NOT NULL,
	[CaseID] [varchar](100) NULL,
	[Gaps1] [varchar](max) NULL,
	[Gaps1Options] [varchar](max) NULL,
	[Gaps2] [varchar](max) NULL,
	[Gaps2Options] [varchar](max) NULL,
	[Gaps3] [varchar](max) NULL,
	[Gaps3Options] [varchar](max) NULL,
	[Gaps4] [varchar](max) NULL,
	[Gaps4Options] [varchar](max) NULL,
	[Gaps5] [varchar](max) NULL,
	[Gaps5Options] [varchar](max) NULL,
	[Gaps6] [varchar](max) NULL,
	[Gaps6Options] [varchar](max) NULL,
	[Gaps7] [varchar](max) NULL,
	[Gaps7Options] [varchar](max) NULL,
	[Gaps8] [varchar](max) NULL,
	[Gaps8Options] [varchar](max) NULL,
	[Gaps9] [varchar](max) NULL,
	[Gaps9Options] [varchar](max) NULL,
	[Gaps10] [varchar](max) NULL,
	[Gaps10Options] [varchar](max) NULL,
	[Gaps11] [varchar](max) NULL,
	[Gaps11Options] [varchar](max) NULL,
	[Gaps12] [varchar](max) NULL,
	[Gaps12Options] [varchar](max) NULL,
	[Gaps13] [varchar](max) NULL,
	[Gaps13Options] [varchar](max) NULL,
	[Gaps14] [varchar](max) NULL,
	[Gaps14Options] [varchar](max) NULL,
	[Gaps15] [varchar](max) NULL,
	[Gaps15Options] [varchar](max) NULL,
	[Gaps16] [varchar](max) NULL,
	[Gaps16Options] [varchar](max) NULL,
	[Gaps17] [varchar](max) NULL,
	[Gaps17Options] [varchar](max) NULL,
	[Gaps18] [varchar](max) NULL,
	[Gaps18Options] [varchar](max) NULL,
	[Gaps19] [varchar](max) NULL,
	[Gaps19Options] [varchar](max) NULL,
	[Gaps20] [varchar](max) NULL,
	[Gaps20Options] [varchar](max) NULL,
	[Gaps21] [varchar](max) NULL,
	[Gaps21Options] [varchar](max) NULL,
	[Gaps22] [varchar](max) NULL,
	[Gaps22Options] [varchar](max) NULL,
	[Gaps23] [varchar](max) NULL,
	[Gaps23Options] [varchar](max) NULL,
	[Gaps24] [varchar](max) NULL,
	[Gaps24Options] [varchar](max) NULL,
	[Gaps25] [varchar](max) NULL,
	[Gaps25Options] [varchar](max) NULL,
	[EnableQuestion] [varchar](max) NULL,
	[AddedGaps] [varchar](max) NULL,
	[LastModifiedDate] [datetime] NULL,
	[IsLocked] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_ABCBS_GapsInCondition_Form] ON [dbo].[ABCBS_GapsInCondition_Form]
(
	[ID] ASC
)
INCLUDE([FormDate],[IsLocked]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
CREATE NONCLUSTERED INDEX [IX_ABCBS_GapsInCondition_Form_FormDate] ON [dbo].[ABCBS_GapsInCondition_Form]
(
	[FormDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
ALTER TABLE [dbo].[ABCBS_GapsInCondition_Form] ADD  DEFAULT (getdate()) FOR [LastModifiedDate]