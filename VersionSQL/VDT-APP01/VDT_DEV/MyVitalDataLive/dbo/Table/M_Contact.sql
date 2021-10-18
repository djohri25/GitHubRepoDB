/****** Object:  Table [dbo].[M_Contact]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[M_Contact](
	[ContactID] [int] NOT NULL,
	[NameID] [int] NOT NULL,
	[PlaceID] [int] NOT NULL,
 CONSTRAINT [PK_Contact] PRIMARY KEY CLUSTERED 
(
	[ContactID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[M_Contact]  WITH CHECK ADD  CONSTRAINT [FK_Contact_Name] FOREIGN KEY([NameID])
REFERENCES [dbo].[M_Name] ([NameID])
ALTER TABLE [dbo].[M_Contact] CHECK CONSTRAINT [FK_Contact_Name]
ALTER TABLE [dbo].[M_Contact]  WITH CHECK ADD  CONSTRAINT [FK_Contact_Place] FOREIGN KEY([PlaceID])
REFERENCES [dbo].[M_Place] ([PlaceID])
ALTER TABLE [dbo].[M_Contact] CHECK CONSTRAINT [FK_Contact_Place]