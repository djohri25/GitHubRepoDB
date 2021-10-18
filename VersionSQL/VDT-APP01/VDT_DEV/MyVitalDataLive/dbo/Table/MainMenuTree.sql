/****** Object:  Table [dbo].[MainMenuTree]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[MainMenuTree](
	[Id] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[IdSort] [int] NOT NULL,
	[IdParent] [int] NOT NULL,
	[MenuName] [varchar](30) NOT NULL,
	[MenuNameSpanish] [varchar](50) NULL,
	[MenuLink] [varchar](100) NULL,
	[ItemId] [int] NULL,
	[IsContentDynamic] [bit] NULL,
 CONSTRAINT [PK_MainMenuTree] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_MainSort] ON [dbo].[MainMenuTree]
(
	[IdSort] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
CREATE NONCLUSTERED INDEX [IX_Parent] ON [dbo].[MainMenuTree]
(
	[IdParent] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
ALTER TABLE [dbo].[MainMenuTree] ADD  CONSTRAINT [DF_MainMenuTree_IdSort]  DEFAULT ((0)) FOR [IdSort]
ALTER TABLE [dbo].[MainMenuTree] ADD  CONSTRAINT [DF_MainMenuTree_IdParent]  DEFAULT ((0)) FOR [IdParent]
ALTER TABLE [dbo].[MainMenuTree] ADD  CONSTRAINT [DF_MainMenuTree_MenuLink]  DEFAULT ('') FOR [MenuLink]
ALTER TABLE [dbo].[MainMenuTree] ADD  CONSTRAINT [DF_MainMenuTree_IsContentDynamic]  DEFAULT ((0)) FOR [IsContentDynamic]