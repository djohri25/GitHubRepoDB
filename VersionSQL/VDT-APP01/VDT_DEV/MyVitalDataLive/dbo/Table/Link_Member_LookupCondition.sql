/****** Object:  Table [dbo].[Link_Member_LookupCondition]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Link_Member_LookupCondition](
	[MVDID] [varchar](50) NOT NULL,
	[LookupConditionID] [int] NOT NULL,
 CONSTRAINT [PK_Link_Member_LookupCondition] PRIMARY KEY CLUSTERED 
(
	[MVDID] ASC,
	[LookupConditionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [IX_Link_Member_LookupCondition_MVDID] ON [dbo].[Link_Member_LookupCondition]
(
	[MVDID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
ALTER TABLE [dbo].[Link_Member_LookupCondition]  WITH CHECK ADD  CONSTRAINT [FK_Link_Member_LookupCondition_LookupMemberConditionSummary] FOREIGN KEY([LookupConditionID])
REFERENCES [dbo].[LookupMemberConditionSummary] ([ID])
ALTER TABLE [dbo].[Link_Member_LookupCondition] CHECK CONSTRAINT [FK_Link_Member_LookupCondition_LookupMemberConditionSummary]