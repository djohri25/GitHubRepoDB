/****** Object:  Table [dbo].[Link_HPRuleCopcFacility]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Link_HPRuleCopcFacility](
	[Rule_ID] [smallint] NOT NULL,
	[CopcFacility_ID] [int] NOT NULL,
 CONSTRAINT [PK_Link_HPRuleCopcFacility] PRIMARY KEY CLUSTERED 
(
	[Rule_ID] ASC,
	[CopcFacility_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[Link_HPRuleCopcFacility]  WITH CHECK ADD  CONSTRAINT [FK_Link_HPRuleCopcFacility_HPAlertRule] FOREIGN KEY([Rule_ID])
REFERENCES [dbo].[HPAlertRule] ([Rule_ID])
ON DELETE CASCADE
ALTER TABLE [dbo].[Link_HPRuleCopcFacility] CHECK CONSTRAINT [FK_Link_HPRuleCopcFacility_HPAlertRule]