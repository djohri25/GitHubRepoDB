/****** Object:  Table [dbo].[Link_UserGroupUsers]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Link_UserGroupUsers](
	[ID] [int] NOT NULL,
	[GroupID] [int] NOT NULL,
	[UserID] [nvarchar](128) NOT NULL
) ON [PRIMARY]