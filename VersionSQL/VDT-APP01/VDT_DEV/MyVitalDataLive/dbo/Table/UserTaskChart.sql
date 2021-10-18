/****** Object:  Table [dbo].[UserTaskChart]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[UserTaskChart](
	[ID] [int] NOT NULL,
	[FirstName] [varchar](50) NULL,
	[LastName] [varchar](50) NULL,
	[UserName] [varchar](100) NULL,
	[DeptID] [int] NULL,
	[ReportToID] [int] NULL,
	[IsSupervisorFLG] [bit] NULL
) ON [PRIMARY]