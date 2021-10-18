/****** Object:  Table [dbo].[CarePlanLibraryGoals]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[CarePlanLibraryGoals](
	[cpGoalNum] [bigint] NOT NULL,
	[cpProbNum] [bigint] NOT NULL,
	[cpGoalType] [bit] NULL,
	[cpGoalText] [nvarchar](max) NOT NULL,
	[cpGoalActiveDate] [datetime] NULL,
	[cpGoalInactiveDate] [datetime] NULL,
	[CreatedDate] [datetime] NOT NULL,
	[CreatedBy] [nvarchar](50) NOT NULL,
	[UpdatedDate] [datetime] NULL,
	[UpdatedBy] [nvarchar](50) NULL,
 CONSTRAINT [PK_CarePlanLibraryGoal] PRIMARY KEY CLUSTERED 
(
	[cpGoalNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

ALTER TABLE [dbo].[CarePlanLibraryGoals] ADD  CONSTRAINT [DF_CarePlanLibraryGoals_cpGoalType]  DEFAULT ((0)) FOR [cpGoalType]
ALTER TABLE [dbo].[CarePlanLibraryGoals] ADD  CONSTRAINT [DF_CarePlanLibraryGoals_CreatedDate]  DEFAULT (getdate()) FOR [CreatedDate]
ALTER TABLE [dbo].[CarePlanLibraryGoals] ADD  CONSTRAINT [DF_CarePlanLibraryGoals_CreatedBy]  DEFAULT (suser_sname()) FOR [CreatedBy]