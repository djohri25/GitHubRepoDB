/****** Object:  Table [dbo].[LookupCarePlanGoalLibrary]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[LookupCarePlanGoalLibrary](
	[cpLibraryID] [int] NOT NULL,
	[cpGoalLanguage] [nvarchar](50) NOT NULL,
	[cpGoalProblemNumber] [int] NOT NULL,
	[cpGoalNumber] [int] NOT NULL,
	[cpLongGoalText] [nvarchar](max) NULL,
	[cpShortGoalText] [nvarchar](max) NULL,
	[cpInterventionsText] [nvarchar](max) NULL,
 CONSTRAINT [PK_LookupCarePlanGoalLibrary] PRIMARY KEY CLUSTERED 
(
	[cpLibraryID] ASC,
	[cpGoalLanguage] ASC,
	[cpGoalProblemNumber] ASC,
	[cpGoalNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

ALTER TABLE [dbo].[LookupCarePlanGoalLibrary] ADD  CONSTRAINT [DF_LookupCarePlanGoalLibrary_cpGoalLanguage]  DEFAULT (N'ENGLISH') FOR [cpGoalLanguage]