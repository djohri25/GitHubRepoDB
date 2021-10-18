/****** Object:  Table [dbo].[temp_sunny_pbi2]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[temp_sunny_pbi2](
	[MemberID] [varchar](15) NULL,
	[Zipcode] [varchar](9) NULL,
	[State] [varchar](2) NULL,
	[countyname] [varchar](30) NULL,
	[SubscriberID] [varchar](10) NULL,
	[CmOrgRegion] [varchar](50) NULL,
	[Relationship] [varchar](2) NULL,
	[MVDID] [varchar](30) NOT NULL,
	[ClaimNumber] [varchar](20) NULL,
	[StatementFromDate] [date] NULL,
	[Code] [varchar](12) NULL,
	[TypeOfDiag] [varchar](5) NOT NULL,
	[RiskGroupID] [int] NULL,
	[MemberFirstName] [varchar](50) NULL,
	[MemberLastName] [varchar](50) NULL,
	[Age] [int] NULL,
	[Sex] [varchar](1) NULL,
	[EmergencyIndicator] [bit] NULL,
	[NetworkIndicator] [varchar](1) NULL,
	[AdmissionDate] [datetime] NULL,
	[DischargeDate] [datetime] NULL,
	[DischargeStatusCode] [varchar](2) NULL,
	[BilledAmount] [decimal](18, 2) NULL,
	[ClaimStatus] [varchar](5) NULL,
	[FacilityTIN] [varchar](10) NULL,
	[PartyKey] [int] NULL,
	[CaseId] [varchar](1000) NULL,
	[CaseOwner] [varchar](500) NULL,
	[CaseProgram] [varchar](200) NULL,
	[FormDate] [datetime] NULL,
	[FormAuthor] [varchar](100) NULL,
	[EngagementType] [varchar](max) NULL,
	[WhoContacted] [varchar](max) NULL,
	[Disposition] [varchar](max) NULL,
	[1] [varchar](1) NOT NULL,
	[2] [varchar](1) NOT NULL,
	[3] [varchar](1) NOT NULL,
	[4] [varchar](1) NOT NULL,
	[5] [varchar](1) NOT NULL,
	[6] [varchar](1) NOT NULL,
	[7] [varchar](1) NOT NULL,
	[8] [varchar](1) NOT NULL,
	[9] [varchar](1) NOT NULL,
	[10] [varchar](1) NOT NULL,
	[11] [varchar](1) NOT NULL,
	[12] [varchar](1) NOT NULL,
	[13] [varchar](1) NOT NULL,
	[14] [varchar](1) NOT NULL,
	[15] [varchar](1) NOT NULL,
	[16] [varchar](1) NOT NULL,
	[17] [varchar](1) NOT NULL,
	[18] [varchar](1) NOT NULL,
	[19] [varchar](1) NOT NULL,
	[20] [varchar](1) NOT NULL,
	[21] [varchar](1) NOT NULL,
	[22] [varchar](1) NOT NULL,
	[23] [varchar](1) NOT NULL,
	[24] [varchar](1) NOT NULL,
	[25] [varchar](1) NOT NULL,
	[26] [varchar](1) NOT NULL,
	[27] [varchar](1) NOT NULL,
	[28] [varchar](1) NOT NULL,
	[29] [varchar](1) NOT NULL,
	[30] [varchar](1) NOT NULL,
	[31] [varchar](1) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]