/****** Object:  Table [dbo].[Link_Disease_Code]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Link_Disease_Code](
	[DiseaseID] [int] NOT NULL,
	[CodeFirst3] [varchar](50) NOT NULL,
 CONSTRAINT [PK_Link_Disease_Code] PRIMARY KEY CLUSTERED 
(
	[DiseaseID] ASC,
	[CodeFirst3] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[Link_Disease_Code]  WITH CHECK ADD  CONSTRAINT [FK_Link_Disease_Code_HPDiseaseType] FOREIGN KEY([DiseaseID])
REFERENCES [dbo].[HPDiseaseType] ([Disease_ID])
ALTER TABLE [dbo].[Link_Disease_Code] CHECK CONSTRAINT [FK_Link_Disease_Code_HPDiseaseType]