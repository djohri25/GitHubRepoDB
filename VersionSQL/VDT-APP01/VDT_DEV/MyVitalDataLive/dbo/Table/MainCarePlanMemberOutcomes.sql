/****** Object:  Table [dbo].[MainCarePlanMemberOutcomes]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[MainCarePlanMemberOutcomes](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[ProblemID] [bigint] NOT NULL,
	[seq] [int] NOT NULL,
	[OutcomeNum] [bigint] NULL,
	[outcomeFreeText] [varchar](max) NULL,
	[Status] [int] NULL,
	[CompleteDate] [datetime] NULL,
	[cpInactiveDate] [datetime] NULL,
	[CreatedDate] [datetime] NOT NULL,
	[CreatedBy] [nvarchar](50) NOT NULL,
	[UpdatedDate] [datetime] NULL,
	[UpdatedBy] [nvarchar](50) NULL,
 CONSTRAINT [PK_MainCarePlanMemberOutcomes] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_MainCarePlanMemberOutcomes_UpdatedDate] ON [dbo].[MainCarePlanMemberOutcomes]
(
	[UpdatedDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]