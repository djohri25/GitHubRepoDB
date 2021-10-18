/****** Object:  Table [dbo].[Task]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Task](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[Title] [nvarchar](100) NOT NULL,
	[Narrative] [nvarchar](max) NOT NULL,
	[MVDID] [varchar](20) NOT NULL,
	[CustomerId] [int] NOT NULL,
	[ProductId] [int] NOT NULL,
	[Author] [varchar](100) NULL,
	[CreatedDate] [datetime] NOT NULL,
	[UpdatedDate] [datetime] NULL,
	[ReminderDate] [datetime] NULL,
	[CompletedDate] [datetime] NULL,
	[PercentComplete] [tinyint] NULL,
	[TypeId] [int] NOT NULL,
	[ParentTaskId] [bigint] NULL,
	[TaskLibraryId] [int] NULL,
	[AutomationProcId] [int] NULL,
	[SensitivityId] [int] NULL,
	[AccountingId] [int] NULL,
	[CaseId] [varchar](50) NULL,
	[UpdatedBy] [varchar](100) NULL,
	[IsDelete] [bit] NULL,
	[Owner] [varchar](100) NULL,
	[DueDate] [datetime] NULL,
	[StatusID] [int] NULL,
	[PriorityID] [int] NULL,
	[GroupID] [int] NULL,
 CONSTRAINT [PK_Task2] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [SECONDARY]
) ON [SECONDARY] TEXTIMAGE_ON [SECONDARY]

CREATE NONCLUSTERED INDEX [IX_Task_Customer_ProductID_Isdelete] ON [dbo].[Task]
(
	[CustomerId] ASC,
	[ProductId] ASC,
	[IsDelete] ASC
)
INCLUDE([Id],[Title],[MVDID],[Author],[CreatedDate],[ReminderDate],[ParentTaskId],[UpdatedBy]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [SECONDARY]
CREATE NONCLUSTERED INDEX [IX_Task_GroupID] ON [dbo].[Task]
(
	[GroupID] ASC
)
INCLUDE([CaseId],[CustomerId],[ProductId]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 85) ON [SECONDARY]
SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [IX_Task_MVDID] ON [dbo].[Task]
(
	[MVDID] ASC
)
INCLUDE([CaseId],[CustomerId],[ProductId]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 85) ON [SECONDARY]
SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [IX_Task_Owner] ON [dbo].[Task]
(
	[Owner] ASC
)
INCLUDE([CaseId],[CustomerId],[ProductId]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 85) ON [SECONDARY]
CREATE NONCLUSTERED INDEX [IX_Task_UpdatedDate] ON [dbo].[Task]
(
	[UpdatedDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [SECONDARY]
ALTER TABLE [dbo].[Task] ADD  CONSTRAINT [DF_Task2_CreatedDate]  DEFAULT (getutcdate()) FOR [CreatedDate]