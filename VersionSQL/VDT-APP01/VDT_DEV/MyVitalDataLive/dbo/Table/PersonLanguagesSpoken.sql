/****** Object:  Table [dbo].[PersonLanguagesSpoken]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[PersonLanguagesSpoken](
	[PersonID] [varchar](50) NOT NULL,
	[PersonCategory] [varchar](50) NULL,
	[LanguageID] [int] NOT NULL,
 CONSTRAINT [PK_PersonLanguagesSpoken] PRIMARY KEY CLUSTERED 
(
	[PersonID] ASC,
	[LanguageID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[PersonLanguagesSpoken]  WITH CHECK ADD  CONSTRAINT [FK_PersonLanguagesSpoken_LookupLanguage] FOREIGN KEY([LanguageID])
REFERENCES [dbo].[LookupLanguage] ([ID])
ALTER TABLE [dbo].[PersonLanguagesSpoken] CHECK CONSTRAINT [FK_PersonLanguagesSpoken_LookupLanguage]