/****** Object:  Table [dbo].[Link_HPRuleDisease]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Link_HPRuleDisease](
	[Rule_ID] [smallint] NOT NULL,
	[Disease_ID] [int] NOT NULL,
 CONSTRAINT [PK_Link_HPRuleDisease] PRIMARY KEY CLUSTERED 
(
	[Rule_ID] ASC,
	[Disease_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[Link_HPRuleDisease]  WITH CHECK ADD  CONSTRAINT [FK_Link_HPRuleDisease_HPAlertRule] FOREIGN KEY([Rule_ID])
REFERENCES [dbo].[HPAlertRule] ([Rule_ID])
ON DELETE CASCADE
ALTER TABLE [dbo].[Link_HPRuleDisease] CHECK CONSTRAINT [FK_Link_HPRuleDisease_HPAlertRule]
ALTER TABLE [dbo].[Link_HPRuleDisease]  WITH CHECK ADD  CONSTRAINT [FK_Link_HPRuleDisease_HPDiseaseType] FOREIGN KEY([Disease_ID])
REFERENCES [dbo].[HPDiseaseType] ([Disease_ID])
ALTER TABLE [dbo].[Link_HPRuleDisease] CHECK CONSTRAINT [FK_Link_HPRuleDisease_HPDiseaseType]