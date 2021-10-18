/****** Object:  Table [dbo].[AsthmaReportProgressLog]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[AsthmaReportProgressLog](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[log] [varchar](max) NULL,
	[date] [datetime] NULL,
 CONSTRAINT [PK_AsthmaReportProgressLog] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

ALTER TABLE [dbo].[AsthmaReportProgressLog] ADD  CONSTRAINT [DF_AsthmaReportProgressLog_date]  DEFAULT (getdate()) FOR [date]