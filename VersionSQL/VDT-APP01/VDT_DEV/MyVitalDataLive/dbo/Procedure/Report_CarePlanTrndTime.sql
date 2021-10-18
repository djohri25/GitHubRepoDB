/****** Object:  Procedure [dbo].[Report_CarePlanTrndTime]    Committed by VersionSQL https://www.versionsql.com ******/

/*
Author:		Jose Pons
Create date:	2020-12-17
Description:	Generate data for ABCBS report 
			called Care Plan Turnaround Time Report
Ticket:		4068

Test case:
Exec [dbo].[Report_CarePlanTrndTime]
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
20210205		Jose Pons			Tweak the days range to ignore the portion time of the [q1CaseCreateDate]
20210217		Jose Pons			Add Last and First Name
05/20/2021		Bhupinder Singh		BUG - Updated to use the CaseProgram field instead of q4CaseProgram.
06/09/2021		Bhupinder Singh		BUG - Chaged the link to HPAlertNote table to use the ID column instead of OriginalFormID
20210615		Jose				Added table hint  (readuncommitted)
07/22/2021		Bhupinder Singh		Ticket 5720 - Added PlanType column.
									Updated logic to use ConsentDate instead of CaseCreatedDate as date range filter.

Report_CarePlanTrndTime '01/01/2021','01/20/2021',1
*/

CREATE PROCEDURE [dbo].[Report_CarePlanTrndTime]
@StartDate			date,
@EndDate			date,
@YTD				bit = 0,
@OnlyAuditable		bit = 0,
@LOB				varchar(MAX) = 'ALL',
@CmOrgRegion		varchar(MAX) = 'ALL',
@CompanyKey			varchar(MAX) = 'ALL',
@CaseProgram		varchar(MAX) = 'ALL',
@CaseManager		varchar(MAX) = 'ALL',
@DueDays			int			 = 7		--Deafult to 7 days due
AS
BEGIN

----For testing purposes
--Declare
--	@StartDate			date = '20200101',
--	@EndDate			date = '20201231',
--	@YTD				bit = 0,
--	@OnlyAuditable		bit = 0,
--	@LOB				varchar(MAX) = 'ALL',
--	@CmOrgRegion		varchar(MAX) = 'ALL',
--	@CompanyKey			varchar(MAX) = 'ALL',
--	@CaseProgram		varchar(MAX) = 'ALL',
--	@CaseManager		varchar(MAX) = 'ALL'


if (@YTD = 1)
begin
	set @startdate =  DATEADD(yy, DATEDIFF(yy, 0, GETDATE()), 0)
	set @enddate = DATEADD(day, -1, CAST(GETDATE() AS date))
end

print @OnlyAuditable

DROP TABLE IF EXISTS #CPusers
DROP TABLE IF EXISTS #CPuserInfo

select distinct ID, UserName, FirstName, LastName into #CPusers from AspNetUsers (readuncommitted)
select distinct UserID,Department,Supervisor into #CPuserInfo from AspNetUserInfo (readuncommitted)

	
drop table if exists #cases

select distinct
	mmf.[ID], 
	mmf.[MVDID], 
	ccq.[MemberID],
	ccq.[LastName],
	ccq.[FirstName],
	mmf.[CaseID],
	mmf.[q1CaseCreateDate],
	mmf.[q1CaseOwner],
	mmf.[CaseProgram],
	mmf.[auditableCase],
	mmf.[q2CloseReason],
	ccq.[LOB],
	ccq.[CMOrgRegion],
	ccq.[CompanyKey],
	ccq.[CompanyName],
	max( mmf.[CarePlanID] ) over (
		partition by 
			mmf.[mvdid],
			mmf.[q4CaseProgram],
			mmf.[CaseID]) [CarePlanID],
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
into 
	#cases
from 
	dbo.ABCBS_MemberManagement_Form mmf (readuncommitted)
	--logic to get active forms
	inner join ABCBS_MMFHistory_Form mmf_hist (readuncommitted) 
		on mmf_hist.OriginalFormID = mmf.ID
	inner join HPAlertNote hlan (readuncommitted) 
		on hlan.LinkedFormID = mmf_hist.ID 
		and hlan.LinkedFormType = 'ABCBS_MMFHistory' 
		and	ISNULL(hlan.IsDelete,0) != 1
	inner join dbo.ComputedCareQueue ccq (readuncommitted) 
		on ccq.MVDID = MMF.MVDID
	LEFT JOIN [dbo].[FinalEligibility] IH (readuncommitted) 
		ON mmf.MVDID = IH.MVDID 
		AND IsNull(IH.FakeSpanInd,'N') != 'Y' 
		and IsNull(IH.SpanVoidInd,'N') != 'Y'
		And MemberEffectiveDate Between @startDate AND @endDate
