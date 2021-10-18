/****** Object:  Table [dbo].[MemberDiagnosisSummaryByHosp]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[MemberDiagnosisSummaryByHosp](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[InsMemberID] [varchar](50) NULL,
	[CustID] [int] NULL,
	[HospitalID] [int] NULL,
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
 CONSTRAINT [PK_MemberDiagnosisSummaryByHospital] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[MemberDiagnosisSummaryByHosp] ADD  CONSTRAINT [DF_MemberDiagnosisSummaryByHospital_Created]  DEFAULT (getutcdate()) FOR [Created]
ALTER TABLE [dbo].[MemberDiagnosisSummaryByHosp] ADD  CONSTRAINT [DF_MemberDiagnosisSummaryByHospital_ModifyDate]  DEFAULT (getutcdate()) FOR [ModifyDate]