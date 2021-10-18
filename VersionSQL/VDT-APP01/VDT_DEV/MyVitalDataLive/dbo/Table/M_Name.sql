/****** Object:  Table [dbo].[M_Name]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[M_Name](
	[NameID] [int] NOT NULL,
	[FullName] [nvarchar](100) NOT NULL,
	[FirstName] [nvarchar](50) NULL,
	[LastName] [nvarchar](50) NULL,
	[NameCategoryID] [int] NOT NULL,
 CONSTRAINT [PK_Name] PRIMARY KEY CLUSTERED 
(
	[NameID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[M_Name]  WITH CHECK ADD  CONSTRAINT [FK_Name_NameCategory] FOREIGN KEY([NameCategoryID])
REFERENCES [dbo].[L_NameCategory] ([NameCategoryID])
ALTER TABLE [dbo].[M_Name] CHECK CONSTRAINT [FK_Name_NameCategory]