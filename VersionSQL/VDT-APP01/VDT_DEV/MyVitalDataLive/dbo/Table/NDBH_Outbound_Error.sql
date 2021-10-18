/****** Object:  Table [dbo].[NDBH_Outbound_Error]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[NDBH_Outbound_Error](
	[Flat File Source Error Output Column] [nvarchar](max) NULL,
	[ErrorCode] [int] NULL,
	[ErrorColumn] [int] NULL,
	[ID] [int] IDENTITY(1,1) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]