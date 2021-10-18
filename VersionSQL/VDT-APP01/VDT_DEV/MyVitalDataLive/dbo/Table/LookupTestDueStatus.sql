/****** Object:  Table [dbo].[LookupTestDueStatus]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[LookupTestDueStatus](
	[ID] [int] NOT NULL,
	[Name] [varchar](50) NULL,
	[IsComplete] [bit] NULL,
	[Active] [bit] NULL,
	[ParentID] [int] NULL,
 CONSTRAINT [PK_LookupTestDueStatus] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[LookupTestDueStatus] ADD  CONSTRAINT [DF_LookupTestDueStatus_IsComplete]  DEFAULT ((0)) FOR [IsComplete]