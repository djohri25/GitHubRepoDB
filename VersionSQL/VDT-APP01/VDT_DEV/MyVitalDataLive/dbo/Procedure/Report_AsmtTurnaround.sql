/****** Object:  Procedure [dbo].[Report_AsmtTurnaround]    Committed by VersionSQL https://www.versionsql.com ******/

/*
Author:		Mike Grover
Create date: 2020-12-14
Description:	Generate data for ABCBS report 
              called Assessment Turnaround Report
Ticket:      4081

EXEC Report_AsmtTurnaround '2020-06-02','2021-06-30',0,1,'ALL','ALL','ALL','ALL','ALL'--0:37/15,679

Modified		Modified By		Details
12/15/2020		Sunil Nokku		Added HPAlertNote to get active forms.
20201223		Jose Pons		Added DISTINCT to output
								Enable CompanyKey and CompanyName search using @CompanyKey
05/13/2021		Bhupinder Singh	Ticket 4081 - Added new columns and function to determine TimelyCompletion
05/20/2021		Bhupinder Singh	BUG - Updated to use the CaseProgram field instead of q4CaseProgram.
06/02/2021		Bhupinder Singh	Ticket 5475 - Added Supervisor in output for the Assessment Dashboard filter.
20210615		Jose			Added table hint  (readuncommitted)
07/22/2021		Bhupinder Singh	Ticket 5719 - Added PlanType Column.
								Updated logic to use the ConsentDate instead of CaseCreatedDate for date range filter.
*/

CREATE  PROCEDURE [dbo].[Report_AsmtTurnaround]
	@startdate date,
	@enddate date,
	@YTD bit = 0,
	@OnlyAuditable bit = 0,
	@LOB varchar(MAX) = 'ALL',
	@CmOrgRegion varchar(MAX) = 'ALL',
	@CompanyKey varchar(MAX) = 'ALL',
	@CaseProgram varchar(MAX) = 'ALL',
	@CaseManager varchar(MAX) = 'ALL'

AS
BEGIN

----For testing purposes
--Declare
--	@startdate date,
--	@enddate date,
--	@YTD bit = 0,
--	@OnlyAuditable bit = 0,
--	@LOB varchar(MAX) = 'ALL',
--	@CmOrgRegion varchar(MAX) = 'ALL',
--	@CompanyKey varchar(MAX) = 'ALL',
--	@CaseProgram varchar(MAX) = 'ALL',
--	@CaseManager varchar(MAX) = 'ALL'

