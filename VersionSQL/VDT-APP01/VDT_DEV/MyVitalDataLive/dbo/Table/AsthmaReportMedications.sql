/****** Object:  Table [dbo].[AsthmaReportMedications]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[AsthmaReportMedications](
	[NDC] [varchar](50) NOT NULL,
	[Name] [varchar](200) NULL,
 CONSTRAINT [PK_AsthmaReportMedications] PRIMARY KEY CLUSTERED 
(
	[NDC] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]