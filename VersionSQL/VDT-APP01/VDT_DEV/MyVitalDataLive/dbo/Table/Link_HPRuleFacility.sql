/****** Object:  Table [dbo].[Link_HPRuleFacility]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Link_HPRuleFacility](
	[Rule_ID] [smallint] NOT NULL,
	[Facility_ID] [int] NOT NULL,
 CONSTRAINT [PK_Link_HPRuleFacility] PRIMARY KEY CLUSTERED 
(
	[Rule_ID] ASC,
	[Facility_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[Link_HPRuleFacility]  WITH CHECK ADD  CONSTRAINT [FK_Link_HPRuleFacility_HPAlertRule] FOREIGN KEY([Rule_ID])
REFERENCES [dbo].[HPAlertRule] ([Rule_ID])
ON DELETE CASCADE
ALTER TABLE [dbo].[Link_HPRuleFacility] CHECK CONSTRAINT [FK_Link_HPRuleFacility_HPAlertRule]