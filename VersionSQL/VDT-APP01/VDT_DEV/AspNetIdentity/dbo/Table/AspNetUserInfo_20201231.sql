/****** Object:  Table [dbo].[AspNetUserInfo_20201231]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[AspNetUserInfo_20201231](
	[Id] [uniqueidentifier] NOT NULL,
	[UserId] [nvarchar](128) NOT NULL,
	[Department] [nvarchar](128) NULL,
	[Groups] [nvarchar](max) NULL,
	[Supervisor] [nvarchar](128) NULL,
	[AgentId] [nvarchar](max) NULL,
	[Signature] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]