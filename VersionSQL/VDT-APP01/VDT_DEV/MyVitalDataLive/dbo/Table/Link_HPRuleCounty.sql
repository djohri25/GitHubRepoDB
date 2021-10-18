/****** Object:  Table [dbo].[Link_HPRuleCounty]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Link_HPRuleCounty](
	[Rule_ID] [smallint] NOT NULL,
	[County_ID] [varchar](20) NOT NULL,
 CONSTRAINT [PK_Link_HPRuleCounty] PRIMARY KEY CLUSTERED 
(
	[Rule_ID] ASC,
	[County_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[Link_HPRuleCounty]  WITH CHECK ADD  CONSTRAINT [FK_Link_HPRuleCounty_HPAlertRule] FOREIGN KEY([Rule_ID])
REFERENCES [dbo].[HPAlertRule] ([Rule_ID])
ON DELETE CASCADE
ALTER TABLE [dbo].[Link_HPRuleCounty] CHECK CONSTRAINT [FK_Link_HPRuleCounty_HPAlertRule]