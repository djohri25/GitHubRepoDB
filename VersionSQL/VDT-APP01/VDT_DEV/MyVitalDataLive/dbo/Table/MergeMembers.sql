/****** Object:  Table [dbo].[MergeMembers]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[MergeMembers](
	[ID] [int] NOT NULL,
	[FirstName] [varchar](50) NULL,
	[MiddleName] [varchar](50) NULL,
	[LastName] [varchar](50) NULL,
	[GenderID] [int] NULL,
	[DOB] [smalldatetime] NULL,
	[SSN] [varchar](9) NULL,
	[ICENUMBER] [varchar](20) NULL,
	[IsProcessed] [bit] NOT NULL,
 CONSTRAINT [PK_MergeMembers] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]