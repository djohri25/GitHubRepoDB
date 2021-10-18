/****** Object:  Table [dbo].[EDVisitHistory_History]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[EDVisitHistory_History](
	[ID] [int] NOT NULL,
	[ICENUMBER] [varchar](15) NULL,
	[VisitDate] [datetime2](3) NULL,
	[FacilityName] [nvarchar](50) NULL,
	[PhysicianFirstName] [nvarchar](50) NULL,
	[PhysicianLastName] [nvarchar](50) NULL,
	[PhysicianPhone] [nvarchar](50) NULL,
	[Source] [nvarchar](50) NULL,
	[SourceRecordID] [int] NULL,
	[Created] [datetime2](3) NOT NULL,
	[CancelNotification] [bit] NULL,
	[CancelNotifyReason] [varchar](100) NULL,
	[IsHospitalAdmit] [bit] NULL,
	[VisitType] [varchar](50) NULL,
	[SourceFormType] [varchar](50) NULL,
	[MatchName] [varchar](50) NULL,
	[MatchRecordID] [int] NULL,
	[FacilityNPI] [varchar](50) NULL,
	[POS] [varchar](50) NULL,
	[ChiefComplaint] [varchar](100) NULL
) ON [PRIMARY]