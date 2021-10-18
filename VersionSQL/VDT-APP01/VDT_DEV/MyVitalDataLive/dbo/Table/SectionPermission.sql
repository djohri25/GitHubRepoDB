/****** Object:  Table [dbo].[SectionPermission]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[SectionPermission](
	[ICENUMBER] [varchar](15) NOT NULL,
	[SectionID] [int] NOT NULL,
	[IsPermitted] [bit] NULL,
	[CreationDate] [datetime] NULL,
	[ModifyDate] [datetime] NULL,
 CONSTRAINT [PK_SectionPermission] PRIMARY KEY CLUSTERED 
(
	[ICENUMBER] ASC,
	[SectionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[SectionPermission] ADD  CONSTRAINT [DF_SectionPermission_IsPermitted]  DEFAULT ((0)) FOR [IsPermitted]
ALTER TABLE [dbo].[SectionPermission]  WITH CHECK ADD  CONSTRAINT [FK_SectionPermission_MainICENUMBERGroups] FOREIGN KEY([ICENUMBER])
REFERENCES [dbo].[MainICENUMBERGroups] ([ICENUMBER])
ON UPDATE CASCADE
ON DELETE CASCADE
ALTER TABLE [dbo].[SectionPermission] CHECK CONSTRAINT [FK_SectionPermission_MainICENUMBERGroups]
ALTER TABLE [dbo].[SectionPermission]  WITH CHECK ADD  CONSTRAINT [FK_SectionPermission_MainMenuTree] FOREIGN KEY([SectionID])
REFERENCES [dbo].[MainMenuTree] ([Id])
ON UPDATE CASCADE
ON DELETE CASCADE
ALTER TABLE [dbo].[SectionPermission] CHECK CONSTRAINT [FK_SectionPermission_MainMenuTree]