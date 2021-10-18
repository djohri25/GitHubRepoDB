/****** Object:  Procedure [dbo].[Report_CaseEngagement]    Committed by VersionSQL https://www.versionsql.com ******/

/*
Author:		Jose Pons
Create date:	2020-12-18
Description:	Generate data for ABCBS report 
			called Case Engagement Report
Ticket:		4068

Test Case:
Exec [dbo].[Report_CaseEngagement]
@StartDate			= '20200101',
@EndDate			= '20201231',
@YTD				= 0,
@OnlyAuditable		= 0,
@LOB				= 'ALL',
@CmOrgRegion		= 'ALL',
@CompanyKey			= 'ALL',
@CaseProgram		= 'ALL',
@CaseManager		= 'ALL'


Modified		Modified By			Details
20210217		Jose Pons			Add Last and First Name
20210422		Bill Ray			Add Multiple Columns and join with ARBCBS_Contact_Form for Contact Data
06/15/2021		Sunil Nokku		Add Table Hint (readuncommitted) 
07/22/2021		Bhupinder Singh		Ticket 5716 - Added PlanType Column
*/

CREATE PROCEDURE [dbo].[Report_CaseEngagement]
@StartDate			date,
@EndDate			date,
@YTD				bit = 0,
@OnlyAuditable		bit = 0,
@LOB				varchar(MAX) = 'ALL',
@CmOrgRegion		varchar(MAX) = 'ALL',
@CompanyKey			varchar(MAX) = 'ALL',
@CaseProgram		varchar(MAX) = 'ALL',
@CaseManager		varchar(MAX) = 'ALL'
AS
BEGIN

----For testing purposes
--Declare
--	@StartDate			date,
--	@EndDate			date,
--	@YTD				bit,
--	@OnlyAuditable		bit,
--	@LOB				varchar(MAX),
--	@CmOrgRegion		varchar(MAX),
--	@CompanyKey			varchar(MAX),
--	@CaseProgram		varchar(MAX),
--	@CaseManager		varchar(MAX) 

