/****** Object:  Table [dbo].[NurseLicensure]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[NurseLicensure](
	[State] [nvarchar](2) NULL,
	[UserName] [nvarchar](50) NULL,
	[LicenseType] [nvarchar](50) NULL,
	[LicenseStart] [nvarchar](50) NULL,
	[LicenseEnd] [nvarchar](50) NULL,
	[StateIssued] [nvarchar](50) NULL,
	[CompactState] [nvarchar](50) NULL,
	[Status] [nvarchar](50) NULL,
	[IsActive] [nvarchar](50) NULL,
	[County] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [IX_STATUS] ON [dbo].[NurseLicensure]
(
	[Status] ASC
)
INCLUDE([State],[UserName],[LicenseType],[County]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [IX_UserName] ON [dbo].[NurseLicensure]
(
	[UserName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]