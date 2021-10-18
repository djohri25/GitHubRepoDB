/****** Object:  Table [dbo].[TRC-1]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[TRC-1](
	[RowNumber] [int] IDENTITY(0,1) NOT NULL,
	[EventClass] [int] NULL,
	[TextData] [ntext] NULL,
	[ApplicationName] [nvarchar](128) NULL,
	[NTUserName] [nvarchar](128) NULL,
	[LoginName] [nvarchar](128) NULL,
	[CPU] [int] NULL,
	[Reads] [bigint] NULL,
	[Writes] [bigint] NULL,
	[Duration] [bigint] NULL,
	[ClientProcessID] [int] NULL,
	[SPID] [int] NULL,
	[StartTime] [datetime] NULL,
	[EndTime] [datetime] NULL,
	[BinaryData] [image] NULL,
PRIMARY KEY CLUSTERED 
(
	[RowNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]