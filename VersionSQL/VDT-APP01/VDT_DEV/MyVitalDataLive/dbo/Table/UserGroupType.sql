/****** Object:  Table [dbo].[UserGroupType]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[UserGroupType](
	[ID] [int] NOT NULL,
	[Name] [varchar](100) NOT NULL,
	[FriendlyName] [varchar](100) NOT NULL,
	[Description] [varchar](250) NULL
) ON [PRIMARY]