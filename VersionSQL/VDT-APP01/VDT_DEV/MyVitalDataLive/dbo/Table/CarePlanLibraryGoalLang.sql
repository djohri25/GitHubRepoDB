/****** Object:  Table [dbo].[CarePlanLibraryGoalLang]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[CarePlanLibraryGoalLang](
	[cpGoalLangID] [bigint] IDENTITY(1,1) NOT NULL,
	[cpGoalNum] [bigint] NOT NULL,
	[cpGoalLanguage] [smallint] NOT NULL,
	[cpGoalAlternateText] [nvarchar](max) NULL,
	[cpGoalLangActiveDate] [datetime] NULL,
	[cpGoalLangInactiveDate] [datetime] NULL,
	[CreatedDate] [datetime] NOT NULL,
	[CreatedBy] [nvarchar](50) NOT NULL,
	[UpdatedDate] [datetime] NULL,
	[UpdatedBy] [nvarchar](50) NULL,
 CONSTRAINT [PK_CarePlanLibraryGoalLang] PRIMARY KEY CLUSTERED 
(
	[cpGoalLangID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]