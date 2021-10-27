/****** Object:  Table [dbo].[zzzANUI]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[zzzANUI](
	[ID] [uniqueidentifier] NULL,
	[UserID] [nvarchar](128) NOT NULL,
	[Department] [nvarchar](128) NULL,
	[Groups] [nvarchar](max) NULL,
	[Supervisor] [nvarchar](128) NULL,
	[AgentID] [nvarchar](max) NULL,
	[Signature] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]