/****** Object:  Table [dbo].[FinalEligibilityTemporary]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[FinalEligibilityTemporary](
	[RecordID] [bigint] IDENTITY(1,1) NOT NULL,
	[MVDID] [varchar](30) NOT NULL,
	[MemberID] [varchar](15) NOT NULL,
	[LOB] [varchar](2) NULL,
	[BabyID] [varchar](10) NULL,
	[MomID] [varchar](10) NULL,
	[MemberFirstName] [varchar](50) NULL,
	[MemberLastName] [varchar](50) NULL,
	[MemberMiddleName] [varchar](50) NULL,
	[MemberEffectiveDate] [date] NULL,
	[MemberTerminationDate] [date] NULL,
	[HealthPlanEmployeeFlag] [varchar](1) NULL,
	[CurrentCoPaylevel] [varchar](1) NULL,
	[PCPNPI] [int] NULL,
	[CategoryCode] [varchar](20) NULL,
	[CountyName] [varchar](30) NULL,
	[RiskGroupId] [varchar](20) NULL,
	[PayorTypeId] [varchar](50) NULL,
	[BenefitGroup] [varchar](20) NULL,
	[PlanGroup] [varchar](20) NULL,
	[PlanIdentifier] [varchar](25) NULL,
	[PlanMetalLevel] [varchar](25) NULL,
	[PlanPremiumAmount] [decimal](10, 2) NULL,
	[EnrollMaintainTypeCode] [varchar](5) NULL,
	[RateAreaIdentifier] [varchar](10) NULL,
	[Product] [varchar](20) NULL,
	[EligibleMedicalBenefit] [varchar](1) NULL,
	[EligibleRxBenefit] [varchar](1) NULL,
	[EligibleVisionBenefit] [varchar](1) NULL,
	[GestationAge] [varchar](2) NULL,
	[Birthweight] [varchar](6) NULL,
	[PreviousPlan] [varchar](100) NULL,
	[DisenrollmentReason] [varchar](4) NULL,
	[SDA] [varchar](20) NULL,
	[Perinate] [int] NULL,
	[Pregnant] [varchar](1) NULL,
	[CustID] [int] NULL,
	[BaseBatchID] [bigint] NULL,
	[CurrentBatchID] [bigint] NULL,
	[EligibleDentalBenefit] [varchar](1) NULL,
	[PartyKey] [int] NULL,
	[CompanyKey] [int] NULL,
	[SubgroupKey] [int] NULL,
	[MemberKey] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[MVDID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]