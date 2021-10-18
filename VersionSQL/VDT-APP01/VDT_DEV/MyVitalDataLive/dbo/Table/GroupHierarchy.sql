/****** Object:  Table [dbo].[GroupHierarchy]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[GroupHierarchy](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[CustID] [bigint] NULL,
	[Name] [nvarchar](255) NULL,
	[ParentID] [bigint] NULL,
	[TopmostParentID] [bigint] NULL,
	[Level] [int] NULL
) ON [PRIMARY]

SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [IX_GroupHierarchy_Name] ON [dbo].[GroupHierarchy]
(
	[CustID] ASC,
	[Name] ASC,
	[Level] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
CREATE NONCLUSTERED INDEX [IX_GroupHierarchy_ParentID] ON [dbo].[GroupHierarchy]
(
	[CustID] ASC,
	[ParentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
CREATE NONCLUSTERED INDEX [IX_GroupHierarchy_TopmostParentID] ON [dbo].[GroupHierarchy]
(
	[CustID] ASC,
	[TopmostParentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]