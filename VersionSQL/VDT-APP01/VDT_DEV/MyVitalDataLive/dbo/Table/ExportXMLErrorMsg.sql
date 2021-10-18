/****** Object:  Table [dbo].[ExportXMLErrorMsg]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[ExportXMLErrorMsg](
	[PrimaryKey] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[ErrorDate] [datetime] NOT NULL,
	[ErrorInfo] [nvarchar](2048) NULL,
 CONSTRAINT [PK_ExportXMLErrorMsg] PRIMARY KEY CLUSTERED 
(
	[PrimaryKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[ExportXMLErrorMsg] ADD  CONSTRAINT [DF_ErrorMsg_ErrorDate]  DEFAULT (getdate()) FOR [ErrorDate]