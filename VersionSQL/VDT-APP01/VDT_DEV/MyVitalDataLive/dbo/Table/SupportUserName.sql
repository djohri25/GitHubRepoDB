/****** Object:  Table [dbo].[SupportUserName]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[SupportUserName](
	[UserName] [varchar](50) NOT NULL,
	[Password] [varchar](50) NULL,
	[Active] [int] NULL,
	[SecQuestion] [int] NULL,
	[SecAnswer] [varchar](50) NULL,
	[CreationDate] [datetime] NULL,
	[ModifyDate] [datetime] NULL,
 CONSTRAINT [PK_SupportUserName] PRIMARY KEY CLUSTERED 
(
	[UserName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[SupportUserName] ADD  CONSTRAINT [DF_SupportUserName_CreationDate]  DEFAULT (getutcdate()) FOR [CreationDate]