/****** Object:  Table [dbo].[LookupICD9_deprecated]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[LookupICD9_deprecated](
	[Code] [nvarchar](10) NULL,
	[ChangeIndicator] [char](1) NULL,
	[Status] [char](1) NULL,
	[ShortDesc] [nvarchar](max) NULL,
	[MediumDesc] [nvarchar](max) NULL,
	[LongDesc] [nvarchar](max) NULL,
	[LongDescCont] [nvarchar](max) NULL,
	[Type] [nvarchar](50) NULL,
	[CodeNoPeriod] [nvarchar](10) NULL,
	[ICDNo] [nvarchar](10) NULL,
	[ParentCode] [nvarchar](10) NULL,
	[ParentCodeNoPeriod] [nvarchar](10) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

SET ANSI_PADDING ON

CREATE CLUSTERED INDEX [PK_LookupICD9] ON [dbo].[LookupICD9_deprecated]
(
	[Code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [IX_LookupICD9_CodeType] ON [dbo].[LookupICD9_deprecated]
(
	[Code] ASC,
	[Type] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [IX_LookupICD9_ICDNo] ON [dbo].[LookupICD9_deprecated]
(
	[ICDNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]