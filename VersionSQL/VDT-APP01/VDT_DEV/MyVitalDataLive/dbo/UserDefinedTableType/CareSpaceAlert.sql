/****** Object:  UserDefinedTableType [dbo].[CareSpaceAlert]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TYPE [dbo].[CareSpaceAlert] AS TABLE(
	[ID] [int] NULL,
	[AgentID] [nvarchar](50) NULL,
	[AlertDate] [datetime] NULL,
	[Facility] [nvarchar](50) NULL,
	[Customer] [nvarchar](50) NULL,
	[Text] [nvarchar](1000) NULL,
	[MemberID] [nvarchar](20) NULL,
	[StatusID] [int] NULL,
	[RecordAccessID] [int] NULL,
	[DateCreated] [datetime] NULL,
	[DateModified] [datetime] NULL,
	[ModifiedBy] [nvarchar](64) NULL,
	[TriggerType] [varchar](50) NULL,
	[TriggerID] [int] NULL,
	[RecipientType] [varchar](50) NULL,
	[RecipientCustID] [int] NULL,
	[DischargeDisposition] [varchar](100) NULL,
	[SourceName] [varchar](50) NULL,
	[ChiefComplaint] [varchar](100) NULL,
	[EMSNote] [varchar](1000) NULL,
	[MVDID] [varchar](30) NULL
)