/****** Object:  Table [dbo].[ABCBS_EnterpriseLayerSyncHistory]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[ABCBS_EnterpriseLayerSyncHistory](
	[JobStartDateTime] [datetime] NULL,
	[QueryDateTime] [datetime] NULL,
	[DBType] [varchar](255) NULL,
	[TableName] [varchar](255) NULL,
	[AppCount] [bigint] NULL,
	[ELCount] [bigint] NULL
) ON [PRIMARY]

SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [IX_ABCBS_EnterpriseLayerSyncHistory] ON [dbo].[ABCBS_EnterpriseLayerSyncHistory]
(
	[JobStartDateTime] ASC,
	[DBType] ASC,
	[TableName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]