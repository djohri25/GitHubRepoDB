/****** Object:  Procedure [dbo].[Report_MedRecTurnaround180]    Committed by VersionSQL https://www.versionsql.com ******/

/*
 Author:		Mike Grover
 Create date:	2020-12-14
 Description:	Generate data for ABCBS report 
              called Med Rec Turnaround Report
 Ticket:      4070

Test Case:
EXEC [dbo].[Report_MedRecTurnaround180]
	@startdate			= '20201001',
	@enddate			= '20210531',
	@YTD				= 0,
	@OnlyAuditable		= 0,
	@LOB				= 'ALL',
	@CmOrgRegion		= 'ALL',
	@CompanyKey			= 'ALL',
	@CaseProgram		= 'ALL',
	@CaseManager		= 'ALL'
	--@DueDays			= 180


Modified		Modified By				Details
20201216		Jose Pons				Added HPAlertNote to get active forms.
										Added parameter DueDays to handle 180 days
20210122		Jose Pons				Changes per comments on ticket #4071
05/17/2021		Bhupinder Singh			Ticket 4071 - Added new columns as per requirements
05/20/2021		Bhupinder Singh	BUG - Updated to use the CaseProgram field instead of q4CaseProgram.
06/01/2021		Bhupinder Singh			The final filter in the select was looking at the CreatedAge instead of the CaseAge.
06/09/2021		Bhupinder Singh			The link to the HPAlertNote table was using the OriginalFormId instead of Id for the link.
07/21/2021		Bhupinder Singh			Ticket 5722 - Added PlanType column.

Report_MedRecTurnaround180 '05/01/2021','06/01/2021',0,1--1253
*/

CREATE PROCEDURE [dbo].[Report_MedRecTurnaround180]
@startdate			date,
@enddate			date,
@YTD				bit = 0,
@OnlyAuditable		bit = 0,
@LOB				varchar(MAX) = 'ALL',
@CmOrgRegion		varchar(MAX) = 'ALL',
@CompanyKey			varchar(MAX) = 'ALL',
@CaseProgram		varchar(MAX) = 'ALL',
@CaseManager		varchar(MAX) = 'ALL',
@DueDays			int			 = 180
AS
BEGIN

--Declare
--	@startdate			date = dateadd(dd, -180, getdate()),
--	@enddate			date = getdate(),
--	@YTD				bit = 0,
--	@OnlyAuditable		bit = 0,
--	@LOB				varchar(MAX) = 'ALL',
--	@CmOrgRegion		varchar(MAX) = 'ALL',
--	@CompanyKey			varchar(MAX) = 'ALL',
--	@CaseProgram		varchar(MAX) = 'ALL',
--	@CaseManager		varchar(MAX) = 'ALL',
--	@DueDays			int			 = 180

if (@YTD = 1)
begin
	set @startdate =  DATEADD(yy, DATEDIFF(yy, 0, GETDATE()), 0)
	set @enddate = DATEADD(dd,-1,CAST(GETDATE() AS DATE))
end

--select @startdate, @enddate

drop table if exists #cases
drop table if exists #asmt

select distinct 
	mmf.[ID], 
	mmf.[MVDID], 
	ccq.[MemberID], 
	mmf.[CaseID],
	mmf.[q1CaseCreateDate],
	mmf.[q1CaseCloseDate],
	mmf.[q1CaseOwner],
	mmf.[CaseProgram],
	mmf.[auditableCase],
	mmf.[q2CloseReason],
	ccq.[LOB],
	ccq.[CmOrgRegion],
	ccq.[CompanyKey],
	ccq.[CompanyName],
	ccq.LastName,
	ccq.FirstName,
	mmf.q2ConsentDate,
	mmf.q5CaseCategory,
	mmf.q5CaseType,
	mmf.qCaseLevel,
	CASE WHEN mmf.q1CaseCloseDate IS NULL THEN DATEDIFF(DAY, CAST(mmf.q2ConsentDate AS DATE), @EndDate)
		WHEN CAST(mmf.q1CaseCloseDate AS DATE) BETWEEN @StartDate AND @EndDate THEN DATEDIFF(DAY, CAST(mmf.q2ConsentDate AS DATE), CAST(mmf.q1CaseCloseDate AS DATE))
		ELSE 0 END	 CaseAge,
	DATEDIFF(DAY, CAST(mmf.[q1CaseCreateDate] AS DATE), GETDATE()) CreatedAge,
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
	inner join dbo.[HPAlertNote] hlan (readuncommitted) 
		on hlan.[LinkedFormID] = mmf_hist.ID 
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
	((@OnlyAuditable = 0) or (@OnlyAuditable = 1 and mmf.[AuditableCase] = 1))
	and ((@LOB = 'ALL') or (CHARINDEX(ccq.[LOB], @LOB) > 0))
	and ((@CmOrgRegion = 'ALL') or (CHARINDEX(ccq.[CmOrgRegion], @CmOrgRegion) > 0))
	and ((@CompanyKey = 'ALL') or (CHARINDEX(cast(ccq.[CompanyKey] as varchar(10)), @CompanyKey) > 0))
	and ((@CaseProgram = 'ALL') or (CHARINDEX(mmf.[CaseProgram], @CaseProgram) > 0))
	and ((@CaseManager = 'ALL') or (CHARINDEX(mmf.[q1CaseOwner], @CaseManager) > 0))
	and IsNull(mmf.[q2CloseReason],'--') != 'Void'
	
