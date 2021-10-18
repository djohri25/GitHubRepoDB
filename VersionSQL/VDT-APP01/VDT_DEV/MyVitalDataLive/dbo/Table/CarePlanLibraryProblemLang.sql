/****** Object:  Table [dbo].[CarePlanLibraryProblemLang]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[CarePlanLibraryProblemLang](
	[cpProbLangID] [bigint] IDENTITY(1,1) NOT NULL,
	[cpProbNum] [bigint] NOT NULL,
	[cpProbLanguage] [smallint] NOT NULL,
	[cpProbAlternateText] [nvarchar](max) NULL,
	[cpProbLangActiveDate] [datetime] NULL,
	[cpProbLangInactiveDate] [datetime] NULL,
	[CreatedDate] [datetime] NOT NULL,
	[CreatedBy] [nvarchar](50) NOT NULL,
	[UpdatedDate] [datetime] NULL,
	[UpdatedBy] [nvarchar](50) NULL,
 CONSTRAINT [PK_CarePlanLibraryProblemLang] PRIMARY KEY CLUSTERED 
(
	[cpProbLangID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]