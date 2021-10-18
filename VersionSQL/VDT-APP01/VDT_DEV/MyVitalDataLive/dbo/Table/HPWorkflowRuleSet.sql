/****** Object:  Table [dbo].[HPWorkflowRuleSet]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[HPWorkflowRuleSet](
	[RuleSetID] [int] IDENTITY(1,1) NOT NULL,
	[RuleID] [varchar](100) NULL,
	[Frequency] [varchar](100) NULL,
	[CreatedDate] [datetime] NULL,
	[UpdatedDate] [datetime] NULL,
	[LastRunDate] [datetime] NULL,
 CONSTRAINT [PK_HPWorkflowRuleSet] PRIMARY KEY CLUSTERED 
(
	[RuleSetID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[HPWorkflowRuleSet] ADD  DEFAULT (getutcdate()) FOR [CreatedDate]
ALTER TABLE [dbo].[HPWorkflowRuleSet] ADD  CONSTRAINT [DF_HPWorkflowRuleSet_UpdatedDate]  DEFAULT (getutcdate()) FOR [UpdatedDate]