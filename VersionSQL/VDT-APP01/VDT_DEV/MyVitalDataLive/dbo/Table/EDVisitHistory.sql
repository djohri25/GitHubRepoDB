/****** Object:  Table [dbo].[EDVisitHistory]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[EDVisitHistory](
	[ID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[ICENUMBER] [varchar](15) NULL,
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
	[BatchID] [bigint] NULL,
	[CustID] [int] NULL,
 CONSTRAINT [PK_EDVisitHistory] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [_dta_index_EDVisitHistory_18_132911545__K2_K3_K18_K1] ON [dbo].[EDVisitHistory]
(
	[ICENUMBER] ASC,
	[VisitDate] ASC,
	[FacilityNPI] ASC,
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [IX_EDVisitHistory] ON [dbo].[EDVisitHistory]
(
	[ICENUMBER] ASC,
	[VisitDate] ASC,
	[FacilityName] ASC
)
INCLUDE([VisitType]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [IX_EDVisitHistory_VisitType_VisitDate] ON [dbo].[EDVisitHistory]
(
	[VisitType] ASC,
	[VisitDate] ASC
)
INCLUDE([ICENUMBER],[IsHospitalAdmit],[Source]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
CREATE NONCLUSTERED INDEX [IX_NCI_EDVisitHist_Date_ICE_Chief] ON [dbo].[EDVisitHistory]
(
	[VisitDate] ASC
)
INCLUDE([ICENUMBER],[ChiefComplaint],[VisitType]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [IX_NCI_EDVisitHistory_5] ON [dbo].[EDVisitHistory]
(
	[FacilityName] ASC,
	[ID] ASC,
	[ICENUMBER] ASC,
	[FacilityNPI] ASC
)
INCLUDE([VisitDate]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [IX_NCI_EDVisitHistory_Visittype] ON [dbo].[EDVisitHistory]
(
	[VisitType] ASC
)
INCLUDE([ICENUMBER],[VisitDate],[ClaimID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [IX_VisitType_ICENUMBER_VisitDate] ON [dbo].[EDVisitHistory]
(
	[VisitType] ASC,
	[ICENUMBER] ASC,
	[VisitDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
ALTER TABLE [dbo].[EDVisitHistory] ADD  CONSTRAINT [DF_EDVisitHistory_Created]  DEFAULT (getutcdate()) FOR [Created]
ALTER TABLE [dbo].[EDVisitHistory] ADD  CONSTRAINT [DF_EDVisitHistory_CancelNotification]  DEFAULT ((0)) FOR [CancelNotification]
ALTER TABLE [dbo].[EDVisitHistory]  WITH NOCHECK ADD  CONSTRAINT [FK_EDVisitHistory_MainPersonalDetails] FOREIGN KEY([ICENUMBER])
REFERENCES [dbo].[MainPersonalDetails] ([ICENUMBER])
ON UPDATE CASCADE
ON DELETE CASCADE
ALTER TABLE [dbo].[EDVisitHistory] NOCHECK CONSTRAINT [FK_EDVisitHistory_MainPersonalDetails]