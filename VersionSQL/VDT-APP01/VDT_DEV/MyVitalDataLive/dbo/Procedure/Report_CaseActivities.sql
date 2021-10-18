/****** Object:  Procedure [dbo].[Report_CaseActivities]    Committed by VersionSQL https://www.versionsql.com ******/

/*
 Author:		Jose Pons
 Create date:	2020-12-28
 Description:	Generate data for ABCBS report 
				called Case with Activities Report
 Ticket:		4188

Case Test:
EXEC [dbo].[Report_CaseActivities]
	@StartDate			= '20200901',
	@EndDate			= '20201231',
	@YTD				= 0,
	@OnlyAuditable		= 0,
	@LOB				= 'ALL',
	@CmOrgRegion		= 'ALL',
	@CompanyKey			= 'ALL',
	@CaseProgram		= 'ALL',
	@CaseManager		= 'ALL'


Modified		Modified By		Details
20210203		Jose Pons		Tweak Rx med recon count per session
20210218		Jose Pons		Add Last and First Name
06/09/2021		Bhupinder Singh	#4205 - Test cases not showing up. Updated link to HPAlertNote table to use the ID column.
								Also updated the Where clause to cast the db datetime as date since input is date.
06/15/2021		Sunil Nokku		Add Table Hint (readuncommitted) 
07/23/2021		Bhupinder Singh	#5715 - Add PlanType column.

Report_CaseActivities '01/01/2021','07/22/2021',1 --19040
*/

CREATE PROCEDURE [dbo].[Report_CaseActivities]
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
--	@OnlyAuditable		bit = 0,
--	@LOB				varchar(MAX),
--	@CmOrgRegion		varchar(MAX),
--	@CompanyKey			varchar(MAX),
--	@CaseProgram		varchar(MAX),
--	@CaseManager		varchar(MAX) 

