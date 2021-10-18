/****** Object:  Table [dbo].[Link_HPRuleAlertGroup]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Link_HPRuleAlertGroup](
	[Rule_ID] [smallint] NOT NULL,
	[AlertGroup_ID] [smallint] NOT NULL,
 CONSTRAINT [PK_Link_HPRuleAlertGroup] PRIMARY KEY CLUSTERED 
(
	[Rule_ID] ASC,
	[AlertGroup_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[Link_HPRuleAlertGroup]  WITH CHECK ADD  CONSTRAINT [FK_Link_HPRuleAlertGroup_HPAlertGroup] FOREIGN KEY([AlertGroup_ID])
REFERENCES [dbo].[HPAlertGroup] ([ID])
ALTER TABLE [dbo].[Link_HPRuleAlertGroup] CHECK CONSTRAINT [FK_Link_HPRuleAlertGroup_HPAlertGroup]
ALTER TABLE [dbo].[Link_HPRuleAlertGroup]  WITH NOCHECK ADD  CONSTRAINT [FK_Link_HPRuleAlertGroup_HPAlertRule] FOREIGN KEY([Rule_ID])
REFERENCES [dbo].[HPAlertRule] ([Rule_ID])
ON DELETE CASCADE
ALTER TABLE [dbo].[Link_HPRuleAlertGroup] NOCHECK CONSTRAINT [FK_Link_HPRuleAlertGroup_HPAlertRule]