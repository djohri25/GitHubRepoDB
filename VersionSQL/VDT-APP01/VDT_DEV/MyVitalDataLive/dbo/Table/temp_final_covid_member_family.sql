/****** Object:  Table [dbo].[temp_final_covid_member_family]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[temp_final_covid_member_family](
	[MemberID] [varchar](15) NULL,
	[SubscriberID] [varchar](10) NULL,
	[FName] [varchar](50) NULL,
	[LName] [varchar](50) NULL,
	[Sex] [varchar](1) NULL,
	[Age] [int] NULL,
	[Relationship] [varchar](2) NULL,
	[Address1] [varchar](100) NULL,
	[Address2] [varchar](50) NULL,
	[City] [varchar](50) NULL,
	[State] [varchar](2) NULL,
	[Zip] [varchar](9) NULL,
	[HomePhone] [varchar](10) NULL,
	[CmOrgRegion] [varchar](50) NULL,
	[LOB] [varchar](2) NULL,
	[County] [varchar](30) NULL,
	[RiskScore] [int] NULL,
	[EBIRisk] [varchar](20) NULL,
	[CaseId] [varchar](1000) NULL,
	[FormDate] [datetime] NULL,
	[CaseOwner] [varchar](500) NULL
) ON [PRIMARY]