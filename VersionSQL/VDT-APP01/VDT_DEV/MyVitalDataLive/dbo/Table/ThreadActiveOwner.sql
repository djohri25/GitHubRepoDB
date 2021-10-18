/****** Object:  Table [dbo].[ThreadActiveOwner]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[ThreadActiveOwner](
	[MVDID] [varchar](30) NOT NULL,
	[InternalThreadId] [bigint] NOT NULL,
	[ActiveOwner] [varchar](200) NOT NULL
) ON [PRIMARY]