/****** Object:  Table [dbo].[LookupHCPCSAdditionalInfo]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[LookupHCPCSAdditionalInfo](
	[Code] [nvarchar](5) NOT NULL,
	[ShowOnReportDays] [smallint] NULL,
 CONSTRAINT [PK_HCPCSAdditionalInfo] PRIMARY KEY CLUSTERED 
(
	[Code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]