--Only open cases
--delete from #cases
--where [q1CaseCloseDate] is not null


--select 
--	*
--into 
--	#asmt
--from (
--	select distinct SessionId as ID,[MVDID],[ReconDT] as formdate,'' as CaseID,'MedRec' as Asmt
--	from [dbo].[MemberRxInteractionReport]
--	where 
--		mvdid in (select MVDID from #cases) 
--		and ReconDT between @startdate and @enddate
--) m


;with RxCount as (
	SELECT	c.MVDID,
			COUNT(*) TotalComplete
	FROM	[dbo].[MemberRxInteractionReport] r (readuncommitted)
	inner join #cases c on r.[MVDID] = c.[MVDID]
where 
	(c.q2ConsentDate IS NULL OR [ReconDT] >= CAST(c.q2ConsentDate AS Date))
group by c.MVDID
),
[RxIR] as (
--Get Rx data
select distinct 
	--r.SessionId as ID,
	r.[MVDID],
	cast([ReconDT] as date) as formdate
from [dbo].[MemberRxInteractionReport] r (readuncommitted)
	inner join #cases c on r.[MVDID] = c.[MVDID]
where 
	[ReconDT] between c.[q1CaseCreateDate] and Dateadd( dd, @DueDays, c.[q1CaseCreateDate] )
),
[Rx2] as (
--Identify 2 or more Rx
select 
	[MVDID]
from 
	[RxIR]
group by 
	MVDID
having 
	count(*) > 1
),
[RxData] as (
--Get data ready to pivot
select 
	row_number() over (
		partition by
			ir.[MVDID]
		order by
			ir.[MVDID],
			ir.[formdate] asc
		) [RowNumber],
	ir.[MVDID],
	ir.[formdate]
from [RxIR] ir
	inner join [Rx2] r on ir.[MVDID] = r.[MVDID]
)
select 
	[MVDID],
	TotalComplete,
	[1] as [RxDate1], 
	[2] as [RxDate2]
into #asmt
from (
	select 
		[formdate],
		[RowNumber],
		d.[MVDID],
		m.TotalComplete
	from 
		[RxData] d
		left join RxCount m
		on d.mvdid = m.mvdid
	) a
pivot (
	max( [formdate] )
	for [RowNumber]
		in ( [1], [2] )
) as pvt

select distinct 
	c.[CaseID], 
	c.[MemberID], 
	c.LastName,
	c.FirstName,
	c.[q1CaseOwner] as [CaseManager], 
	IsNull([CaseProgram],'n/a') as [CaseProgram], 
	c.q5CaseCategory CaseCategory,
	c.q5CaseType CaseType,
	c.qCaseLevel CaseLevel,
	c.q2ConsentDate ConsentDate,
	c.[q1CaseCreateDate] as [DateOpened], 
	c.CaseAge,
	a.TotalComplete,
	[RxDate1] as [MedRec1], 
	[RxDate2] as [MedRec2],	
	Case When a.TotalComplete >= 2 and [RxDate2] <= DateAdd(Day,180,c.[q1CaseCreateDate]) Then 'Y' else 'N' end as TwoComplete,
	[LOB],
	[CmOrgRegion],
	[CompanyKey],
	[CompanyName],
	CASE WHEN [auditableCase] = 1 THEN 'Y' ELSE 'N' END [auditableCase],
	PlanType
from #cases c
	left join #asmt a 
		on a.mvdid = c.mvdid 
--where c.[MemberID] = 'T0005227500'
where c.CaseAge >= 180
order by 
	[CaseProgram]

END