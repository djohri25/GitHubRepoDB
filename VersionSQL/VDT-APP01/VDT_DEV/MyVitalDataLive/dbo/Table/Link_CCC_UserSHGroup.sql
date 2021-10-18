/****** Object:  Table [dbo].[Link_CCC_UserSHGroup]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Link_CCC_UserSHGroup](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Userid] [uniqueidentifier] NOT NULL,
	[UserName] [varchar](512) NULL,
	[SHGroupID] [int] NOT NULL,
	[Active] [bit] NULL,
	[ManagerID] [uniqueidentifier] NULL,
	[ManagerName] [varchar](512) NULL,
	[Created] [datetime] NULL,
	[Updated] [datetime] NULL
) ON [PRIMARY]

ALTER TABLE [dbo].[Link_CCC_UserSHGroup] ADD  DEFAULT (getutcdate()) FOR [Created]