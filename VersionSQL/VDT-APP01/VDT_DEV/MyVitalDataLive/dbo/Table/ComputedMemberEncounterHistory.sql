/****** Object:  Table [dbo].[ComputedMemberEncounterHistory]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[ComputedMemberEncounterHistory](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[MVDID] [varchar](50) NULL,
	[VisitDate] [datetime] NULL,
	[FacilityName] [nvarchar](50) NULL,
	[PhysicianFirstName] [nvarchar](50) NULL,
	[PhysicianLastName] [nvarchar](50) NULL,
	[PhysicianPhone] [nvarchar](50) NULL,
	[Source] [nvarchar](50) NULL,
	[SourceRecordID] [int] NULL,
	[Created] [datetime] NOT NULL,
	[CancelNotification] [bit] NULL,
	[CancelNotifyReason] [varchar](100) NULL,
	[IsHospitalAdmit] [bit] NULL,
	[VisitType] [varchar](50) NULL,
	[SourceFormType] [varchar](50) NULL,
	[MatchName] [varchar](50) NULL,
	[MatchRecordID] [int] NULL,
	[FacilityNPI] [varchar](50) NULL,
	[POS] [varchar](50) NULL,
	[ChiefComplaint] [varchar](100) NULL,
	[ClaimID] [int] NULL,
	[ClaimNumber] [varchar](20) NULL,
	[TotalPaidAmount] [decimal](18, 2) NULL,
	[BatchID] [bigint] NOT NULL,
	[CustID] [int] NOT NULL,
 CONSTRAINT [PK_ComputedMemberEncounterHistory] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [IX_ComputedMemberEncounterHistory_ClaimNumber] ON [dbo].[ComputedMemberEncounterHistory]
(
	[ClaimNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [IX_ComputedMemberEncounterHistory_MVDID] ON [dbo].[ComputedMemberEncounterHistory]
(
	[MVDID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]