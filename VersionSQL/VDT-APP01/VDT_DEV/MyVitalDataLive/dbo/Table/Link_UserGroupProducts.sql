/****** Object:  Table [dbo].[Link_UserGroupProducts]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Link_UserGroupProducts](
	[ID] [int] NOT NULL,
	[GroupID] [int] NOT NULL,
	[ProductID] [int] NOT NULL
) ON [PRIMARY]