/****** Object:  Table [dbo].[LookupCPTAdditionalInfo]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[LookupCPTAdditionalInfo](
	[Code] [nvarchar](10) NOT NULL,
	[ShowOnReportDays] [smallint] NULL,
 CONSTRAINT [PK_CPTAdditionalInfo] PRIMARY KEY CLUSTERED 
(
	[Code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[LookupCPTAdditionalInfo]  WITH CHECK ADD  CONSTRAINT [FK_LookupCPTAdditionalInfo_LookupCPT] FOREIGN KEY([Code])
REFERENCES [dbo].[LookupCPT] ([Code])
ALTER TABLE [dbo].[LookupCPTAdditionalInfo] CHECK CONSTRAINT [FK_LookupCPTAdditionalInfo_LookupCPT]