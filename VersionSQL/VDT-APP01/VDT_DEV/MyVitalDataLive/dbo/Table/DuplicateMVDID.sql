/****** Object:  Table [dbo].[DuplicateMVDID]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[DuplicateMVDID](
	[MVDID] [varchar](30) NOT NULL,
	[MemberID] [varchar](15) NULL,
	[cnt] [int] NULL
) ON [PRIMARY]