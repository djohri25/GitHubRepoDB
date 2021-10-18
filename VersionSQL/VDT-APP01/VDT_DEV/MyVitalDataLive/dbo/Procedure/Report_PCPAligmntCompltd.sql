/****** Object:  Procedure [dbo].[Report_PCPAligmntCompltd]    Committed by VersionSQL https://www.versionsql.com ******/

/*
Author:		Jose Pons
Create date:	2020-12-16
Description:	Generate data for ABCBS report 
			called PCP Alignment Report
Ticket:		4072

Test Case:
Exec [dbo].[Report_PCPAligmntCompltd]
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
20210217		Jose Pons			Add First and Last Name
20210309		Jose Pons			Changes on #4072
07/23/2021		Bhupinder Singh		#5707 Added PlanType, ConsentDate columns. Update YTD logic to display data till yesterday.

Report_PCPAligmntCompltd '08/01/2021','10/22/2021',0,0,'ALL','HAEXCHNG'
*/

CREATE PROCEDURE [dbo].[Report_PCPAligmntCompltd]
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
--	@StartDate			date			= '20200101',
--	@EndDate			date			= '20201231',
--	@YTD				bit				= 0,
--	@OnlyAuditable		bit				= 0,
--	@LOB				varchar(MAX)	= 'ALL',
--	@CmOrgRegion		varchar(MAX)	= 'ALL',
--	@CompanyKey			varchar(MAX)	= 'ALL',
--	@CaseProgram		varchar(MAX)	= 'ALL',
--	@CaseManager		varchar(MAX)	= 'ALL'


if (@YTD = 1)
begin
	set @startdate =  DATEADD(yy, DATEDIFF(yy, 0, GETDATE()), 0)
	set @enddate = DATEADD(dd,-1,CAST(GETDATE() AS DATE))
end

	
drop table if exists #cases

select 
	--mmf.ID, 
	mmf.MVDID, 
	mmf.CaseID,
	ccq.MemberID,
	ccq.[LastName],
	ccq.[FirstName],
	mmf.[q1CaseCreateDate],
	mmf.[q1CaseOwner],
	mmf.[q4CaseProgram],
	mmf.auditableCase,
	mmf.q2ConsentDate,
	ccq.LOB,
	ccq.CmOrgRegion,
	ccq.CompanyKey,
	CompanyName,
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
	dbo.ABCBS_MemberManagement_Form mmf (readuncommitted)
	--logic to get active forms
	inner join ABCBS_MMFHistory_Form mmf_hist (readuncommitted) 
		on mmf_hist.OriginalFormID = mmf.ID
	inner join HPAlertNote hlan (readuncommitted) 
		on hlan.LinkedFormID = mmf_hist.OriginalFormID 
		and hlan.LinkedFormType = 'ABCBS_MMFHistory' 
		and	ISNULL(hlan.IsDelete,0) != 1
	inner join dbo.ComputedCareQueue CCQ (readuncommitted) 
		on CCQ.MVDID = mmf.MVDID
	LEFT JOIN [dbo].[FinalEligibility] IH (readuncommitted) 
		ON mmf.MVDID = IH.MVDID 
		AND IsNull(IH.FakeSpanInd,'N') != 'Y' 
		and IsNull(IH.SpanVoidInd,'N') != 'Y'
		And mmf.[q1CaseCreateDate] Between MemberEffectiveDate AND MemberTerminationDate
where 
	mmf.[q1CaseCreateDate] between @startdate and @enddate
	and ((@OnlyAuditable = 0) or (@OnlyAuditable = 1 and mmf.AuditableCase = 1))
	and ((@LOB = 'ALL') or (CHARINDEX(CCQ.LOB, @LOB) > 0))
	--and ((@CmOrgRegion = 'ALL') or (CHARINDEX(CCQ.CmOrgRegion, @CmOrgRegion) > 0))
	and (@CmOrgRegion = 'ALL' OR CCQ.CmOrgRegion IN (SELECT data FROM dbo.Split(@CmOrgRegion,',')))
	and ((@CompanyKey = 'ALL') or (CHARINDEX(cast(CCQ.CompanyKey as varchar(10)), @CompanyKey) > 0))
	and ((@CaseProgram = 'ALL') or (CHARINDEX(mmf.q4CaseProgram, @CaseProgram) > 0))
	and ((@CaseManager = 'ALL') or (CHARINDEX(mmf.q1CaseOwner, @CaseManager) > 0))
	and IsNull(mmf.q2CloseReason,'--') != 'Void'
	
;with [cteAssmnt] as (
--Get Initial Assessment for Patient within 7 days of the case opened/created
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
	[q4Score],		-- Question: PCP Alignment Completed
					--Do you have a Primary Care Provider	
	[q5Score],		--Did you educate the member
	q4ScoreOther,	--how long since you saw your last PCP?
	q4InstatePCPType, --if you reside in Arkansas is the provider one of our value-based providers
	q4OutstatePCP,	--if you reside in Arkansas and do not have a PCP did CM make a referral to one of our Value Based Providers
	q4OutstatePCPType, --If yes, select the Value Based Provider:
	q5ScoreOther	--How did you educate the member?
from dbo.[ARBCBS_InitialAssessment_Form] iaf (readuncommitted)
	inner join	#cases c
		on iaf.[MVDID] = c.[MVDID]
			and iaf.[qCaseProgram] = c.[q4CaseProgram]
where
	iaf.[FormDate] between [q1CaseCreateDate] and Dateadd( day, 7, [q1CaseCreateDate] )	--Within 7 days of case opened/created
),
[cteInitAssmnt] as (
--Only the first one/oldest if there are many
select 
	[MVDID],
	[q4Score],
	[q5Score],
	q4ScoreOther,	--how long since you saw your last PCP?
	q4InstatePCPType, --if you reside in Arkansas is the provider one of our value-based providers
	q4OutstatePCP,	--if you reside in Arkansas and do not have a PCP did CM make a referral to one of our Value Based Providers
	q4OutstatePCPType,
	q5ScoreOther
from
	[cteAssmnt]
where
	[RowNumber] = 1
)

select distinct 
	[CaseID],
	[MemberID],
	[LastName],
	[FirstName],
	[q1CaseOwner]											[CaseManager], 
	IsNull(q4CaseProgram,'n/a')								[CaseProgram], 
	--IsNull(a.Asmt,'n/a') as AssessmentType, 
	[q1CaseCreateDate]										[CaseCreateDate],
	case 
		when isnull([q4Score],'No') = 'Yes' then 'Y'
		when isnull([q5Score],'No') = 'Yes' then 'Y'
		else NULL end										[HavePCP],
	--case when DATEDIFF( day, q1CaseCreateDate, IsNull( [q1CaseCloseDate],'2040-12-31')) <= 7 then 'Y' else 'N' end as Completed,
	[LOB],
	[CmOrgRegion],
	[CompanyKey],
	[CompanyName],
	c.PlanType,
	c.q2ConsentDate ConsentDate,
	IIF(c.AuditableCase = 1, 'Y','N') Auditable,
	q4ScoreOther SinceLastVisit,
	q4InstatePCPType ValueBasedPCP,
	IIF(q4OutstatePCP = 'No', 'No Referral Made', q4OutstatePCPType) ReferralMade,
	IIF([q5Score] = 'No', 'No', q5ScoreOther) MemEducated
from #cases c
	left join [cteInitAssmnt] a 
		on a.[MVDID] = c.[MVDID]
order by 
	[CaseProgram], 
	[HavePCP], 
	[CaseManager]


END