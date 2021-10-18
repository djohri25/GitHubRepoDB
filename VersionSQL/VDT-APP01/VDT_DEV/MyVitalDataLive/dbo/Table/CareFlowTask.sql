/****** Object:  Table [dbo].[CareFlowTask]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[CareFlowTask](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[UniqueRecordCheckSum] [varchar](250) NULL,
	[MVDID] [varchar](50) NOT NULL,
	[RuleId] [smallint] NOT NULL,
	[ExpirationDate] [datetime] NOT NULL,
	[ActionId] [smallint] NULL,
	[CreatedDate] [datetime] NOT NULL,
	[CreatedBy] [varchar](20) NULL,
	[UpdatedDate] [datetime] NOT NULL,
	[UpdatedBy] [varchar](20) NULL,
	[ProductId] [int] NOT NULL,
	[CustomerId] [int] NOT NULL,
	[StatusId] [int] NOT NULL,
	[OwnerGroup] [smallint] NULL,
	[OwnerUser] [varchar](100) NULL,
	[PriorityId] [int] NULL
) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_CareFlowTask_RuleID] ON [dbo].[CareFlowTask]
(
	[RuleId] ASC,
	[CustomerId] ASC,
	[ProductId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
CREATE NONCLUSTERED INDEX [IX_CareFlowTask_UpdatedDate] ON [dbo].[CareFlowTask]
(
	[UpdatedDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
ALTER TABLE [dbo].[CareFlowTask] ADD  CONSTRAINT [DF_CareFlowTask_CreatedDate]  DEFAULT (getutcdate()) FOR [CreatedDate]
ALTER TABLE [dbo].[CareFlowTask] ADD  CONSTRAINT [DF_CareFlowTask_UpdatedDate]  DEFAULT (getutcdate()) FOR [UpdatedDate]
ALTER TABLE [dbo].[CareFlowTask]  WITH NOCHECK ADD  CONSTRAINT [FK_CareFlowTask_HPAlertGroup] FOREIGN KEY([OwnerGroup])
REFERENCES [dbo].[HPAlertGroup] ([ID])
ALTER TABLE [dbo].[CareFlowTask] NOCHECK CONSTRAINT [FK_CareFlowTask_HPAlertGroup]
ALTER TABLE [dbo].[CareFlowTask]  WITH NOCHECK ADD  CONSTRAINT [FK_CareFlowTask_HPCustomer] FOREIGN KEY([CustomerId])
REFERENCES [dbo].[HPCustomer] ([Cust_ID])
ALTER TABLE [dbo].[CareFlowTask] NOCHECK CONSTRAINT [FK_CareFlowTask_HPCustomer]
ALTER TABLE [dbo].[CareFlowTask]  WITH NOCHECK ADD  CONSTRAINT [FK_CareFlowTask_HPWorkflowRule_RuleID] FOREIGN KEY([RuleId])
REFERENCES [dbo].[HPWorkflowRule] ([Rule_ID])
ALTER TABLE [dbo].[CareFlowTask] NOCHECK CONSTRAINT [FK_CareFlowTask_HPWorkflowRule_RuleID]
ALTER TABLE [dbo].[CareFlowTask]  WITH NOCHECK ADD  CONSTRAINT [FK_CareFlowTask_Lookup_Generic_Code] FOREIGN KEY([StatusId])
REFERENCES [dbo].[Lookup_Generic_Code] ([CodeID])
ALTER TABLE [dbo].[CareFlowTask] NOCHECK CONSTRAINT [FK_CareFlowTask_Lookup_Generic_Code]
ALTER TABLE [dbo].[CareFlowTask]  WITH NOCHECK ADD  CONSTRAINT [FK_CareFlowTask_Products] FOREIGN KEY([ProductId])
REFERENCES [dbo].[Products] ([ID])
ALTER TABLE [dbo].[CareFlowTask] NOCHECK CONSTRAINT [FK_CareFlowTask_Products]
ALTER TABLE [dbo].[CareFlowTask]  WITH NOCHECK ADD  CONSTRAINT [FK_CareFlowTask_QuickAction] FOREIGN KEY([ActionId])
REFERENCES [dbo].[QuickAction] ([Id])
ALTER TABLE [dbo].[CareFlowTask] NOCHECK CONSTRAINT [FK_CareFlowTask_QuickAction]