/****** Object:  Table [dbo].[Lookup_ICD_TopHierarchy]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Lookup_ICD_TopHierarchy](
	[ParentCode] [varchar](10) NULL,
	[ParentLongDesc] [varchar](1000) NULL,
	[ChildCode] [varchar](10) NULL,
	[ChildCodeNoPeriod] [varchar](10) NULL,
	[ChildLongDesc] [varchar](max) NULL,
	[Created] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [IX_NCI_Lookup_ICD_TopHierarchy_Childcode] ON [dbo].[Lookup_ICD_TopHierarchy]
(
	[ChildCode] ASC
)
INCLUDE([ParentLongDesc]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [IX_NCI_Lookup_ICD_TopHierarchy_Code] ON [dbo].[Lookup_ICD_TopHierarchy]
(
	[ParentLongDesc] ASC,
	[ChildCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
ALTER TABLE [dbo].[Lookup_ICD_TopHierarchy] ADD  CONSTRAINT [DF_Lookup_ICD_TopHierarchy_Created]  DEFAULT (getdate()) FOR [Created]