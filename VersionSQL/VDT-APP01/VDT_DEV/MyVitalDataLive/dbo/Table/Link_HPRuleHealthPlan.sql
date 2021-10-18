/****** Object:  Table [dbo].[Link_HPRuleHealthPlan]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Link_HPRuleHealthPlan](
	[Rule_ID] [smallint] NOT NULL,
	[HealthPlan_ID] [int] NOT NULL,
 CONSTRAINT [PK_Link_HPRuleHealthPlan] PRIMARY KEY CLUSTERED 
(
	[Rule_ID] ASC,
	[HealthPlan_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[Link_HPRuleHealthPlan]  WITH CHECK ADD  CONSTRAINT [FK_Link_HPRuleHealthPlan_HPAlertRule] FOREIGN KEY([Rule_ID])
REFERENCES [dbo].[HPAlertRule] ([Rule_ID])
ON DELETE CASCADE
ALTER TABLE [dbo].[Link_HPRuleHealthPlan] CHECK CONSTRAINT [FK_Link_HPRuleHealthPlan_HPAlertRule]
ALTER TABLE [dbo].[Link_HPRuleHealthPlan]  WITH CHECK ADD  CONSTRAINT [FK_Link_HPRuleHealthPlan_HPHealthPlan] FOREIGN KEY([HealthPlan_ID])
REFERENCES [dbo].[HPHealthPlan] ([HealthPlan_ID])
ALTER TABLE [dbo].[Link_HPRuleHealthPlan] CHECK CONSTRAINT [FK_Link_HPRuleHealthPlan_HPHealthPlan]