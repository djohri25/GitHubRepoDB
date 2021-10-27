/****** Object:  Table [dbo].[AspNetCareQueueGroupsUsers]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[AspNetCareQueueGroupsUsers](
	[UserId] [nvarchar](128) NOT NULL,
	[CareQueueGroupId] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
 CONSTRAINT [PK_AspNetCareQueueGroupsUsers] PRIMARY KEY CLUSTERED 
(
	[UserId] ASC,
	[CareQueueGroupId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[AspNetCareQueueGroupsUsers] ADD  CONSTRAINT [DF_AspNetCareQueueGroupsUsers_CareQueueGroupId]  DEFAULT (newid()) FOR [CareQueueGroupId]
ALTER TABLE [dbo].[AspNetCareQueueGroupsUsers]  WITH CHECK ADD  CONSTRAINT [FK_AspNetCareQueueGroupsUsers_AspNetCareQueueGroups] FOREIGN KEY([CareQueueGroupId])
REFERENCES [dbo].[AspNetCareQueueGroups] ([Id])
ALTER TABLE [dbo].[AspNetCareQueueGroupsUsers] CHECK CONSTRAINT [FK_AspNetCareQueueGroupsUsers_AspNetCareQueueGroups]
ALTER TABLE [dbo].[AspNetCareQueueGroupsUsers]  WITH CHECK ADD  CONSTRAINT [FK_AspNetCareQueueGroupsUsers_AspNetUsers] FOREIGN KEY([UserId])
REFERENCES [dbo].[AspNetUsers_20210201] ([Id])
ALTER TABLE [dbo].[AspNetCareQueueGroupsUsers] CHECK CONSTRAINT [FK_AspNetCareQueueGroupsUsers_AspNetUsers]