/****** Object:  Table [dbo].[Message]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Message](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[InternalThreadId] [bigint] NOT NULL,
	[ClientAppId] [int] NOT NULL,
	[ClientThreadId] [uniqueidentifier] NULL,
	[ClientMessageId] [uniqueidentifier] NULL,
	[TopicId] [int] NOT NULL,
	[ThreadPopulationId] [int] NOT NULL,
	[SenderTypeId] [int] NOT NULL,
	[PLMsgStatusId] [int] NOT NULL,
	[MessageDirectionId] [int] NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[CreatedBy] [varchar](250) NOT NULL,
	[UpdatedDate] [datetime] NULL,
	[UpdatedBy] [varchar](250) NULL,
	[IsActive] [bit] NOT NULL,
 CONSTRAINT [PK_Message] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]