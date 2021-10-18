/****** Object:  Table [dbo].[CarePlanLibraryProblems]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[CarePlanLibraryProblems](
	[cpProbNum] [bigint] NOT NULL,
	[cpLibraryID] [bigint] NOT NULL,
	[cpProbText] [nvarchar](max) NOT NULL,
	[cpProblemActiveDate] [datetime] NULL,
	[cpProblemInactiveDate] [datetime] NULL,
	[CreatedDate] [datetime] NOT NULL,
	[CreatedBy] [nvarchar](50) NOT NULL,
	[UpdatedDate] [datetime] NULL,
	[UpdatedBy] [nvarchar](50) NULL,
	[Mapped] [bit] NOT NULL,
	[Category] [nvarchar](max) NULL,
	[LOB] [nvarchar](50) NULL,
	[Dept] [nvarchar](50) NULL,
	[Closed] [bit] NULL,
 CONSTRAINT [PK_CarePlanLibraryProblem] PRIMARY KEY CLUSTERED 
(
	[cpProbNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

ALTER TABLE [dbo].[CarePlanLibraryProblems] ADD  CONSTRAINT [DF_CarePlanLibraryProblems_CreatedDate]  DEFAULT (getdate()) FOR [CreatedDate]
ALTER TABLE [dbo].[CarePlanLibraryProblems] ADD  CONSTRAINT [DF_CarePlanLibraryProblems_CreatedBy]  DEFAULT (suser_sname()) FOR [CreatedBy]
ALTER TABLE [dbo].[CarePlanLibraryProblems] ADD  CONSTRAINT [DF_CarePlanLibraryProblems_Mapped]  DEFAULT ((0)) FOR [Mapped]