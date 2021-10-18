/****** Object:  Table [dbo].[Link_MDAccountGroup]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Link_MDAccountGroup](
	[MDAccountID] [int] NOT NULL,
	[MDGroupID] [int] NOT NULL,
 CONSTRAINT [PK_Link_MDAccountGroup] PRIMARY KEY CLUSTERED 
(
	[MDAccountID] ASC,
	[MDGroupID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]