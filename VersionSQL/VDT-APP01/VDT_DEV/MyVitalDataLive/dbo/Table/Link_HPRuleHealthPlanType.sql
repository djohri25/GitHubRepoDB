/****** Object:  Table [dbo].[Link_HPRuleHealthPlanType]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Link_HPRuleHealthPlanType](
	[Rule_ID] [smallint] NOT NULL,
	[HealthPlanType_ID] [int] NOT NULL,
 CONSTRAINT [PK_Link_HPRuleHealthPlanType] PRIMARY KEY CLUSTERED 
(
	[Rule_ID] ASC,
	[HealthPlanType_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[Link_HPRuleHealthPlanType]  WITH CHECK ADD  CONSTRAINT [FK_Link_HPRuleHealthPlanType_HPAlertRule] FOREIGN KEY([Rule_ID])
REFERENCES [dbo].[HPAlertRule] ([Rule_ID])
ON DELETE CASCADE
ALTER TABLE [dbo].[Link_HPRuleHealthPlanType] CHECK CONSTRAINT [FK_Link_HPRuleHealthPlanType_HPAlertRule]
ALTER TABLE [dbo].[Link_HPRuleHealthPlanType]  WITH CHECK ADD  CONSTRAINT [FK_Link_HPRuleHealthPlanType_HPHealthPlanType] FOREIGN KEY([HealthPlanType_ID])
REFERENCES [dbo].[HPHealthPlanType] ([HealthPlanType_ID])
ALTER TABLE [dbo].[Link_HPRuleHealthPlanType] CHECK CONSTRAINT [FK_Link_HPRuleHealthPlanType_HPHealthPlanType]