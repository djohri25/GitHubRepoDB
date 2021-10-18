/****** Object:  Table [dbo].[Link_ConditionLookupCode]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Link_ConditionLookupCode](
	[LookupID] [int] NOT NULL,
	[Code] [varchar](50) NOT NULL,
	[CodingSystem] [varchar](50) NULL,
 CONSTRAINT [PK_Link_ConditionLookupCode] PRIMARY KEY CLUSTERED 
(
	[LookupID] ASC,
	[Code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[Link_ConditionLookupCode]  WITH CHECK ADD  CONSTRAINT [FK_Link_ConditionLookupCode_LookupMemberConditionSummary] FOREIGN KEY([LookupID])
REFERENCES [dbo].[LookupMemberConditionSummary] ([ID])
ALTER TABLE [dbo].[Link_ConditionLookupCode] CHECK CONSTRAINT [FK_Link_ConditionLookupCode_LookupMemberConditionSummary]