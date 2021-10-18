/****** Object:  Procedure [dbo].[Report_MedRecTurnaround]    Committed by VersionSQL https://www.versionsql.com ******/

/*
 Author:		Mike Grover
 Create date:	2020-12-14
 Description:	Generate data for ABCBS report 
              called Med Rec Turnaround Report
 Ticket:      4070

Test Case:
EXEC [dbo].[Report_MedRecTurnaround]
	@startdate			= '20200801',
	@enddate			= '20201231',
	@YTD				= 0,
	@OnlyAuditable		= 0,
	@LOB				= 'ALL',
	@CmOrgRegion		= 'ALL',
	@CompanyKey			= 'ALL',
	@CaseProgram		= 'ALL',
	@CaseManager		= 'ALL',
	@DueDays			= 7


Modified		Modified By				Details
20201216		Jose Pons				Added HPAlertNote to get active forms.
										Added parameter DueDays to handle 180 days
20210203		Jose Pons				Tweaked Rx recon based on 7 days range and open cases
										DeDupe the output
20210219		Jose Pons				Add Last and First Name
20210721		Bhupinder Singh			#5721 Added BenefitGroup as PlanType.
										Updated logic to use ConsentDate instead of CaseCreatedDate

[dbo].[Report_MedRecTurnaround] '01/01/2021','07/20/2021',1 --19240
*/

CREATE PROCEDURE [dbo].[Report_MedRecTurnaround]
@startdate			date,
@enddate			date,
@YTD				bit = 0,
@OnlyAuditable		bit = 0,
@LOB				varchar(MAX) = 'ALL',
@CmOrgRegion		varchar(MAX) = 'ALL',
@CompanyKey			varchar(MAX) = 'ALL',
@CaseProgram		varchar(MAX) = 'ALL',
@CaseManager		varchar(MAX) = 'ALL',
@DueDays			int			 = 7
AS
BEGIN


if (@YTD = 1)
begin
	set @startdate =  DATEADD(yy, DATEDIFF(yy, 0, GETDATE()), 0)
	set @enddate = DATEADD(day, -1, CAST(GETDATE() AS date))
end
	
drop table if exists #cases
drop table if exists #asmt

select 
	mmf.[ID], 
	mmf.[MVDID], 
	ccq.[MemberID], 
	ccq.[LastName], 
	ccq.[FirstName], 
	mmf.[CaseID],
	CAST(mmf.[q1CaseCreateDate] AS DATE) [q1CaseCreateDate],
	mmf.[q1CaseOwner],
	mmf.[q4CaseProgram],
	mmf.[auditableCase],
	mmf.[q2CloseReason],
	ccq.[LOB],
	ccq.[CmOrgRegion],
	ccq.[CompanyKey],
	ccq.[CompanyName],
	--#5721
	CASE WHEN IH.PlanIdentifier='H9699' AND IH.BenefitGroup IN (004,001,002,003) THEN 'Health Advantage Blue Classic (HMO)'
			WHEN IH.PlanIdentifier='H9699'  AND IH.BenefitGroup IN (006)			  THEN 'Health Advantage Blue Premier (HMO)'
			WHEN IH.PlanIdentifier='H4213'  AND IH.BenefitGroup IN (016,001,003,004) THEN 'BlueMedicare Value (PFFS)'
			WHEN IH.PlanIdentifier='H4213'  AND IH.BenefitGroup IN (017,001,005,006) THEN 'BlueMedicare Preferred (PFFS)'
			WHEN IH.PlanIdentifier='H3554'  AND IH.BenefitGroup IN (001,002)		  THEN 'BlueMedicare Saver Choice (PPO)'
			WHEN IH.PlanIdentifier='H3554'  AND IH.BenefitGroup IN (003,004,005,006) THEN 'BlueMedicare Value Choice (PPO)'
			WHEN IH.PlanIdentifier='H3554'  AND IH.BenefitGroup IN (007,008,009,010) THEN 'BlueMedicare Premier Choice (PPO)'
			WHEN IH.PlanIdentifier='H6158'  AND IH.BenefitGroup IN (001,002)		  THEN 'BlueMedicare Premier (PPO)'
	ELSE NULL 
	END  AS PlanType,
	CAST(mmf.q2ConsentDate AS DATE) ConsentDate
into 
	#cases
