/****** Object:  Table [dbo].[EDPatientStatus]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[EDPatientStatus](
	[ID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[FacilityID] [int] NULL,
	[MemberID] [varchar](15) NULL,
	[CustID] [int] NULL,
	[PatientFirstName] [varchar](32) NULL,
	[PatientLastName] [varchar](32) NULL,
	[Status] [varchar](16) NULL,
	[ModifiedBy] [varchar](50) NULL,
	[DateVisited] [datetime] NULL,
	[DateCreated] [datetime] NULL,
	[DateModified] [datetime] NULL,
	[PatientName] [varchar](64) NULL,
 CONSTRAINT [PK_EDPatientStatus] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[EDPatientStatus] ADD  CONSTRAINT [DF_EDPatientStatus_DateCreated]  DEFAULT (getutcdate()) FOR [DateCreated]
ALTER TABLE [dbo].[EDPatientStatus] ADD  CONSTRAINT [DF_EDPatientStatus_DateModified]  DEFAULT (getutcdate()) FOR [DateModified]