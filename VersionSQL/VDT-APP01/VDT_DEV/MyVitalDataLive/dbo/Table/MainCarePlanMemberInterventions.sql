/****** Object:  Table [dbo].[MainCarePlanMemberInterventions]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[MainCarePlanMemberInterventions](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[GoalID] [bigint] NOT NULL,
	[seq] [int] NOT NULL,
	[InterventionNum] [bigint] NULL,
	[interventionFreeText] [varchar](max) NULL,
	[Outcome] [int] NULL,
	[CompleteDate] [datetime] NULL,
	[Comment] [varchar](max) NULL,
	[cpInactiveDate] [datetime] NULL,
	[CreatedDate] [datetime] NOT NULL,
	[CreatedBy] [nvarchar](50) NOT NULL,
	[UpdatedDate] [datetime] NULL,
	[UpdatedBy] [nvarchar](50) NULL,
	[Status] [int] NULL,
 CONSTRAINT [PK_MainCarePlanMemberIntervention] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_MainCarePlanMemberInterventions_UpdatedDate] ON [dbo].[MainCarePlanMemberInterventions]
(
	[UpdatedDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]