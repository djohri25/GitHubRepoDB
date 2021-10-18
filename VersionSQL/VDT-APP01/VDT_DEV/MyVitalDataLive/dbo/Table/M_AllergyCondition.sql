/****** Object:  Table [dbo].[M_AllergyCondition]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[M_AllergyCondition](
	[AllergyConditionID] [int] NOT NULL,
	[PatientID] [int] NOT NULL,
	[AllergyID] [int] NOT NULL,
	[Reaction] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_AllergyCondition] PRIMARY KEY CLUSTERED 
(
	[AllergyConditionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[M_AllergyCondition]  WITH CHECK ADD  CONSTRAINT [FK_AllergyCondition_Allergy] FOREIGN KEY([AllergyID])
REFERENCES [dbo].[L_Allergy] ([AllergyID])
ALTER TABLE [dbo].[M_AllergyCondition] CHECK CONSTRAINT [FK_AllergyCondition_Allergy]
ALTER TABLE [dbo].[M_AllergyCondition]  WITH CHECK ADD  CONSTRAINT [FK_AllergyCondition_Patient] FOREIGN KEY([PatientID])
REFERENCES [dbo].[M_Patient] ([PatientID])
ALTER TABLE [dbo].[M_AllergyCondition] CHECK CONSTRAINT [FK_AllergyCondition_Patient]