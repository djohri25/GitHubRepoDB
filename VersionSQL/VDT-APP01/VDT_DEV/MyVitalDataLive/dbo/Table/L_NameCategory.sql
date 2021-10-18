/****** Object:  Table [dbo].[L_NameCategory]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[L_NameCategory](
	[NameCategoryID] [int] NOT NULL,
	[CategoryName] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_NameCategory] PRIMARY KEY CLUSTERED 
(
	[NameCategoryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]