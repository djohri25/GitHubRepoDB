/****** Object:  Table [dbo].[ExportNewAlertsLog]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[ExportNewAlertsLog](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ExportDate] [datetime] NULL,
	[Filename] [varchar](50) NULL,
	[RecordCount] [int] NULL,
	[Note] [varchar](max) NULL,
	[Success] [bit] NULL,
 CONSTRAINT [PK_NewAlertsExportLog] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

ALTER TABLE [dbo].[ExportNewAlertsLog] ADD  CONSTRAINT [DF_NewAlertsExportLog_ExportDate]  DEFAULT (getutcdate()) FOR [ExportDate]
ALTER TABLE [dbo].[ExportNewAlertsLog] ADD  CONSTRAINT [DF_NewAlertsExportLog_Success]  DEFAULT ((0)) FOR [Success]