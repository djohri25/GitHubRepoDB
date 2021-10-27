/****** Object:  Table [dbo].[AspNetUserInfo_20210201]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[AspNetUserInfo_20210201](
	[Id] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
	[UserId] [nvarchar](128) NOT NULL,
	[Department] [nvarchar](128) NULL,
	[Groups] [nvarchar](max) NULL,
	[Supervisor] [nvarchar](128) NULL,
	[AgentId] [nvarchar](max) NULL,
	[Signature] [nvarchar](max) NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC,
	[UserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

ALTER TABLE [dbo].[AspNetUserInfo_20210201] ADD  DEFAULT (newid()) FOR [Id]