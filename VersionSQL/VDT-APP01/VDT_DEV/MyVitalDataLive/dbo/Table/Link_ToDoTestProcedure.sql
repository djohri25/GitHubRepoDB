/****** Object:  Table [dbo].[Link_ToDoTestProcedure]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Link_ToDoTestProcedure](
	[TestLookupID] [int] NOT NULL,
	[ProcedureCode] [varchar](50) NOT NULL,
	[ProcedureCodingSystem] [varchar](50) NOT NULL,
	[DoneByPCP] [bit] NULL,
	[Note] [varchar](1000) NULL,
	[Category] [varchar](50) NOT NULL,
 CONSTRAINT [PK_Link_ToDoTestProcedure] PRIMARY KEY CLUSTERED 
(
	[TestLookupID] ASC,
	[ProcedureCode] ASC,
	[ProcedureCodingSystem] ASC,
	[Category] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[Link_ToDoTestProcedure] ADD  CONSTRAINT [DF__Link_ToDo__DoneB__10822311]  DEFAULT ((0)) FOR [DoneByPCP]