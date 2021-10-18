/****** Object:  Table [dbo].[HCCMemberRisk]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[HCCMemberRisk](
	[RecordNumber] [int] IDENTITY(1,1) NOT NULL,
	[MVDID] [varchar](20) NOT NULL,
	[MonthID] [varchar](6) NULL,
	[CCCode] [varchar](10) NULL,
	[Createdate] [datetime] NULL,
	[Updatedate] [datetime] NULL,
 CONSTRAINT [PK_HCCMemberRisk] PRIMARY KEY CLUSTERED 
(
	[RecordNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_HCCMemberRisk_Updatedate] ON [dbo].[HCCMemberRisk]
(
	[Updatedate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
ALTER TABLE [dbo].[HCCMemberRisk] ADD  CONSTRAINT [DF_HCCMemberRisk_Createdate]  DEFAULT (getutcdate()) FOR [Createdate]