/****** Object:  Table [Rules].[MemberDiagnosedDetl]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [Rules].[MemberDiagnosedDetl](
	[ICENUMBER] [varchar](30) NULL,
	[MemberID] [varchar](30) NULL,
	[Cust_ID] [int] NULL,
	[DIA_1stDiagDate] [datetime] NULL,
	[HTN_1stDiagDate] [datetime] NULL,
	[ASM_1stDiagDate] [datetime] NULL,
	[BH_1stDiagDate] [datetime] NULL,
	[CreateDate] [datetime] NULL
) ON [PRIMARY]

SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [IX_NCI_MemberDiagDetl_1] ON [Rules].[MemberDiagnosedDetl]
(
	[Cust_ID] ASC,
	[ICENUMBER] ASC,
	[MemberID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
ALTER TABLE [Rules].[MemberDiagnosedDetl] ADD  DEFAULT (getdate()) FOR [CreateDate]