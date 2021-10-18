/****** Object:  Table [dbo].[WebserviceLog]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[WebserviceLog](
	[RecordNumber] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[ServiceName] [varchar](50) NULL,
	[ClientIP] [varchar](25) NULL,
	[XMLFile] [varchar](max) NULL,
	[CreationDate] [datetime] NULL,
 CONSTRAINT [PK_WebserviceLog] PRIMARY KEY CLUSTERED 
(
	[RecordNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

ALTER TABLE [dbo].[WebserviceLog] ADD  CONSTRAINT [DF_WebserviceLog_CreationDate]  DEFAULT (getdate()) FOR [CreationDate]