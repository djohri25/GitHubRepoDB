/****** Object:  Table [dbo].[ForbiddenEmailDomains]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[ForbiddenEmailDomains](
	[ID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[Name] [varchar](50) NOT NULL,
 CONSTRAINT [PK_ForbiddenEmailDomains] PRIMARY KEY CLUSTERED 
(
	[Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]