/****** Object:  Table [dbo].[Home_Visit_Form]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Home_Visit_Form](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[MVDID] [varchar](20) NOT NULL,
	[FormDate] [datetime] NOT NULL,
	[FormAuthor] [varchar](20) NOT NULL,
	[CaseID] [varchar](100) NULL,
	[q1] [varchar](max) NULL,
	[q1a] [varchar](max) NULL,
	[q1b] [varchar](max) NULL,
	[q1c] [varchar](max) NULL,
	[q1d] [varchar](max) NULL,
	[q1e] [varchar](max) NULL,
	[AddInfo] [varchar](8000) NULL,
	[formVersion] [varchar](10) NULL,
	[q1b1] [varchar](max) NULL,
	[q1c1] [varchar](max) NULL,
	[q1d1] [varchar](max) NULL,
	[q1e1] [varchar](max) NULL,
	[LastModifiedDate] [datetime] NULL,
	[IsLocked] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_Home_Visit_Form] ON [dbo].[Home_Visit_Form]
(
	[ID] ASC
)
INCLUDE([FormDate],[IsLocked]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]