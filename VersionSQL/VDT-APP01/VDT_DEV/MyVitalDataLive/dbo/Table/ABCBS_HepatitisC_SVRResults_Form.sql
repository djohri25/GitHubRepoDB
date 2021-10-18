/****** Object:  Table [dbo].[ABCBS_HepatitisC_SVRResults_Form]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[ABCBS_HepatitisC_SVRResults_Form](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[MVDID] [varchar](20) NOT NULL,
	[FormDate] [datetime] NOT NULL,
	[FormAuthor] [varchar](100) NOT NULL,
	[CaseID] [varchar](100) NULL,
	[q1BaseViralLoad] [varchar](max) NULL,
	[q2BaslineViralLoadUndetect] [varchar](max) NULL,
	[q3SVRResult12] [varchar](max) NULL,
	[q4SVRResult12Undetect] [varchar](max) NULL,
	[q5SVRResult24] [varchar](max) NULL,
	[q6SVRResult24Undetect] [varchar](max) NULL,
	[q7Comments] [varchar](max) NULL,
	[LastModifiedDate] [datetime] NULL,
	[IsLocked] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_ABCBS_HepatitisC_SVRResults_Form] ON [dbo].[ABCBS_HepatitisC_SVRResults_Form]
(
	[ID] ASC
)
INCLUDE([FormDate],[IsLocked]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
CREATE NONCLUSTERED INDEX [IX_ABCBS_HepatitisC_SVRResults_Form_FormDate] ON [dbo].[ABCBS_HepatitisC_SVRResults_Form]
(
	[FormDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
ALTER TABLE [dbo].[ABCBS_HepatitisC_SVRResults_Form] ADD  DEFAULT (getdate()) FOR [LastModifiedDate]