/****** Object:  UserDefinedTableType [dbo].[EngagementMessage]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TYPE [dbo].[EngagementMessage] AS TABLE(
	[MVDID] [varchar](50) NULL,
	[TIN] [varchar](50) NULL,
	[MessageSubject] [varchar](50) NULL,
	[MessageText] [varchar](max) NULL,
	[MessageSender] [varchar](50) NULL,
	[MessageDate] [datetime] NULL,
	[CreatedDate] [datetime] NULL,
	[ExpirationDate] [datetime] NULL,
	[DeliveredToPCP] [bit] NULL,
	[DeliveredToMobile] [bit] NULL
)