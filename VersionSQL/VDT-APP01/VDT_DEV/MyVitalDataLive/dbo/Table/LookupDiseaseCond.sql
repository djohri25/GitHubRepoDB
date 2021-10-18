/****** Object:  Table [dbo].[LookupDiseaseCond]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[LookupDiseaseCond](
	[DiseaseCondId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[DiseaseId] [int] NULL,
	[DiseaseCondName] [varchar](50) NULL,
	[IsMajor] [bit] NULL,
 CONSTRAINT [PK_LookDiaseseCond] PRIMARY KEY CLUSTERED 
(
	[DiseaseCondId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_DiseaseId] ON [dbo].[LookupDiseaseCond]
(
	[DiseaseId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
ALTER TABLE [dbo].[LookupDiseaseCond]  WITH CHECK ADD  CONSTRAINT [FK_LookupDiaseseCond_LookupDisease] FOREIGN KEY([DiseaseId])
REFERENCES [dbo].[LookupDisease] ([DiseaseId])
ON UPDATE CASCADE
ALTER TABLE [dbo].[LookupDiseaseCond] CHECK CONSTRAINT [FK_LookupDiaseseCond_LookupDisease]