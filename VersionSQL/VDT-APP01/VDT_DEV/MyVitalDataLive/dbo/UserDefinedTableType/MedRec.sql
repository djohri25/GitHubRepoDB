/****** Object:  UserDefinedTableType [dbo].[MedRec]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TYPE [dbo].[MedRec] AS TABLE(
	[ID] [int] NULL,
	[CustID] [int] NULL,
	[MVDID] [nvarchar](30) NULL,
	[ReconDateTime] [datetime] NULL,
	[NDC] [nvarchar](20) NULL,
	[RxStartDate] [datetime] NULL,
	[ReconStatus] [int] NULL,
	[CreatedBy] [nvarchar](250) NULL,
	[SessionID] [nvarchar](40) NULL
)