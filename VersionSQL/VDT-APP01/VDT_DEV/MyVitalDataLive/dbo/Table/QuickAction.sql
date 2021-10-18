/****** Object:  Table [dbo].[QuickAction]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[QuickAction](
	[Id] [smallint] IDENTITY(1,1) NOT NULL,
	[CustomerId] [int] NULL,
	[ActionName] [varchar](250) NOT NULL,
	[ActionDescription] [varchar](max) NULL,
	[ScheduledJobId] [int] NULL,
	[ParentQAId] [smallint] NULL,
	[IsActive] [bit] NULL,
	[CreatedDate] [datetime] NULL,
	[CreatedBy] [varchar](20) NULL,
	[UpdatedDate] [datetime] NULL,
	[UpdatedBy] [varchar](20) NULL,
	[QATId] [tinyint] NOT NULL,
	[TaskStatusToUpdate] [int] NULL,
	[ProductId] [int] NOT NULL,
 CONSTRAINT [PK_QuickAction] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

ALTER TABLE [dbo].[QuickAction] ADD  CONSTRAINT [DF_QuickAction_IsActive]  DEFAULT ((1)) FOR [IsActive]
ALTER TABLE [dbo].[QuickAction] ADD  CONSTRAINT [DF_QuickAction_CreatedDate]  DEFAULT (getutcdate()) FOR [CreatedDate]
ALTER TABLE [dbo].[QuickAction]  WITH NOCHECK ADD  CONSTRAINT [FK_QuickAction_HPCustomer] FOREIGN KEY([CustomerId])
REFERENCES [dbo].[HPCustomer] ([Cust_ID])
ALTER TABLE [dbo].[QuickAction] CHECK CONSTRAINT [FK_QuickAction_HPCustomer]
ALTER TABLE [dbo].[QuickAction]  WITH NOCHECK ADD  CONSTRAINT [FK_QuickAction_Products] FOREIGN KEY([ProductId])
REFERENCES [dbo].[Products] ([ID])
ALTER TABLE [dbo].[QuickAction] CHECK CONSTRAINT [FK_QuickAction_Products]
ALTER TABLE [dbo].[QuickAction]  WITH NOCHECK ADD  CONSTRAINT [FK_QuickAction_QuickActionType] FOREIGN KEY([QATId])
REFERENCES [dbo].[QuickActionType] ([Id])
ALTER TABLE [dbo].[QuickAction] CHECK CONSTRAINT [FK_QuickAction_QuickActionType]