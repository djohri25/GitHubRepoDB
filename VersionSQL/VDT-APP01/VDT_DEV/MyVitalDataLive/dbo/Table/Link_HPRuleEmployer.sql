/****** Object:  Table [dbo].[Link_HPRuleEmployer]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Link_HPRuleEmployer](
	[Rule_ID] [smallint] NOT NULL,
	[Employer_ID] [int] NOT NULL,
 CONSTRAINT [PK_Link_HPRuleEmployer] PRIMARY KEY CLUSTERED 
(
	[Rule_ID] ASC,
	[Employer_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[Link_HPRuleEmployer]  WITH CHECK ADD  CONSTRAINT [FK_Link_HPRuleEmployer_HPAlertRule] FOREIGN KEY([Rule_ID])
REFERENCES [dbo].[HPAlertRule] ([Rule_ID])
ON DELETE CASCADE
ALTER TABLE [dbo].[Link_HPRuleEmployer] CHECK CONSTRAINT [FK_Link_HPRuleEmployer_HPAlertRule]
ALTER TABLE [dbo].[Link_HPRuleEmployer]  WITH CHECK ADD  CONSTRAINT [FK_Link_HPRuleEmployer_HPEmployer] FOREIGN KEY([Employer_ID])
REFERENCES [dbo].[HPEmployer] ([Employer_ID])
ALTER TABLE [dbo].[Link_HPRuleEmployer] CHECK CONSTRAINT [FK_Link_HPRuleEmployer_HPEmployer]