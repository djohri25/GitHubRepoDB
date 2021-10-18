/****** Object:  Table [dbo].[MessageLink]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[MessageLink](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[MessageTypeId] [int] NOT NULL,
	[MessageEntityId] [bigint] NOT NULL,
	[Title] [nvarchar](250) NULL,
	[Url] [nvarchar](max) NULL,
	[CreatedBy] [varchar](250) NULL,
	[CreatedDate] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

ALTER TABLE [dbo].[MessageLink] ADD  CONSTRAINT [DF_MessageLink_CreatedDate]  DEFAULT (getutcdate()) FOR [CreatedDate]