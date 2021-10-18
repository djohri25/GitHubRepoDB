/****** Object:  Table [dbo].[Link_BroadcastMember]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Link_BroadcastMember](
	[BAId] [bigint] NOT NULL,
	[MVDID] [varchar](50) NOT NULL,
	[BroadcastStatusId] [int] NOT NULL,
	[IsMemberMobileRegistered] [bit] NULL
) ON [PRIMARY]