--Select
--	@StartDate			= '20200901',
--	@EndDate			= '20201231',
--	@YTD				= 0,
--	@OnlyAuditable		= 0,
--	@LOB				= 'ALL',
--	@CmOrgRegion		= 'ALL',
--	@CompanyKey			= 'ALL',
--	@CaseProgram		= 'ALL',
--	@CaseManager		= 'ALL'

	if (@YTD = 1)
	begin
		set @startdate =  DATEADD(yy, DATEDIFF(yy, 0, GETDATE()), 0)
		set @enddate = DATEADD(dd,-1,CAST(GETDATE() AS DATE))
	end

	
	drop table if exists #cases
	drop table if exists #Assessment
	drop table if exists #CarePlane
	drop table if exists #OtherForms

	;WITH TotalContacts (MVDID, CaseID, LastContactDate, PhoneSuccess, PhoneFail, OutboundEmail, InboundEmail, OutboundMobile, InboundMobile, TotalContacts) AS
	(	SELECT mmf.MVDID, mmf.CaseID, MAX(cf.q1ContactDate) [LastContactDate],
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
	)	
		select distinct 
		mmf.[MVDID], 
		mmf.[CaseID],
		ccq.[MemberID],
		ccq.[LastName],
		ccq.[FirstName],
		mmf.[CaseProgram],
		mmf.[q1CaseOwner],
		mmf.[q1CaseCreateDate],
		mmf.[q5CaseCategory],
		mmf.[q5CaseType],
		mmf.[qCaseLevel],
		mmf.[q2ConsentDate],
		mmf.[AuditableCase],
		DateDiff( 
			day, 
			ISNULL(mmf.[q1CaseCreateDate], GetDate()), 
			case when mmf.[q1CaseCloseDate] = '1900-01-01 00:00:00.000' then ISNULL(mmf.[q1CaseCloseDate], GetDate())
			else ISNULL(mmf.[q1CaseCloseDate], GetDate()) end)					[CaseAge],

		case when mmf.[q1CaseCloseDate] = '1900-01-01 00:00:00.000' then null
			else mmf.[q1CaseCloseDate] end					[q1CaseCloseDate],
		--mmf.[CarePlanID],
		ccq.[LOB],
		ccq.[CMOrgRegion],
		ccq.[CompanyName],
		ccq.[RiskGroupID],
		ISNULL(tc.TotalContacts, 0) TotalContacts,
		ISNULL(tc.PhoneSuccess, 0) PhoneSuccess,
		ISNULL(tc.PhoneFail, 0) PhoneFail,
		ISNULL(tc.OutboundEmail, 0) OutboundEmail,
		ISNULL(tc.InboundEmail, 0) InboundEmail,
		ISNULL(tc.OutboundMobile, 0) OutboundMobile,
		ISNULL(tc.InboundMobile, 0) InboundMobile,
		tc.[LastContactDate],
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
	into 
		#cases
	from 
		dbo.[ABCBS_MemberManagement_Form] mmf (readuncommitted)
		--logic to get active forms
		inner join dbo.[ABCBS_MMFHistory_Form] mmf_hist (readuncommitted)
			on mmf_hist.[OriginalFormID] = mmf.[ID]
		inner join dbo.[HPAlertNote] hlan  (readuncommitted)
			on hlan.[LinkedFormID] = mmf_hist.ID 
			and hlan.[LinkedFormType] = 'ABCBS_MMFHistory' 
			and	ISNULL(hlan.[IsDelete],0) != 1
		inner join dbo.[ComputedCareQueue] ccq (readuncommitted)
			on ccq.[MVDID] = MMF.[MVDID]
		left join TotalContacts tc ON tc.MVDID = mmf.MVDID AND tc.CaseID = mmf.CaseID
		LEFT JOIN [dbo].[FinalEligibility] IH (readuncommitted) 
			ON mmf.MVDID = IH.MVDID 
			AND IsNull(IH.FakeSpanInd,'N') != 'Y' 
			and IsNull(IH.SpanVoidInd,'N') != 'Y'
			And mmf.[q1CaseCreateDate] Between MemberEffectiveDate AND MemberTerminationDate
	where 
		CAST(mmf.[q1CaseCreateDate] AS DATE) between @startdate and @enddate
		and ((@LOB = 'ALL') or (CHARINDEX(ccq.[LOB], @LOB) > 0))
		and ((@CmOrgRegion = 'ALL') or (CHARINDEX(ccq.[CmOrgRegion], @CmOrgRegion) > 0))
		and ((@CaseProgram = 'ALL') or (CHARINDEX(mmf.[CaseProgram], @CaseProgram) > 0))
		and ((@CaseManager = 'ALL') or (CHARINDEX(mmf.[q1CaseOwner], @CaseManager) > 0))
		and IsNull(mmf.[q2CloseReason],'--') != 'Void'
		and ((@CompanyKey = 'ALL') 
			or (CHARINDEX(cast(ccq.[CompanyKey] as varchar(10)), @CompanyKey) > 0 
				or ccq.[CompanyName] LIKE '%'+@CompanyKey+'%'))


	--Get Assessments count
	select 
		f.[MVDID],
		count(*)						[FormCount],
		MAX(f.[FormDate])				LastAssessmentContactDate
	into 
		#Assessment
	from 
		dbo.[ABCBS_PediatricComplexAssessment_Form] f (readuncommitted)
		inner join #cases c
			on f.[MVDID] = c.[MVDID] 
				and f.[FormDate] between c.[q1CaseCreateDate] and isnull( c.[q1CaseCloseDate], getdate() )
	group by
		f.[MVDID]

	union all
	select 
		f.[MVDID],
		count(*)						[FormCount],
		MAX(f.[FormDate])				LastAssessmentContactDate
	from dbo.[ARBCBS_InitialAssessment_Form] f (readuncommitted)
		inner join #cases c
			on f.[MVDID] = c.[MVDID] 
				and f.[FormDate] between c.[q1CaseCreateDate] and isnull( c.[q1CaseCloseDate], getdate() )
	group by
		f.[MVDID]
	
	union all
	select 
		f.[MVDID],
		count(*)						[FormCount],
		MAX(f.[FormDate])				LastAssessmentContactDate
	from dbo.[ABCBS_NeonatalAssessment_Form] f (readuncommitted)
		inner join #cases c
			on f.[MVDID] = c.[MVDID] 
				and f.[FormDate] between c.[q1CaseCreateDate] and isnull( c.[q1CaseCloseDate], getdate() )
	group by
		f.[MVDID]
	
	union all
	select 
		f.[MVDID],
		count(*)						[FormCount],
		MAX(f.[FormDate])				LastAssessmentContactDate
	from dbo.[ABCBS_SocialAssessment_Form] f (readuncommitted)
		inner join #cases c
			on f.[MVDID] = c.[MVDID] 
				and f.[FormDate] between c.[q1CaseCreateDate] and isnull( c.[q1CaseCloseDate], getdate() )
	group by
		f.[MVDID]
	
	union all
	select 
		f.[MVDID],
		count(*)						[FormCount],
		MAX(f.[FormDate])				LastAssessmentContactDate
	from dbo.[ABCBS_MaternityComplexAssessment_Form] f (readuncommitted)
		inner join #cases c
			on f.[MVDID] = c.[MVDID] 
				and f.[FormDate] between c.[q1CaseCreateDate] and isnull( c.[q1CaseCloseDate], getdate() )
	group by
		f.[MVDID]
	
	union all
	select 
		f.[MVDID],
		count(*)						[FormCount],
		MAX(f.[FormDate])				LastAssessmentContactDate
	from dbo.[ARBCBS_ComplexAssessment_Form] f (readuncommitted)
		inner join #cases c
			on f.[MVDID] = c.[MVDID] 
				and f.[FormDate] between c.[q1CaseCreateDate] and isnull( c.[q1CaseCloseDate], getdate() )
	group by
		f.[MVDID]


	--Get Care Plans count 
	select 
		f.[MVDID],
		count(*)						[FormCount],
		MAX(f.[CreatedDate])			LastCarePlanContactDate
		--cpo.[Status]			--Status: 0. Incomplete/ 1. Completed/ 2. Pending
	into
		#CarePlane
	from
		dbo.[MainCarePlanMemberIndex] f (readuncommitted)
		inner join #cases c
			on f.[MVDID] = c.[MVDID] 
				--and cpi.[CarePlanType] = c.[CaseProgram] 
				--and cpi.[CarePlanID] = c.[CarePlanID]
				and f.[CreatedDate] between c.[q1CaseCreateDate] and isnull( c.[q1CaseCloseDate], getdate() )
				and f.[CarePlanStatus] = 1
	group by
		f.[MVDID]
	order by
		f.[MVDID]


	--Get Other Forms count
	select 
		f.[MVDID],
		count(*)						[FormCount]
	into
		#OtherForms
	from dbo.[Home_Visit_Form] f (readuncommitted)
		inner join #cases c
			on f.[MVDID] = c.[MVDID] 
				and f.[FormDate] between c.[q1CaseCreateDate] and isnull( c.[q1CaseCloseDate], getdate() )
	group by
		f.[MVDID]

	--ABCBS_MemberManagement_Form
	--ABCBS_MMFHistory_Form

	union all
	select 
		f.[MVDID],
		count(*)						[FormCount]
	from dbo.[ABCBS_CaseSaving_Form] f (readuncommitted)
		inner join #cases c
			on f.[MVDID] = c.[MVDID] 
				and f.[FormDate] between c.[q1CaseCreateDate] and isnull( c.[q1CaseCloseDate], getdate() )
	group by
		f.[MVDID]
	
	union all
	select 
		f.[MVDID],
		count(*)						[FormCount]
	from dbo.[ABCBS_FEPPharmacist_Form] f (readuncommitted)
		inner join #cases c
			on f.[MVDID] = c.[MVDID] 
				and f.[FormDate] between c.[q1CaseCreateDate] and isnull( c.[q1CaseCloseDate], getdate() )	
	group by
		f.[MVDID]

	union all
	select 
		f.[MVDID],
		count(*)						[FormCount]
	from dbo.[ABCBS_PreAdmitCall_Form] f (readuncommitted)
		inner join #cases c
			on f.[MVDID] = c.[MVDID] 
				and f.[FormDate] between c.[q1CaseCreateDate] and isnull( c.[q1CaseCloseDate], getdate() )	
	group by
		f.[MVDID]
	
	union all
	select 
		f.[MVDID],
		count(*)						[FormCount]
	from dbo.[ABCBS_FEPDMEnrollment_Form] f (readuncommitted)
		inner join #cases c
			on f.[MVDID] = c.[MVDID] 
				and f.[FormDate] between c.[q1CaseCreateDate] and isnull( c.[q1CaseCloseDate], getdate() )	
	group by
		f.[MVDID]
	
	union all
	select 
		f.[MVDID],
		count(*)						[FormCount]
	from dbo.[ABCBS_FEPCMScreening_Form] f  (readuncommitted)
		inner join #cases c
			on f.[MVDID] = c.[MVDID] 
				and f.[FormDate] between c.[q1CaseCreateDate] and isnull( c.[q1CaseCloseDate], getdate() )	
	group by
		f.[MVDID]
	
	union all
	select 
		f.[MVDID],
		count(*)						[FormCount]
	from dbo.[ABCBS_HEP_CatchAir_Form] f  (readuncommitted)
		inner join #cases c
			on f.[MVDID] = c.[MVDID] 
				and f.[FormDate] between c.[q1CaseCreateDate] and isnull( c.[q1CaseCloseDate], getdate() )	
	group by
		f.[MVDID]
	
	union all
	select 
		f.[MVDID],
		count(*)						[FormCount]
	from dbo.[ABCBS_HEP_OnTheLevel_Form] f  (readuncommitted)
		inner join #cases c
			on f.[MVDID] = c.[MVDID] 
				and f.[FormDate] between c.[q1CaseCreateDate] and isnull( c.[q1CaseCloseDate], getdate() )	
	group by
		f.[MVDID]
	
	union all
	select 
		f.[MVDID],
		count(*)						[FormCount]
	from dbo.[ABCBS_HEP_AdultEnrollment_Form] f  (readuncommitted)
		inner join #cases c
			on f.[MVDID] = c.[MVDID] 
				and f.[FormDate] between c.[q1CaseCreateDate] and isnull( c.[q1CaseCloseDate], getdate() )	
	group by
		f.[MVDID]
	
	union all
	select 
		f.[MVDID],
		count(*)						[FormCount]
	from dbo.[ABCBS_FEPDMDischarge_Form] f  (readuncommitted)
		inner join #cases c
			on f.[MVDID] = c.[MVDID] 
				and f.[FormDate] between c.[q1CaseCreateDate] and isnull( c.[q1CaseCloseDate], getdate() )	
	group by
		f.[MVDID]
	
	union all
	select 
		f.[MVDID],
		count(*)						[FormCount]
	from dbo.[ABCBS_GapsInCondition_Form] f  (readuncommitted)
		inner join #cases c
			on f.[MVDID] = c.[MVDID] 
				and f.[FormDate] between c.[q1CaseCreateDate] and isnull( c.[q1CaseCloseDate], getdate() )	
	group by
		f.[MVDID]
	
	union all
	select 
		f.[MVDID],
		count(*)						[FormCount]
	from dbo.[ABCBS_HEP_EDEnrollment_Form] f  (readuncommitted)
		inner join #cases c
			on f.[MVDID] = c.[MVDID] 
				and f.[FormDate] between c.[q1CaseCreateDate] and isnull( c.[q1CaseCloseDate], getdate() )	
	group by
		f.[MVDID]
	
	union all
	select 
		f.[MVDID],
		count(*)						[FormCount]
	from dbo.[PatientHealthQuestionnaire_Form] f  (readuncommitted)
		inner join #cases c
			on f.[MVDID] = c.[MVDID] 
				and f.[FormDate] between c.[q1CaseCreateDate] and isnull( c.[q1CaseCloseDate], getdate() )	
	group by
		f.[MVDID]
	
	union all
	select 
		f.[MVDID],
		count(*)						[FormCount]
	from dbo.[ABCBS_GapsInCare_Form] f  (readuncommitted)
		inner join #cases c
			on f.[MVDID] = c.[MVDID] 
				and f.[FormDate] between c.[q1CaseCreateDate] and isnull( c.[q1CaseCloseDate], getdate() )	
	group by
		f.[MVDID]
	
	union all
	select 
		f.[MVDID],
		count(*)						[FormCount]
	from dbo.[ABCBS_FEPCMCostBenefit_Form] f  (readuncommitted)
		inner join #cases c
			on f.[MVDID] = c.[MVDID] 
				and f.[FormDate] between c.[q1CaseCreateDate] and isnull( c.[q1CaseCloseDate], getdate() )	
	group by
		f.[MVDID]
	
	union all
	select 
		f.[MVDID],
		count(*)						[FormCount]
	from dbo.[ABCBS_TransitionOfCare_Form] f  (readuncommitted)
		inner join #cases c
			on f.[MVDID] = c.[MVDID] 
				and f.[FormDate] between c.[q1CaseCreateDate] and isnull( c.[q1CaseCloseDate], getdate() )	
	group by
		f.[MVDID]
	
	union all
	select 
		f.[MVDID],
		count(*)						[FormCount]
	from dbo.[ABCBS_ExcessLoss_Form] f  (readuncommitted)
		inner join #cases c
			on f.[MVDID] = c.[MVDID] 
				and f.[FormDate] between c.[q1CaseCreateDate] and isnull( c.[q1CaseCloseDate], getdate() )	
	group by
		f.[MVDID]
	
	union all
	select 
		f.[MVDID],
		count(*)						[FormCount]
	from dbo.[ABCBS_MedHUB_Form] f  (readuncommitted)
		inner join #cases c
			on f.[MVDID] = c.[MVDID] 
				and f.[FormDate] between c.[q1CaseCreateDate] and isnull( c.[q1CaseCloseDate], getdate() )	
	group by
		f.[MVDID]
	
	union all
	select 
		f.[MVDID],
		count(*)						[FormCount]
	from dbo.[ABCBS_MRR_Form] f  (readuncommitted)
		inner join #cases c
			on f.[MVDID] = c.[MVDID] 
				and f.[FormDate] between c.[q1CaseCreateDate] and isnull( c.[q1CaseCloseDate], getdate() )	
	group by
		f.[MVDID]
	
	union all
	select 
		f.[MVDID],
		count(*)						[FormCount]
	from dbo.[ABCBS_BariatricHistory_Form] f  (readuncommitted)
		inner join #cases c
			on f.[MVDID] = c.[MVDID] 
				and f.[FormDate] between c.[q1CaseCreateDate] and isnull( c.[q1CaseCloseDate], getdate() )	
	group by
		f.[MVDID]
	
	union all
	select 
		f.[MVDID],
		count(*)						[FormCount]
	from dbo.[ABCBS_Bariatric_Form] f  (readuncommitted)
		inner join #cases c
			on f.[MVDID] = c.[MVDID] 
				and f.[FormDate] between c.[q1CaseCreateDate] and isnull( c.[q1CaseCloseDate], getdate() )	
	group by
		f.[MVDID]
	
	union all
	select 
		f.[MVDID],
		count(*)						[FormCount]
	from dbo.[ABCBS_HepatitisC_SVRResults_Form] f  (readuncommitted)
		inner join #cases c
			on f.[MVDID] = c.[MVDID] 
				and f.[FormDate] between c.[q1CaseCreateDate] and isnull( c.[q1CaseCloseDate], getdate() )	
	group by
		f.[MVDID]
	
	union all
	select 
		f.[MVDID],
		count(*)						[FormCount]
	from dbo.[ABCBS_HEPCPharmacy_Form] f  (readuncommitted)
		inner join #cases c
			on f.[MVDID] = c.[MVDID] 
				and f.[FormDate] between c.[q1CaseCreateDate] and isnull( c.[q1CaseCloseDate], getdate() )	
	group by
		f.[MVDID]
	
	union all
	select 
		f.[MVDID],
		count(*)						[FormCount]
	from dbo.[ABCBS_MaternityEnrollment_Form] f  (readuncommitted)
		inner join #cases c
			on f.[MVDID] = c.[MVDID] 
				and f.[FormDate] between c.[q1CaseCreateDate] and isnull( c.[q1CaseCloseDate], getdate() )	
	group by
		f.[MVDID]
	
	union all
	select 
		f.[MVDID],
		count(*)						[FormCount]
	from dbo.[ABCBS_MaternityRiskREEvaluation_Form] f  (readuncommitted)
		inner join #cases c
			on f.[MVDID] = c.[MVDID] 
				and f.[FormDate] between c.[q1CaseCreateDate] and isnull( c.[q1CaseCloseDate], getdate() )	
	group by
		f.[MVDID]
	
	union all
	select 
		f.[MVDID],
		count(*)						[FormCount]
	from dbo.[ABCBS_Transplant_Form] f  (readuncommitted)
		inner join #cases c
			on f.[MVDID] = c.[MVDID] 
				and f.[FormDate] between c.[q1CaseCreateDate] and isnull( c.[q1CaseCloseDate], getdate() )	
	group by
		f.[MVDID]
	
	union all
	select 
		f.[MVDID],
		count(*)						[FormCount]
	from dbo.[ABCBS_ReferraltoNewDirections_Form] f  (readuncommitted)
		inner join #cases c
			on f.[MVDID] = c.[MVDID] 
				and f.[FormDate] between c.[q1CaseCreateDate] and isnull( c.[q1CaseCloseDate], getdate() )	
	group by
		f.[MVDID]
	
	union all
	select 
		f.[MVDID],
		count(*)						[FormCount]
	from dbo.[ABCBS_InterdisciplinaryTeam_Form] f  (readuncommitted)
		inner join #cases c
			on f.[MVDID] = c.[MVDID] 
				and f.[FormDate] between c.[q1CaseCreateDate] and isnull( c.[q1CaseCloseDate], getdate() )	
	group by
		f.[MVDID]


	--Initial Asessment
	;with [cteInitAssmnt] as (
	select
		ROW_NUMBER() OVER (
			PARTITION BY
				iaf.[MVDID]				
			ORDER BY
				iaf.[MVDID],
				iaf.[ID] 
			) as [RowNumber],
		iaf.[ID],
		iaf.[MVDID],
		iaf.[q2Score]
	from dbo.[ARBCBS_InitialAssessment_Form] iaf  (readuncommitted)
		inner join	#cases c
			on iaf.[MVDID] = c.[MVDID] and iaf.[qCaseProgram] = c.[CaseProgram]
	),
	[cteInitAssmntCondition] as (
	--Only the first one/oldest if there are many
	select 
		[MVDID],
		LTRIM(RTRIM(REPLACE(REPLACE(REPLACE([q2Score], '[', ''), ']', ''), '"', '')))	[CaseCondition]
	from
		[cteInitAssmnt]
	where
		[RowNumber] = 1
	),
	[cteContacts] as (
	select 
		f.[MVDID],
		count(*)						[FormCount]
	from 
		[dbo].[ARBCBS_Contact_Form] f  (readuncommitted)
		inner join #cases c
			on f.[MVDID] = c.[MVDID] 
				and f.[q2program] = c.[CaseProgram]
				and f.[FormDate] between c.[q1CaseCreateDate] and isnull( c.[q1CaseCloseDate], getdate() )
	group by
		f.[MVDID]
	),
	[cteAssessment] as (
	select 
		[MVDID],
		sum( [FormCount] )					[FormCount],
		MAX([LastAssessmentContactDate])	LastAssessmentContactDate
	from 
		#Assessment
	group by
		[MVDID]
	),
	[cteCarePlan] as (
	select 
		[MVDID],
		sum( [FormCount] )				[FormCount],
		MAX([LastCarePlanContactDate])	LastCarePlanContactDate
	from
		#CarePlane
	group by
		[MVDID]
	),
	[cteMedRec] as (
	select 
		f.[MVDID],
		count(distinct [SessionID])		[FormCount],
		MAX(f.[ReconDateTime])			LastMedRecContactDate
	from
		[dbo].[MainMedRec] f  (readuncommitted)
		inner join #cases c
			on f.[MVDID] = c.[MVDID] 
				and f.[ReconDateTime] between c.[q1CaseCreateDate] and isnull( c.[q1CaseCloseDate], getdate() )
	group by
		f.[MVDID]
	),
	[cteConsults] as (
	select 
		f.[MVDID],
		count(*)						[FormCount]
	from
		dbo.[Consult_Form] f  (readuncommitted)
		inner join #cases c 
			on f.[MVDID] = c.[MVDID] 
				and f.[FormDate] between c.[q1CaseCreateDate] and isnull( c.[q1CaseCloseDate], getdate() )
	group by
		f.[MVDID]
	),
	[cteOtherForms] as (
	select 
		[MVDID],
		sum( [FormCount] )				[FormCount]
	from 
		#OtherForms
	group by
		[MVDID]
	),
	[NewDirectionsReferralForm] as (
		SELECT
			ndf.[MVDID],
			MAX(ndf.FormDate) [FormDate]
		FROM
			dbo.ABCBS_ReferraltoNewDirections_Form ndf (readuncommitted) 
		inner join #cases c 
			on ndf.[MVDID] = c.[MVDID] 
			and ndf.[FormDate] between c.[q1CaseCreateDate] and isnull( c.[q1CaseCloseDate], getdate() )
		group by
			ndf.[MVDID]
	)

	select 
		c.[CaseID],
		c.[MemberID],
		c.[LastName],
		c.[FirstName],
		IsNull(c.[CaseProgram],'n/a')			[CaseProgram], 
		cc.[CaseCondition],
		c.[q1CaseOwner]							[CaseManager], 
		c.[q1CaseCreateDate]					[CaseOpenedDate],
		c.[q5CaseCategory]						[CaseCategory],
		c.[q5CaseType]							[CaseType],
		c.[qCaseLevel]							[CaseLevel],
		c.[q2ConsentDate]						[ConsentDate],
		IIF(c.[AuditableCase]=1,'Y','N')		[AuditableCase],
		c.[CaseAge]								[CaseAge],
		
		case when c.[q1CaseCloseDate] = '1900-01-01 00:00:00.000' then null
			else c.[q1CaseCloseDate] end		[CaseClosedDate],
		IsNull(ct.[FormCount],0)				[Contacts],
		IsNull(ss.[FormCount],0)				[Assessments],
		IsNull(cp.[FormCount],0)				[CarePlans],
		IsNull(mr.[FormCount],0)				[MedRecCount],
		IsNull(cn.[FormCount],0)				[Consults],
		IsNull(ot.[FormCount],0)				[OtherForms],
		case when IsNull(ndrf.[MVDID],'No') = 'No' THEN 'N' ELSE 'Y' END [NewDirectionsForm], 
		c.[LOB],
		c.[CmOrgRegion],
		c.[CompanyName],
		ISNULL(c.[RiskGroupID],0)			[RiskScore],
		--ISNULL(c.TotalContacts, 0) TotalContacts,
		ISNULL(c.PhoneSuccess, 0) + ISNULL(c.OutboundEmail, 0) + ISNULL(c.InboundEmail, 0) + IsNull(ss.[FormCount],0) + IsNull(cp.[FormCount],0) + IsNull(mr.[FormCount],0) as TotalContacts,
		ISNULL(c.PhoneSuccess, 0) PhoneSuccess,
		ISNULL(c.PhoneFail, 0) PhoneFail,
		ISNULL(c.OutboundEmail, 0) OutboundEmail,
		ISNULL(c.InboundEmail, 0) InboundEmail,
		ISNULL(c.OutboundMobile, 0) OutboundMobile,
		ISNULL(c.InboundMobile, 0) InboundMobile,
		--c.LastContactDate
		(SELECT MAX(LastContactDate)
		FROM (VALUES (c.LastContactDate),(ss.LastAssessmentContactDate),(cp.LastCarePlanContactDate),(mr.LastMedRecContactDate)) AS UpdateDate(LastContactDate)) 
		AS LastContactDate,
		c.PlanType
	from #cases c
		left join [cteInitAssmntCondition] cc
			on c.[MVDID] = cc.[MVDID] 
		left join [cteContacts] ct
			on c.[MVDID] = ct.[MVDID]
		left join [cteAssessment] ss
			on c.[MVDID] = ss.[MVDID]
		left join [cteCarePlan] cp
			on c.[MVDID] = cp.[MVDID]
		left join [cteMedRec] mr
			on c.[MVDID] = mr.[MVDID]
		left join [cteConsults] cn
			on c.[MVDID] = cn.[MVDID]
		left join [cteOtherForms] ot
			on c.[MVDID] = ot.[MVDID]
		left join [NewDirectionsReferralForm] ndrf
			on c.[MVDID] = ndrf.[MVDID]

	--where c.[MemberID] = 'T0034676400'
	order by 
		c.[LOB],
		c.[q1CaseCreateDate] DESC,
		c.[CaseProgram], 
		cc.[CaseCondition]		 

END