/****** Object:  Table [dbo].[AspNetUserInfo]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[AspNetUserInfo](
	[Id] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
	[UserId] [nvarchar](128) NOT NULL,
	[Department] [nvarchar](128) NULL,
	[Groups] [nvarchar](max) NULL,
	[Supervisor] [nvarchar](128) NULL,
	[AgentId] [nvarchar](max) NULL,
	[Signature] [nvarchar](max) NULL,
 CONSTRAINT [PK_AspNetUserInfo] PRIMARY KEY CLUSTERED 
(
	[Id] ASC,
	[UserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 85) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [IX_AspNetUserInfo_UserId] ON [dbo].[AspNetUserInfo]
(
	[UserId] ASC
)
INCLUDE([Groups],[Id]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 85) ON [PRIMARY]
ALTER TABLE [dbo].[AspNetUserInfo] ADD  DEFAULT (newid()) FOR [Id]
ALTER TABLE [dbo].[AspNetUserInfo]  WITH CHECK ADD  CONSTRAINT [FK_AspNetUserInfo_AspNetUsers] FOREIGN KEY([UserId])
REFERENCES [dbo].[AspNetUsers] ([Id])
ALTER TABLE [dbo].[AspNetUserInfo] CHECK CONSTRAINT [FK_AspNetUserInfo_AspNetUsers]