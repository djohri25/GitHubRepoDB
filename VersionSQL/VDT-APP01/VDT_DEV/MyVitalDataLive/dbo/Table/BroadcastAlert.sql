/****** Object:  Table [dbo].[BroadcastAlert]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[BroadcastAlert](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[ClientAppId] [int] NOT NULL,
	[ClientBroadcastId] [uniqueidentifier] NULL,
	[TopicId] [int] NOT NULL,
	[ThreadPopulationId] [int] NOT NULL,
	[ReferralReason] [varchar](250) NULL,
	[Subject] [varchar](250) NOT NULL,
	[From] [varchar](150) NOT NULL,
	[MessageDirectionId] [int] NOT NULL,
	[BroadcastStatusId] [int] NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[CreatedBy] [varchar](100) NOT NULL,
	[IsActive] [bit] NULL,
 CONSTRAINT [PK_BroadcastAlert] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]