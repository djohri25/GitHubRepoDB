/****** Object:  Table [dbo].[UTSW]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[UTSW](
	[Last Name] [nvarchar](255) NULL,
	[Suffix] [nvarchar](255) NULL,
	[Degree] [nvarchar](255) NULL,
	[First Name] [nvarchar](255) NULL,
	[Middle Name] [nvarchar](255) NULL,
	[NPI] [nvarchar](255) NOT NULL,
	[Specialty] [nvarchar](255) NULL
) ON [PRIMARY]

SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [IX_UTSW_NPI] ON [dbo].[UTSW]
(
	[Last Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]