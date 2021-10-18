/****** Object:  Table [dbo].[Link_HPRuleChiefComplaint]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Link_HPRuleChiefComplaint](
	[Rule_ID] [smallint] NOT NULL,
	[ChiefComplaint_ID] [int] NOT NULL,
 CONSTRAINT [PK_Link_HPRuleChiefComplaint] PRIMARY KEY CLUSTERED 
(
	[Rule_ID] ASC,
	[ChiefComplaint_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[Link_HPRuleChiefComplaint]  WITH CHECK ADD  CONSTRAINT [FK_Link_HPRuleChiefComplaint_HPAlertRule] FOREIGN KEY([Rule_ID])
REFERENCES [dbo].[HPAlertRule] ([Rule_ID])
ON DELETE CASCADE
ALTER TABLE [dbo].[Link_HPRuleChiefComplaint] CHECK CONSTRAINT [FK_Link_HPRuleChiefComplaint_HPAlertRule]
ALTER TABLE [dbo].[Link_HPRuleChiefComplaint]  WITH CHECK ADD  CONSTRAINT [FK_Link_HPRuleChiefComplaint_LookupChiefComplaint] FOREIGN KEY([ChiefComplaint_ID])
REFERENCES [dbo].[LookupChiefComplaint] ([ID])
ALTER TABLE [dbo].[Link_HPRuleChiefComplaint] CHECK CONSTRAINT [FK_Link_HPRuleChiefComplaint_LookupChiefComplaint]