/****** Object:  Table [dbo].[MemberDiagnosisSummary]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[MemberDiagnosisSummary](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[InsMemberID] [varchar](50) NULL,
	[CustID] [int] NULL,
	[MVDID] [varchar](50) NULL,
	[FirstName] [varchar](50) NULL,
	[LastName] [varchar](50) NULL,
	[StatusID] [int] NULL,
	[PhysVisitCount] [int] NULL,
	[PCPVisitCount] [int] NULL,
	[ERVisitCount] [int] NULL,
	[PhysVisitCountSinceContact] [int] NULL,
	[PCPVisitCountSinceContact] [int] NULL,
	[ERVisitCountSinceContact] [int] NULL,
	[LastContactDate] [datetime] NULL,
	[LastContactBy] [varchar](50) NULL,
	[LastContactByName] [varchar](100) NULL,
	[Created] [datetime] NULL,
	[ModifyDate] [datetime] NULL,
	[ModifiedBy] [varchar](50) NULL,
	[ModifiedByName] [varchar](100) NULL,
	[LastERVisit] [datetime] NULL,
 CONSTRAINT [PK_MemberDiagnosisSummary] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [IX_MemberDiagnosisSummary_MVDID] ON [dbo].[MemberDiagnosisSummary]
(
	[MVDID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
ALTER TABLE [dbo].[MemberDiagnosisSummary] ADD  CONSTRAINT [DF_MemberDiagnosisSummary_Created]  DEFAULT (getutcdate()) FOR [Created]
ALTER TABLE [dbo].[MemberDiagnosisSummary] ADD  CONSTRAINT [DF_MemberDiagnosisSummary_ModifyDate]  DEFAULT (getutcdate()) FOR [ModifyDate]