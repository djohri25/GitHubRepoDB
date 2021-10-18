/****** Object:  Table [dbo].[MDUser_Member]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[MDUser_Member](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[DoctorID] [varchar](50) NULL,
	[DoctorUsername] [varchar](50) NULL,
	[HPName] [varchar](50) NULL,
	[CustID] [int] NULL,
	[MemberID] [varchar](50) NULL,
	[MVDID] [varchar](20) NULL,
	[MemberFirstName] [varchar](50) NULL,
	[MemberLastName] [varchar](50) NULL,
	[PCP_NPI] [varchar](50) NULL,
	[Created] [datetime] NULL,
	[PCP_TIN] [varchar](20) NULL,
	[TestID] [int] NULL,
	[IsTestDue] [char](1) NULL,
	[TestStatusID] [int] NULL,
	[StatusIDSaveDate] [datetime] NULL,
 CONSTRAINT [PK_MDUser_Member2] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [IX_MDUser_Member_MVDID] ON [dbo].[MDUser_Member]
(
	[MVDID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [IX_MDUser_Member2] ON [dbo].[MDUser_Member]
(
	[DoctorUsername] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
ALTER TABLE [dbo].[MDUser_Member] ADD  CONSTRAINT [DF_MDUser_Member2_Created]  DEFAULT (getutcdate()) FOR [Created]