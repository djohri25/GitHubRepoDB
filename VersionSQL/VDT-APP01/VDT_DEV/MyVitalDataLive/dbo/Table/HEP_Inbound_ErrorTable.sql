/****** Object:  Table [dbo].[HEP_Inbound_ErrorTable]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[HEP_Inbound_ErrorTable](
	[Flat File Source Error Output Column] [nvarchar](max) NULL,
	[ErrorCode] [int] NULL,
	[ErrorColumn] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]