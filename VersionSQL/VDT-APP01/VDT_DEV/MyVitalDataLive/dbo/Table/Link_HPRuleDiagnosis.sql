/****** Object:  Table [dbo].[Link_HPRuleDiagnosis]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Link_HPRuleDiagnosis](
	[Rule_ID] [smallint] NOT NULL,
	[Diagnosis_ID] [int] NOT NULL,
 CONSTRAINT [PK_Link_HPRuleDiagnosis] PRIMARY KEY CLUSTERED 
(
	[Rule_ID] ASC,
	[Diagnosis_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[Link_HPRuleDiagnosis]  WITH CHECK ADD  CONSTRAINT [FK_Link_HPRuleDiagnosis_HPAlertRule] FOREIGN KEY([Rule_ID])
REFERENCES [dbo].[HPAlertRule] ([Rule_ID])
ON DELETE CASCADE
ALTER TABLE [dbo].[Link_HPRuleDiagnosis] CHECK CONSTRAINT [FK_Link_HPRuleDiagnosis_HPAlertRule]
ALTER TABLE [dbo].[Link_HPRuleDiagnosis]  WITH CHECK ADD  CONSTRAINT [FK_Link_HPRuleDiagnosis_HPDiagnosis] FOREIGN KEY([Diagnosis_ID])
REFERENCES [dbo].[HPDiagnosis] ([Diagnosis_ID])
ALTER TABLE [dbo].[Link_HPRuleDiagnosis] CHECK CONSTRAINT [FK_Link_HPRuleDiagnosis_HPDiagnosis]