where 
	--CAST(MMF.[q1CaseCreateDate] AS DATE) between @startdate and @enddate
	(mmf.q1CaseCloseDate IS NULL OR CAST(mmf.q1CaseCloseDate AS DATE) Between @startDate AND @endDate)
	and CAST(ISNULL(mmf.q2ConsentDate, mmf.q1CaseCreateDate) AS DATE) Between @startDate AND @endDate
	and ((@OnlyAuditable = 0) or (@OnlyAuditable = 1 and MMF.AuditableCase = 1))
	and ((@LOB = 'ALL') or (CHARINDEX(ccq.LOB, @LOB) > 0))
	and ((@CmOrgRegion = 'ALL') or (CHARINDEX(ccq.CmOrgRegion, @CmOrgRegion) > 0))
	and ((@CompanyKey = 'ALL') or (CHARINDEX(cast(ccq.CompanyKey as varchar(10)), @CompanyKey) > 0))
	and ((@CaseProgram = 'ALL') or (CHARINDEX(mmf.CaseProgram, @CaseProgram) > 0))
	and ((@CaseManager = 'ALL') or (CHARINDEX(mmf.q1CaseOwner, @CaseManager) > 0))
	and IsNull(mmf.q2CloseReason,'--') != 'Void'



;with [cteAssmnt] as (

--Get Care Plan for Patient within 7 days of the case opened/created
select
	--c.[MVDID],
	mcp.[CarePlanID],
	mcp.[CarePlanType],
	mcp.[CaseID],
	mcp.[ActivatedDate]
	--mcp.[CreatedDate],
	--c.[q1CaseCreateDate]
from dbo.[MainCarePlanMemberIndex] mcp (readuncommitted)
	inner join	#cases c
		on 
			mcp.[CarePlanID] = c.[CarePlanID]
			--and mcp.[CarePlanType] = c.[q4CaseProgram]
			--and mcp.[CaseID] = c.[CaseID]
			and mcp.[Activated] = 1
where
	mcp.[CreatedDate] between convert(date, ISNULL(c.q2ConsentDate, c.q1CaseCreateDate) ) and Dateadd( day, 7, convert(date, ISNULL(c.q2ConsentDate, c.q1CaseCreateDate) ))	--Within 7 days of case opened/created
)

select distinct
	c.[CaseID],
	c.[MemberID],
	c.[LastName],
	c.[FirstName],
	c.[q1CaseOwner]												[CaseManager], 
	IsNull(c.[CaseProgram],'n/a')								[CaseProgram], 
	--IsNull(a.Asmt,'n/a') as AssessmentType, 
	c.[q1CaseCreateDate]										[DateOpened],
	case when IsNull(c.[auditableCase],0) = 1 THEN 'Y' ELSE 'N' END	[AuditableCase],
	DateAdd( day, 7, ISNULL(c.q2ConsentDate, c.q1CaseCreateDate))						[DueDate],
	case when a.[CaseID] IS NOT NULL THEN 'Y' ELSE 'N' END		[CarePlanCreated],
	c.[LOB],
	c.[CmOrgRegion],
	c.[CompanyKey],
	c.[CompanyName],
	dbo.GetTimelyCompletionFlag(a.ActivatedDate,c.q2ConsentDate,c.[q1CaseCreateDate],@DueDays) TimelyCompletion,
	ANI.Supervisor,
	c.PlanType
from #CPusers AN
	join #CPuserInfo ANI on AN.ID = ANI.UserID
	right join #cases c on c.q1CaseOwner = AN.UserName
	left join [cteAssmnt] a 
		on a.[CarePlanID] = c.[CarePlanID]
			and a.[CarePlanType] = c.[CaseProgram]
			and a.[CaseID] = c.[CaseID]
--where c.[MemberID] = '00388913W00'
order by 
	IsNull(c.[CaseProgram],'n/a'), 
	DateAdd( day, 7, ISNULL(c.q2ConsentDate, c.q1CaseCreateDate)), 
	case when a.[CaseID] IS NOT NULL THEN 'Y' ELSE 'N' END

END