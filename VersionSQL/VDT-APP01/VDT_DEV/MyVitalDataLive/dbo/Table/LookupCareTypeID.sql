/****** Object:  Table [dbo].[LookupCareTypeID]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[LookupCareTypeID](
	[CareTypeID] [int] NOT NULL,
	[CareTypeName] [varchar](50) NULL,
	[CareTypeNameSpanish] [nvarchar](100) NULL,
 CONSTRAINT [PK_LookupCareTypeID] PRIMARY KEY CLUSTERED 
(
	[CareTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [IX_LookupCareTypeID] ON [dbo].[LookupCareTypeID]
(
	[CareTypeName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]