/****** Object:  Table [dbo].[HPWorkflowRule]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[HPWorkflowRule](
	[Rule_ID] [smallint] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[Cust_ID] [int] NULL,
	[Name] [varchar](250) NULL,
	[Description] [nvarchar](500) NULL,
	[Body] [varchar](max) NULL,
	[Action_ID] [int] NULL,
	[Action_Days] [int] NULL,
	[Active] [bit] NULL,
	[CreatedDate] [datetime] NULL,
	[Query] [nvarchar](max) NULL,
	[AdminUseOnly] [bit] NOT NULL,
	[Group] [varchar](50) NULL,
 CONSTRAINT [PK_HPWorkflowRule] PRIMARY KEY CLUSTERED 
(
	[Rule_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

ALTER TABLE [dbo].[HPWorkflowRule] ADD  CONSTRAINT [DF_HPWorkflowRule_Active]  DEFAULT ((0)) FOR [Active]
ALTER TABLE [dbo].[HPWorkflowRule] ADD  CONSTRAINT [DF_HPWorkflowRule_CreatedDate]  DEFAULT (getdate()) FOR [CreatedDate]
ALTER TABLE [dbo].[HPWorkflowRule] ADD  CONSTRAINT [DF_HPWorkflowRule_AdminUseOnly]  DEFAULT ((0)) FOR [AdminUseOnly]
ALTER TABLE [dbo].[HPWorkflowRule]  WITH CHECK ADD  CONSTRAINT [FK_HPWorflowRule_HPCustomer] FOREIGN KEY([Cust_ID])
REFERENCES [dbo].[HPCustomer] ([Cust_ID])
ALTER TABLE [dbo].[HPWorkflowRule] CHECK CONSTRAINT [FK_HPWorflowRule_HPCustomer]