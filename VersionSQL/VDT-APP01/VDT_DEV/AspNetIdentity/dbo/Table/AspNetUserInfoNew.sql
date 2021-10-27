/****** Object:  Table [dbo].[AspNetUserInfoNew]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[AspNetUserInfoNew](
	[Id] [uniqueidentifier] NULL,
	[UserId] [nvarchar](128) NOT NULL,
	[Department] [nvarchar](128) NULL,
	[Groups] [nvarchar](max) NULL,
	[Supervisor] [nvarchar](128) NULL,
	[AgentId] [nvarchar](max) NULL,
	[Signature] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]