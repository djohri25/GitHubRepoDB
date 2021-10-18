/****** Object:  Table [dbo].[LookupRoleID]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[LookupRoleID](
	[RoleID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[RoleName] [varchar](50) NULL,
	[RoleNameSpanish] [nvarchar](100) NULL,
 CONSTRAINT [PK_LookupRoleID] PRIMARY KEY CLUSTERED 
(
	[RoleID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]