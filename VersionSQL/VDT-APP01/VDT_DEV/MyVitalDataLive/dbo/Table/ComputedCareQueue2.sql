/****** Object:  Table [dbo].[ComputedCareQueue2]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[ComputedCareQueue2](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[CaseId] [varchar](1000) NULL,
	[MVDID] [varchar](200) NULL,
	[OpenCaseCount] [int] NULL,
	[OpenTaskCount] [int] NULL,
	[CaseProgram] [varchar](200) NULL,
	[CaseOwner] [varchar](500) NULL,
	[TaskOwner] [varchar](500) NULL,
	[MemberOwnerByUser] [varchar](500) NULL,
	[MemberID] [varchar](100) NULL,
	[LOB] [varchar](100) NULL,
	[PlanGroup] [varchar](100) NULL,
	[County] [varchar](100) NULL,
	[Region] [varchar](100) NULL,
	[Isactive] [bit] NULL,
	[HealthPlanEmployeeFlag] [varchar](1) NULL,
	[FirstName] [varchar](200) NULL,
	[LastName] [varchar](200) NULL,
	[DOB] [date] NULL,
	[GroupId] [int] NULL,
	[MemberOwnedByGroup] [varchar](255) NULL,
	[CmOrGRegion] [varchar](50) NULL,
	[CompanyKey] [int] NULL,
	[CompanyName] [varchar](100) NULL,
	[RiskGroupID] [int] NULL,
	[State] [varchar](2) NULL,
	[GrpInitvCd] [varchar](30) NULL,
	[BenefitGroup] [varchar](255) NULL
) ON [PRIMARY]

SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [IX_ComputedCareQueue2_HPEmployee] ON [dbo].[ComputedCareQueue2]
(
	[MVDID] ASC,
	[HealthPlanEmployeeFlag] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [IX_ComputedCareQueue2_MemberIDLOB] ON [dbo].[ComputedCareQueue2]
(
	[MemberID] ASC,
	[LOB] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [IX_ComputedCareQueue2_MVDID] ON [dbo].[ComputedCareQueue2]
(
	[MVDID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
CREATE NONCLUSTERED INDEX [IX_ComputedCareQueue2_RiskGroupID_IsActive] ON [dbo].[ComputedCareQueue2]
(
	[Isactive] ASC,
	[RiskGroupID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]