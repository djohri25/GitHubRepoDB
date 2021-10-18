/****** Object:  UserDefinedTableType [dbo].[MedRecExt]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TYPE [dbo].[MedRecExt] AS TABLE(
	[ID] [int] NULL,
	[CustID] [int] NULL,
	[MVDID] [nvarchar](30) NULL,
	[ReconDateTime] [datetime] NULL,
	[NDC] [nvarchar](20) NULL,
	[RxStartDate] [datetime] NULL,
	[ReconStatus] [int] NULL,
	[Quantity] [varchar](50) NULL,
	[DaysSupply] [varchar](50) NULL,
	[CreatedBy] [nvarchar](250) NULL,
	[SessionID] [nvarchar](40) NULL
)