/****** Object:  Table [dbo].[HPAlertGroup]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[HPAlertGroup](
	[ID] [smallint] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[Cust_ID] [int] NULL,
	[Name] [nvarchar](50) NULL,
	[Description] [nvarchar](500) NULL,
	[Active] [bit] NULL,
	[Created] [datetime] NULL,
	[Modified] [datetime] NULL,
 CONSTRAINT [PK_HPAlertGroup] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[HPAlertGroup] ADD  CONSTRAINT [DF_HPAlertGroup_Active]  DEFAULT ((0)) FOR [Active]
ALTER TABLE [dbo].[HPAlertGroup] ADD  CONSTRAINT [DF_HPAlertGroup_Created]  DEFAULT (getutcdate()) FOR [Created]
ALTER TABLE [dbo].[HPAlertGroup]  WITH CHECK ADD  CONSTRAINT [FK_HPAlertGroup_HPCustomer] FOREIGN KEY([Cust_ID])
REFERENCES [dbo].[HPCustomer] ([Cust_ID])
ALTER TABLE [dbo].[HPAlertGroup] CHECK CONSTRAINT [FK_HPAlertGroup_HPCustomer]