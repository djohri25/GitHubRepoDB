/****** Object:  Table [dbo].[MainCondition_ToDoCleanup]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[MainCondition_ToDoCleanup](
	[MVDID] [varchar](20) NOT NULL,
	[IsProcessed] [bit] NULL,
 CONSTRAINT [PK_MainCondition_ToDoCleanup] PRIMARY KEY CLUSTERED 
(
	[MVDID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[MainCondition_ToDoCleanup] ADD  CONSTRAINT [DF_MainCondition_ToDoCleanup_IsProcessed]  DEFAULT ((0)) FOR [IsProcessed]