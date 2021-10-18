/****** Object:  Table [dbo].[MDMemberVisit]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[MDMemberVisit](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[MVDID] [varchar](20) NOT NULL,
	[InsMemberID] [varchar](20) NULL,
	[HPCustName] [varchar](50) NULL,
	[CustID] [int] NULL,
	[AlertDate] [datetime] NULL,
	[Facility] [varchar](50) NULL,
	[FacilityNPI] [varchar](50) NULL,
	[SourceRecordID] [int] NULL,
	[VisitType] [varchar](50) NULL,
	[ChiefComplaint] [varchar](100) NULL,
	[EMSNote] [varchar](1000) NULL,
	[Created] [datetime] NULL,
 CONSTRAINT [PK_MDMemberVisit] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [IX_MDMemberVisit] ON [dbo].[MDMemberVisit]
(
	[MVDID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [IX_MDMemberVisit_1] ON [dbo].[MDMemberVisit]
(
	[AlertDate] ASC,
	[MVDID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
ALTER TABLE [dbo].[MDMemberVisit] ADD  CONSTRAINT [DF_MDMemberVisit_Created]  DEFAULT (getutcdate()) FOR [Created]