/****** Object:  Table [dbo].[Link_HPRuleAgent]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Link_HPRuleAgent](
	[Rule_ID] [smallint] NOT NULL,
	[Agent_ID] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_Link_HPRuleAgent] PRIMARY KEY CLUSTERED 
(
	[Rule_ID] ASC,
	[Agent_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[Link_HPRuleAgent]  WITH CHECK ADD  CONSTRAINT [FK_Link_HPRuleAgent_HPAlertRule] FOREIGN KEY([Rule_ID])
REFERENCES [dbo].[HPAlertRule] ([Rule_ID])
ON DELETE CASCADE
ALTER TABLE [dbo].[Link_HPRuleAgent] CHECK CONSTRAINT [FK_Link_HPRuleAgent_HPAlertRule]