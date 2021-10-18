/****** Object:  Table [dbo].[MergeMembersOnIDLog]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[MergeMembersOnIDLog](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[TempID] [varchar](100) NULL,
	[MemberID] [varchar](100) NULL,
	[TempMVDIDID] [varchar](100) NULL,
	[PermMVDIDID] [varchar](100) NULL,
	[IsMatched] [bit] NULL,
	[IsMerged] [bit] NULL,
	[CreatedDT] [datetime] NULL,
	[CreatedBy] [varchar](255) NULL
) ON [PRIMARY]