from 
	dbo.[ABCBS_MemberManagement_Form] mmf (readuncommitted)
	--logic to get active forms
	inner join [ABCBS_MMFHistory_Form] mmf_hist (readuncommitted) 
		on mmf_hist.[OriginalFormID] = mmf.[ID]
	inner join [HPAlertNote] hlan (readuncommitted) 
		on hlan.[LinkedFormID] = mmf_hist.[OriginalFormID] 
		and hlan.[LinkedFormType] = 'ABCBS_MMFHistory' 
		and	ISNULL(hlan.[IsDelete],0) != 1
	inner join dbo.[ComputedCareQueue] ccq (readuncommitted) 
		on ccq.[MVDID] = mmf.[MVDID]
	LEFT JOIN [dbo].[FinalEligibility] IH (readuncommitted) 
		ON mmf.MVDID = IH.MVDID 
		AND IsNull(IH.FakeSpanInd,'N') != 'Y' 
		and IsNull(IH.SpanVoidInd,'N') != 'Y'
		And MemberEffectiveDate Between @startDate AND @endDate
where 
--Ticket 5721
	--mmf.[q1CaseCreateDate] between @startdate and @enddate
	(mmf.q1CaseCloseDate IS NULL OR CAST(mmf.q1CaseCloseDate AS DATE) Between @startDate AND @endDate)
	and CAST(ISNULL(mmf.q2ConsentDate, mmf.q1CaseCreateDate) AS DATE) Between @startDate AND @endDate
--End 5721
	and ((@OnlyAuditable = 0) or (@OnlyAuditable = 1 and mmf.[AuditableCase] = 1))
	and ((@LOB = 'ALL') or (CHARINDEX(ccq.[LOB], @LOB) > 0))
	and ((@CmOrgRegion = 'ALL') or (CHARINDEX(ccq.[CmOrgRegion], @CmOrgRegion) > 0))
	and ((@CompanyKey = 'ALL') or (CHARINDEX(cast(ccq.[CompanyKey] as varchar(10)), @CompanyKey) > 0))
	and ((@CaseProgram = 'ALL') or (CHARINDEX(mmf.[q4CaseProgram], @CaseProgram) > 0))
	and ((@CaseManager = 'ALL') or (CHARINDEX(mmf.[q1CaseOwner], @CaseManager) > 0))
	and IsNull(mmf.[q2CloseReason],'--') != 'Void'
	--and mmf.mvdid = '16C6BC75441C8467EAB9'
	
select  distinct
	--SessionId as ID,
	r.[MVDID],
	CAST(r.[ReconDT] AS DATE) as [formdate]
	--'' as CaseID
	--'MedRec' as Asmt
into #asmt
from [dbo].[MemberRxInteractionReport] r (readuncommitted)
	inner join #cases c on r.[MVDID] = c.[MVDID] 
where 
	 r.[ReconDT] between c.[q1CaseCreateDate] and dateadd(day,@DueDays,c.[q1CaseCreateDate])
	
;WITH CPUsers AS (
		SELECT DISTINCT ID, UserName, FirstName, LastName 
			FROM AspNetUsers (readuncommitted)
	), CPUserInfo AS (
		SELECT DISTINCT UserID,Department,Supervisor 
			FROM AspNetUserInfo (readuncommitted)
	)
select distinct
	c.[CaseID], 
	c.[MemberID], 
	c.[LastName], 
	c.[FirstName], 
	c.[q1CaseOwner] as [CaseManager], 
	IsNull([q4CaseProgram],'n/a') as [CaseProgram], 
	'MedRec' as [AssessmentType],			--IsNull(a.Asmt,'n/a') as AssessmentType, 
	c.[q1CaseCreateDate] as [DateOpened],
	case When ConsentDate IS NULL THEN ''
		when DATEDIFF(day, ConsentDate, IsNull(a.[formdate],'2040-12-31')) <= @DueDays then 'Y' else 'N' end as [TimelyCompletion],
	[LOB],
	[CmOrgRegion],
	[CompanyKey],
	[CompanyName],
	dateadd(day,@DueDays,ConsentDate) as [DueDate],
	a.[FormDate] as CompletedDate,
	case when IsNull(c.[auditableCase],0) = 1 THEN 'Y' ELSE 'N' END	[Auditable],
	c.PlanType,
	c.ConsentDate,
	ANI.Supervisor
from #cases c
	left join #asmt a on a.[MVDID] = c.[MVDID] and a.FormDate >= c.[q1CaseCreateDate]
	LEFT JOIN CPusers AN ON AN.UserName = c.q1CaseOwner
	LEFT JOIN CPuserInfo ANI on AN.ID = ANI.UserID
--where c.[MemberID] = 'T0005227500'
order by 
	[CaseProgram], 
	[DueDate],
	[TimelyCompletion]


END