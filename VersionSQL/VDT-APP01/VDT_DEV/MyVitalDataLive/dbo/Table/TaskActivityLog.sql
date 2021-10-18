/****** Object:  Table [dbo].[TaskActivityLog]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[TaskActivityLog](
	[TaskId] [bigint] NOT NULL,
	[Owner] [varchar](100) NULL,
	[DueDate] [datetime] NULL,
	[StatusId] [int] NOT NULL,
	[PriorityId] [int] NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[CreatedBy] [varchar](100) NULL,
	[ReasonForUpdate] [varchar](250) NULL,
	[GroupID] [int] NULL,
	[ID] [bigint] IDENTITY(1,1) NOT NULL
) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_TaskActivityLog_CreatedDate] ON [dbo].[TaskActivityLog]
(
	[CreatedDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
CREATE NONCLUSTERED INDEX [IX_TaskActivityLog_GroupID] ON [dbo].[TaskActivityLog]
(
	[GroupID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [IX_TaskActivityLog_Owner] ON [dbo].[TaskActivityLog]
(
	[Owner] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
CREATE NONCLUSTERED INDEX [IX_TaskActivityLog_TaskID] ON [dbo].[TaskActivityLog]
(
	[TaskId] ASC,
	[CreatedDate] ASC,
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
ALTER TABLE [dbo].[TaskActivityLog] ADD  CONSTRAINT [DF_TaskActivityLog_UpdatedDate]  DEFAULT (getutcdate()) FOR [CreatedDate]
ALTER TABLE [dbo].[TaskActivityLog]  WITH CHECK ADD  CONSTRAINT [FK_TaskActivityLog_Task] FOREIGN KEY([TaskId])
REFERENCES [dbo].[Task] ([Id])
ALTER TABLE [dbo].[TaskActivityLog] CHECK CONSTRAINT [FK_TaskActivityLog_Task]