--select
--	@startdate = '20201001',
--	@enddate = '20201031',
--	@YTD = 0,
--	@OnlyAuditable = 0,
--	@LOB = 'ALL',
--	@CmOrgRegion = 'ALL',
--	@CompanyKey = 'ALL',
--	@CaseProgram = 'ALL',
--	@CaseManager = 'ALL'


	if (@YTD = 1)
	begin
		set @startdate =  DATEADD(yy, DATEDIFF(yy, 0, GETDATE()), 0)
		set @enddate = DATEADD(dd,-1,CAST(GETDATE() AS DATE))
	end
	
	drop table if exists #cases

	select distinct 
		mmf.[ID], 
		mmf.[MVDID], 
		mmf.[CaseID],
		mmf.[q1CaseCreateDate],
		mmf.[q1CaseOwner],
		mmf.[CaseProgram],
		mmf.[auditableCase],
		mmf.[q2CloseReason],
		ccq.[LOB],
		ccq.[CmOrgRegion],
		ccq.[CompanyName],
		mmf.q2ConsentDate,
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
	into #cases
	from dbo.[ABCBS_MemberManagement_Form] mmf (readuncommitted)
	--logic to get active forms
	inner join dbo.[ABCBS_MMFHistory_Form] mmf_hist (readuncommitted) 
		on mmf_hist.OriginalFormID = mmf.ID
	inner join dbo.[HPAlertNote] hlan (readuncommitted) 
		on hlan.LinkedFormID = mmf_hist.ID 
			and hlan.LinkedFormType = 'ABCBS_MMFHistory' 
			and	ISNULL(hlan.IsDelete,0) != 1
	join dbo.[ComputedCareQueue] ccq (readuncommitted) 
		on ccq.MVDID = mmf.MVDID
	LEFT JOIN [dbo].[FinalEligibility] IH (readuncommitted) 
		ON mmf.MVDID = IH.MVDID 
		AND IsNull(IH.FakeSpanInd,'N') != 'Y' 
		and IsNull(IH.SpanVoidInd,'N') != 'Y'
		And MemberEffectiveDate Between @startDate AND @endDate
	where --CAST(mmf.[q1CaseCreateDate] AS DATE) between @startdate and @enddate
		(mmf.q1CaseCloseDate IS NULL OR CAST(mmf.q1CaseCloseDate AS DATE) Between @startDate AND @endDate)
		and CAST(ISNULL(mmf.q2ConsentDate, mmf.q1CaseCreateDate) AS DATE) Between @startDate AND @endDate
		and ((@OnlyAuditable = 0) or (@OnlyAuditable = 1 and mmf.AuditableCase = 1))
		and ((@LOB = 'ALL') or (CHARINDEX(CCQ.LOB, @LOB) > 0))
		and ((@CmOrgRegion = 'ALL') or (CHARINDEX(CCQ.CmOrgRegion, @CmOrgRegion) > 0))
		and ((@CaseProgram = 'ALL') or (CHARINDEX(MMF.CaseProgram, @CaseProgram) > 0))
		and ((@CaseManager = 'ALL') or (CHARINDEX(MMF.q1CaseOwner, @CaseManager) > 0))
		and IsNull(mmf.q2CloseReason,'--') != 'Void'
		and ((@CompanyKey = 'ALL') 
			or (CHARINDEX(cast(ccq.[CompanyKey] as varchar(10)), @CompanyKey) > 0 
				or ccq.[CompanyName] LIKE '%'+@CompanyKey+'%'))
		
	drop table if exists #asmt
	
	select *
	into #asmt
	from (
		select f.ID, f.MVDID,f.formdate, f.caseid,'Initial' as Asmt
		from [dbo].[ARBCBS_InitialAssessment_Form] f (readuncommitted)
		inner join HPAlertNote hlan (readuncommitted) 
			on hlan.linkedformid = f.ID 
			and hlan.LinkedFormType = 'ARBCBS_InitialAssessment'
			and ISNULL(hlan.IsDelete,0) != 1
		inner join #cases c 
			on f.MVDID = c.MVDID
		where CAST(formdate AS DATE) >= CAST(c.q2ConsentDate AS DATE)
		union
		select f.ID, f.MVDID,f.formdate, f.caseid,'Maternity Enrollment' as Asmt
		from [dbo].[ABCBS_MaternityEnrollment_Form] f (readuncommitted)
		inner join HPAlertNote hlan (readuncommitted) 
			on hlan.linkedformid = f.ID 
			and hlan.LinkedFormType = 'ABCBS_MaternityEnrollment'
			and ISNULL(hlan.IsDelete,0) != 1
		inner join #cases c 
			on f.MVDID = c.MVDID
		where CAST(formdate AS DATE) >= CAST(c.q2ConsentDate AS DATE)
		) m;

	with CPUsers as (
		select distinct ID, UserName, FirstName, LastName from AspNetUsers (readuncommitted)
	), CPUserInfo as (
		select distinct UserID,Department,Supervisor from AspNetUserInfo (readuncommitted)
	)
	select  
		c.[CaseID], 
		M.MemberID,
		c.[q1CaseOwner] as [CaseManager], 
		IsNull([CaseProgram],'n/a') as [CaseProgram], 
		IsNull(a.[Asmt],'n/a') as [AssessmentType], 
		c.[q1CaseCreateDate] as [DateOpened],
		case when DATEDIFF(day,CAST(c.q2ConsentDate AS DATE),IsNull(a.[formdate],'2040-12-31')) <= 7 
			then 'Y' 
			else 'N' 
			end as [Completed],
		c.[LOB],
		c.[CmOrgRegion],
		[CompanyName],
		dateadd(day,7,CAST(c.q2ConsentDate AS DATE)) as [DueDate],
		MAX(a.[FormDate]) as [CompletedDate],
		c.q2ConsentDate ConsentDate,
		M.MemberFirstName FirstName,
		M.MemberLastName LastName,
		IIF(c.AuditableCase = 1,'Y','N') Auditable,
		dbo.GetTimelyCompletionFlag(a.FormDate,c.q2ConsentDate,c.[q1CaseCreateDate],7) TimelyCompletion,
		ANI.Supervisor,
		c.PlanType
	from CPusers AN
		join CPuserInfo ANI on AN.ID = ANI.UserID
		right join #cases c on c.q1CaseOwner = AN.UserName
		left join #asmt a 
			on a.[mvdid] = c.[mvdid]
		join FinalMember M
		on c.MVDID = M.MVDID
	group by c.[CaseID], 
		M.MemberID,
		c.[q1CaseOwner], 
		IsNull([CaseProgram],'n/a'), 
		IsNull(a.[Asmt],'n/a'), 
		c.[q1CaseCreateDate],
		case when DATEDIFF(day,CAST(c.q2ConsentDate AS DATE),IsNull(a.[formdate],'2040-12-31')) <= 7 
			then 'Y' 
			else 'N' 
			end,
		c.[LOB],
		c.[CmOrgRegion],
		[CompanyName],
		dateadd(day,7,CAST(c.q2ConsentDate AS DATE)),
		c.q2ConsentDate,
		M.MemberFirstName,
		M.MemberLastName,
		IIF(c.AuditableCase = 1,'Y','N'),
		dbo.GetTimelyCompletionFlag(a.FormDate,c.q2ConsentDate,c.[q1CaseCreateDate],7),
		ANI.Supervisor,
		c.PlanType
	order by 
		[CaseProgram], 
		dateadd(day,7,CAST(c.q2ConsentDate AS DATE)),
		[Completed]

END