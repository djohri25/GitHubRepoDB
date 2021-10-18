/****** Object:  Table [dbo].[LookupCarePlanProblemLibrary]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[LookupCarePlanProblemLibrary](
	[cpLibraryID] [int] NOT NULL,
	[cpProbLanguage] [nvarchar](50) NOT NULL,
	[cpProbNumber] [int] NOT NULL,
	[cpProbText] [nvarchar](max) NOT NULL,
 CONSTRAINT [PK_LookupCarePlanProblemLibrary] PRIMARY KEY CLUSTERED 
(
	[cpLibraryID] ASC,
	[cpProbLanguage] ASC,
	[cpProbNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

ALTER TABLE [dbo].[LookupCarePlanProblemLibrary] ADD  CONSTRAINT [DF_LookupCarePlanProblemLibrary_cpProbLanguage]  DEFAULT (N'ENGLISH') FOR [cpProbLanguage]