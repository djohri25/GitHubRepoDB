/****** Object:  Table [dbo].[ABCBS_MemberPacket]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[ABCBS_MemberPacket](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[MVDID] [nvarchar](255) NULL,
	[FormID] [nvarchar](100) NULL,
	[ProcedureName] [nvarchar](255) NULL,
	[CreatedDatetime] [datetime] NULL
) ON [PRIMARY]

SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [IX_ABCBS_MemberPacket_MVDID] ON [dbo].[ABCBS_MemberPacket]
(
	[MVDID] ASC,
	[FormID] ASC,
	[ProcedureName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]