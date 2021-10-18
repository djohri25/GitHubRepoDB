/****** Object:  Table [dbo].[LockedUsers]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[LockedUsers](
	[Username] [nvarchar](100) NOT NULL,
	[CompanyID] [int] NOT NULL,
	[Count] [tinyint] NOT NULL,
	[DateLastFailed] [datetime] NOT NULL,
 CONSTRAINT [PK_LockedUsers] PRIMARY KEY CLUSTERED 
(
	[Username] ASC,
	[CompanyID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[LockedUsers] ADD  CONSTRAINT [DF_LockedUsers_Count]  DEFAULT ((0)) FOR [Count]