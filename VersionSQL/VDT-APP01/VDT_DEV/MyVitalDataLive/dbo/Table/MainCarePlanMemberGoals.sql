/****** Object:  Table [dbo].[MainCarePlanMemberGoals]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[MainCarePlanMemberGoals](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[ProblemID] [bigint] NOT NULL,
	[seq] [int] NOT NULL,
	[GoalNum] [bigint] NULL,
	[goalFreeText] [varchar](max) NULL,
	[goalType] [char](1) NOT NULL,
	[Outcome] [int] NULL,
	[TargetDate] [datetime] NULL,
	[CompleteDate] [datetime] NULL,
	[Comment] [varchar](max) NULL,
	[cpInactiveDate] [datetime] NULL,
	[CreatedDate] [datetime] NOT NULL,
	[CreatedBy] [nvarchar](50) NOT NULL,
	[UpdatedDate] [datetime] NULL,
	[UpdatedBy] [nvarchar](50) NULL,
 CONSTRAINT [PK_MainCarePlanMemberGoals] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_MainCarePlanMemberGoals_UpdatedDate] ON [dbo].[MainCarePlanMemberGoals]
(
	[UpdatedDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
ALTER TABLE [dbo].[MainCarePlanMemberGoals] ADD  CONSTRAINT [DF__MainCareP__goalT__330D1096]  DEFAULT ('S') FOR [goalType]