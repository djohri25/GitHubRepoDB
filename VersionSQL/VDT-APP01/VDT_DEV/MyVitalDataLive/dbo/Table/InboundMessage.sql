/****** Object:  Table [dbo].[InboundMessage]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[InboundMessage](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[Message] [varchar](max) NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
 CONSTRAINT [PK_InboundMessage] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]