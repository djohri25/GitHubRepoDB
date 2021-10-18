/****** Object:  Table [dbo].[CarePlanLibraryInterventionLang]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[CarePlanLibraryInterventionLang](
	[cpInterventionLangID] [bigint] IDENTITY(1,1) NOT NULL,
	[cpInterventionNum] [bigint] NOT NULL,
	[cpInterventionLanguage] [smallint] NOT NULL,
	[cpInterventionAlternateText] [nvarchar](max) NULL,
	[cpInterventionLangActiveDate] [datetime] NULL,
	[cpInterventionLangInactiveDate] [datetime] NULL,
	[CreatedDate] [datetime] NOT NULL,
	[CreatedBy] [nvarchar](50) NOT NULL,
	[UpdatedDate] [datetime] NULL,
	[UpdatedBy] [nvarchar](50) NULL,
 CONSTRAINT [PK_CarePlanLibraryInterventionLang] PRIMARY KEY CLUSTERED 
(
	[cpInterventionLangID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]