--Select
--	@StartDate			= '20200101',
--	@EndDate			= '20201231',
--	@YTD				= 0,
--	@OnlyAuditable		= 0,
--	@LOB				= 'ALL',
--	@CmOrgRegion		= 'ALL',
--	@CompanyKey			= 'ALL',
--	@CaseProgram		= 'ALL',
--	@CaseManager		= 'ALL'

	IF (@YTD = 1)
	BEGIN
		set @startdate =  DATEADD(yy, DATEDIFF(yy, 0, GETDATE()), 0)
		set @enddate = DATEADD(dd,-1,CAST(GETDATE() AS DATE))
	END

	
	;WITH TotalContacts (MVDID, CaseID, PhoneSuccess, PhoneFail, OutboundEmail, InboundEmail, OutboundMobile, InboundMobile, TotalContacts) AS
	(	SELECT mmf.MVDID, mmf.CaseID,
			SUM(CASE WHEN cf.q5ContactMethod = 'Phone' AND cf.q7ContactSuccess = 'Yes' THEN 1 ELSE 0 END) PhoneSuccess, 
			SUM(CASE WHEN cf.q5ContactMethod = 'Phone' AND cf.q7ContactSuccess = 'No' THEN 1 ELSE 0 END) PhoneFail, 
			SUM(CASE WHEN cf.q3ContactType = 'Outbound' AND cf.q5ContactMethod = 'Email' THEN 1 ELSE 0 END) OutboundEmail, 
			SUM(CASE WHEN cf.q3ContactType = 'Inbound' AND cf.q5ContactMethod = 'Email' THEN 1 ELSE 0 END) InboundEmail, 
			SUM(CASE WHEN cf.q3ContactType = 'Outbound' AND cf.q5ContactMethod = 'Mobile' THEN 1 ELSE 0 END) OutboundMobile, 
			SUM(CASE WHEN cf.q3ContactType = 'Inbound' AND cf.q5ContactMethod = 'Mobile' THEN 1 ELSE 0 END) InboundMobile, 
			SUM(CASE WHEN cf.q5ContactMethod = 'Phone' OR cf.q5ContactMethod = 'Email' OR cf.q5ContactMethod = 'Mobile' THEN 1 ELSE 0 END) TotalContacts
		FROM [dbo].[ABCBS_MemberManagement_Form] mmf (readuncommitted)
		JOIN [dbo].[ARBCBS_Contact_Form] cf (readuncommitted) ON cf.MVDID = mmf.MVDID AND cf.q1ContactDate BETWEEN @StartDate AND 
				CASE WHEN ISNULL(mmf.[q1CaseCloseDate], '1900-01-01 00:00:00.000' ) = '1900-01-01 00:00:00.000' THEN GETDATE() ELSE mmf.[q1CaseCloseDate] END
		WHERE cf.q1ContactDate BETWEEN mmf.q1CaseCreateDate AND 
				CASE WHEN ISNULL(mmf.[q1CaseCloseDate], '1900-01-01 00:00:00.000' ) = '1900-01-01 00:00:00.000' THEN GETDATE() ELSE mmf.[q1CaseCloseDate] END
		GROUP BY mmf.MVDID, mmf.CaseID
	), CaseList (MVDID, CaseID, q1CaseCreateDate, q1CaseOwner, CaseProgram, q6ConsentVerbal, ReferralReason, AuditableCase, q2ConsentDate, q1CaseCloseDate, DaysOpen, CaseStatus,
				MemberID, LastName, FirstName, RiskGroupID, LOB, CmOrgRegion, CompanyKey, CompanyName, PlanType) AS
	(
		SELECT 
			mmf.[MVDID], 
			mmf.[CaseID],
			mmf.[q1CaseCreateDate],
			mmf.[q1CaseOwner],
			mmf.[CaseProgram],
			mmf.[q6ConsentVerbal],
			mmf.[ReferralReason],
			mmf.[AuditableCase],
			mmf.[q2ConsentDate],
			mmf.[q1CaseCloseDate],
			DateDiff( 
				day, 
				mmf.[q1CaseCreateDate], 
				ISNULL( 
					CASE WHEN ISNULL(mmf.[q1CaseCloseDate], '1900-01-01 00:00:00.000' ) = '1900-01-01 00:00:00.000' THEN null ELSE mmf.[q1CaseCloseDate] END,
					GETDATE()))								[DaysOpen],
			CASE 
				WHEN ISNULL(mmf.[q1CaseCloseDate], '1900-01-01 00:00:00.000' ) = '1900-01-01 00:00:00.000' THEN 'Open' 
				ELSE 'Closed' END				[CaseStatus],
			ccq.[MemberID],
			ccq.[LastName],
			ccq.[FirstName],
			ccq.[RiskGroupID],
			ccq.[LOB],
			ccq.[CmOrgRegion],
			ccq.[CompanyKey],
			ccq.CompanyName,
			CASE WHEN IH.PlanIdentifier='H9699' AND IH.BenefitGroup IN (004,001,002,003) THEN 'Health Advantage Blue Classic (HMO)'
					WHEN IH.PlanIdentifier='H9699'  AND IH.BenefitGroup IN (006)			  THEN 'Health Advantage Blue Premier (HMO)'
					WHEN IH.PlanIdentifier='H4213'  AND IH.BenefitGroup IN (016,001,003,004) THEN 'BlueMedicare Value (PFFS)'
					WHEN IH.PlanIdentifier='H4213'  AND IH.BenefitGroup IN (017,001,005,006) THEN 'BlueMedicare Preferred (PFFS)'
					WHEN IH.PlanIdentifier='H3554'  AND IH.BenefitGroup IN (001,002)		  THEN 'BlueMedicare Saver Choice (PPO)'
					WHEN IH.PlanIdentifier='H3554'  AND IH.BenefitGroup IN (003,004,005,006) THEN 'BlueMedicare Value Choice (PPO)'
					WHEN IH.PlanIdentifier='H3554'  AND IH.BenefitGroup IN (007,008,009,010) THEN 'BlueMedicare Premier Choice (PPO)'
					WHEN IH.PlanIdentifier='H6158'  AND IH.BenefitGroup IN (001,002)		  THEN 'BlueMedicare Premier (PPO)'
			ELSE NULL 
			END  AS PlanType
		FROM 
			dbo.[ABCBS_MemberManagement_Form] mmf (readuncommitted)
			--logic to get active forms
			INNER JOIN dbo.[ABCBS_MMFHistory_Form] mmf_hist (readuncommitted) 
				ON mmf_hist.[OriginalFormID] = mmf.[ID]
			INNER JOIN dbo.[HPAlertNote] hlan (readuncommitted) 
				ON hlan.[LinkedFormID] = mmf_hist.[OriginalFormID] 
				AND hlan.[LinkedFormType] = 'ABCBS_MMFHistory' 
				AND	ISNULL(hlan.[IsDelete],0) != 1
			INNER JOIN dbo.[ComputedCareQueue] ccq (readuncommitted) 
				ON ccq.MVDID = mmf.MVDID
			LEFT JOIN [dbo].[FinalEligibility] IH (readuncommitted) 
				ON mmf.MVDID = IH.MVDID 
				AND IsNull(IH.FakeSpanInd,'N') != 'Y' 
				and IsNull(IH.SpanVoidInd,'N') != 'Y'
				And mmf.[q1CaseCreateDate] Between MemberEffectiveDate AND MemberTerminationDate
		where 
			CAST(mmf.[q1CaseCreateDate] AS DATE) BETWEEN @startdate AND @enddate
			AND ((@OnlyAuditable = 0) or (@OnlyAuditable = 1 AND mmf.[AuditableCase] = 1))
			AND ((@LOB = 'ALL') or (CHARINDEX(ccq.[LOB], @LOB) > 0))
			AND ((@CmOrgRegion = 'ALL') or (CHARINDEX(ccq.[CmOrgRegion], @CmOrgRegion) > 0))
			AND ((@CompanyKey = 'ALL') or (CHARINDEX(cast(ccq.[CompanyKey] as varchar(10)), @CompanyKey) > 0))
			AND ((@CaseProgram = 'ALL') or (CHARINDEX(mmf.[CaseProgram], @CaseProgram) > 0))
			AND ((@CaseManager = 'ALL') or (CHARINDEX(mmf.[q1CaseOwner], @CaseManager) > 0))
			AND ISNULL(mmf.[q2CloseReason],'--') != 'Void'
	)
	SELECT DISTINCT
		cl.[CaseID], 
		cl.[LastName],
		cl.[FirstName],
		ISNULL(cl.[CaseProgram],'n/a')	[CaseProgram], 
		cl.[CmOrgRegion],
		cl.[LOB],
		cl.[CompanyKey],
		cl.[CompanyName],
		cl.[MemberID],
		cl.[ReferralReason],
		CASE WHEN cl.[AuditableCase] = 1 THEN 'Y' ELSE 'N' END AuditableCase,
		cl.[q2ConsentDate] 					[ConsentDate],
		cl.[q1CaseCloseDate]				[CaseCloseDate],
		cl.[q1CaseCreateDate]				[CaseCreateDate],
		cl.[DaysOpen],
		cl.[CaseStatus],
		ISNULL(cl.[RiskGroupID],0)			[RiskScore],
		CASE 
			WHEN ISNULL(cl.[q6ConsentVerbal],'No') = 'No' THEN 'N' 
			ELSE 'Y' END					[Consent],
		ISNULL(tc.TotalContacts, 0) TotalContacts,
		ISNULL(tc.PhoneSuccess, 0) PhoneSuccess,
		ISNULL(tc.PhoneFail, 0) PhoneFail,
		ISNULL(tc.OutboundEmail, 0) OutboundEmail,
		ISNULL(tc.InboundEmail, 0) InboundEmail,
		ISNULL(tc.OutboundMobile, 0) OutboundMobile,
		ISNULL(tc.InboundMobile, 0) InboundMobile,
		cl.PlanType
	FROM CaseList cl
	LEFT OUTER JOIN TotalContacts tc ON tc.MVDID = cl.MVDID AND tc.CaseID = cl.CaseID
	ORDER BY 
		ISNULL([CaseProgram],'n/a'), 
		CASE WHEN ISNULL([q6ConsentVerbal],'No') = 'No' THEN 'N' ELSE 'Y' END, 
		[CmOrgRegion]

END