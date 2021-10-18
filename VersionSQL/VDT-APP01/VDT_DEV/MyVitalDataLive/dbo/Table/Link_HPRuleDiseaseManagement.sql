/****** Object:  Table [dbo].[Link_HPRuleDiseaseManagement]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Link_HPRuleDiseaseManagement](
	[Rule_ID] [smallint] NOT NULL,
	[DM_ID] [int] NOT NULL,
 CONSTRAINT [PK_Link_HPRuleDiseaseManagement] PRIMARY KEY CLUSTERED 
(
	[Rule_ID] ASC,
	[DM_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[Link_HPRuleDiseaseManagement]  WITH CHECK ADD  CONSTRAINT [FK_Link_HPRuleDiseaseManagement_HPAlertRule] FOREIGN KEY([Rule_ID])
REFERENCES [dbo].[HPAlertRule] ([Rule_ID])
ON DELETE CASCADE
ALTER TABLE [dbo].[Link_HPRuleDiseaseManagement] CHECK CONSTRAINT [FK_Link_HPRuleDiseaseManagement_HPAlertRule]
ALTER TABLE [dbo].[Link_HPRuleDiseaseManagement]  WITH CHECK ADD  CONSTRAINT [FK_Link_HPRuleDiseaseManagement_HPDiseaseManagement] FOREIGN KEY([DM_ID])
REFERENCES [dbo].[HPDiseaseManagement] ([DM_ID])
ALTER TABLE [dbo].[Link_HPRuleDiseaseManagement] CHECK CONSTRAINT [FK_Link_HPRuleDiseaseManagement_HPDiseaseManagement]