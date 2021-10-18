/****** Object:  Table [dbo].[LookupICD9AdditionalInfo]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[LookupICD9AdditionalInfo](
	[CodeNoPeriod] [nvarchar](6) NOT NULL,
	[FollowupPriority] [tinyint] NULL,
	[ShowOnReportDays] [smallint] NULL,
 CONSTRAINT [PK_LookupICD9AdditionalInfo] PRIMARY KEY CLUSTERED 
(
	[CodeNoPeriod] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]