/****** Object:  Procedure [dbo].[Report_TaskSummary]    Committed by VersionSQL https://www.versionsql.com ******/

/*
 Author:		Jose Pons
 Create date:	2020-12-21
 Description:	Generate data for ABCBS report 
				called Task Summary Report
 Ticket:		4125

Modified		Modified By		Details
20201223		Jose Pons		Enable CompanyKey and CompanyName search using @CompanyKey
20210204		Jose Pons		Tweak [CreatedDate], [DueDate], [CompletedDate] using timeoffset (-5 hours)
20210225		Jose Pons		Add Last and First name
								Fix columns [Task] and [TaskStatus]
07/26/2021		Bhupinder Singh #5713 Added new column PlanType
10/19/2021		Bhupinder Singh #6178 Added parameter for CaseManager that is available on the front end but was not
								being used to filter the records.

Report_TaskSummary '05/01/2021','07/25/2021',0,'all','all','all','Case Manager'
*/

CREATE PROCEDURE [dbo].[Report_TaskSummary]
@StartDate			date,
@EndDate			date,
@YTD				bit = 0,
@LOB				varchar(max) = 'ALL',
@CmOrgRegion		varchar(max) = 'ALL',
@CompanyKey			varchar(max) = 'ALL',
@UserType			varchar(max) = 'ALL',
@CaseManager		varchar(max) = 'ALL'
AS
BEGIN

----For testing purposes
--Declare
--	@StartDate			date = '20200101',
--	@EndDate			date = '20201231',
--	@YTD				bit = 0,
--	@LOB				varchar(max) = 'ALL',
--	@CmOrgRegion		varchar(max) = 'ALL',
--	@CompanyKey			varchar(max) = 'ALL',
--	@UserType			varchar(1000) = 'ALL'


if (@YTD = 1)
begin
	set @startdate =  DATEADD(yy, DATEDIFF(yy, 0, GETDATE()), 0)
	set @enddate = DATEADD(dd,-1,CAST(GETDATE() AS DATE))
end

;with [cteASPUsers] as (
--Some values are not valid: FFFF-GGG012-KKK
select 
	[ID],
	[UserName] 
from 
	dbo.[AspNetUsers]
where 
	try_cast([ID] as uniqueidentifier) is not null
)
select Distinct
	t.[ID]										[TaskID],
	ccq.[MemberID],
	ccq.[LastName],
	ccq.[FirstName],
	t.[Owner],
	r.[Description]								[UserRole],
	t.[Title]									[Task],
	ts.[Label]									[TaskStatus],
	Dateadd(hh, -5, t.[CreatedDate])			[CreatedDate],
	Dateadd(hh, -5, t.[DueDate])				[DueDate],
	Dateadd(hh, -5, t.[CompletedDate])			[CompletedDate],
	tp.[Label_Desc]								[TaskPriority],
	ccq.[LOB],
	ccq.[CmOrGRegion],
	ccq.[CompanyName],
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
from dbo.[Task] t (readuncommitted)
	inner join dbo.[ComputedCareQueue] ccq (readuncommitted) 
		on t.[MVDID] = ccq.[MVDID] 

	left join [cteASPUsers] u (readuncommitted) 
		on t.[Owner] = u.[UserName]
	left join dbo.[UserRole] ur (readuncommitted) 
		on u.[id] = ur.[UserID] 
	left join dbo.[Role] r (readuncommitted)
		on ur.[RoleID] = r.[RoleID] 

	left join dbo.[Lookup_Generic_Code] ts (readuncommitted)
		on t.[StatusID] = ts.[CodeID] and ts.[CodeTypeID] = 13
	left join dbo.[Lookup_Generic_Code] tp (readuncommitted)
		on t.[PriorityID] = tp.[CodeID] and tp.[CodeTypeID] = 14
	LEFT JOIN [dbo].[FinalEligibility] IH (readuncommitted) 
		ON t.MVDID = IH.MVDID 
		AND IsNull(IH.FakeSpanInd,'N') != 'Y' 
		and IsNull(IH.SpanVoidInd,'N') != 'Y'
		And t.[CreatedDate] Between MemberEffectiveDate AND MemberTerminationDate
where
	t.[CreatedDate] between @startdate and @enddate
	and ((@LOB = 'ALL') or (CHARINDEX(ccq.[LOB], @LOB) > 0))
	and ((@CmOrgRegion = 'ALL') or (CHARINDEX(ccq.[CmOrgRegion], @CmOrgRegion) > 0))
	and ((@UserType = 'ALL') or (CHARINDEX(r.[Description], @UserType) > 0))
	--and ((@UserType = 'ALL') or r.Description IN (SELECT Item FROM dbo.SplitString(@UserType, ',')))
	and ((@CaseManager = 'ALL') or t.[Owner] IN (SELECT Item FROM dbo.SplitString(@CaseManager, ',')))
	and ((@CompanyKey = 'ALL') 
		or (CHARINDEX(cast(ccq.[CompanyKey] as varchar(10)), @CompanyKey) > 0 
			or ccq.[CompanyName] LIKE '%'+@CompanyKey+'%'))
	--and ccq.[MemberID] = 'M6162052001'
order by 
	tp.[Label_Desc], 
	Dateadd(hh, -5, t.[CompletedDate]),
	t.[Title], 
	t.[Owner]
		

--select * --Id
--from ASPNetUsers
--where USerName = 'RLCOOK'

--select *
--from UserRole --Roles
--where UserID = '00575892-4164-4D4A-BD47-9CF02C98BC88'
----union 
--select * --RoleID
--from Role
--where RoleID = '26E62ED2-7940-4AD8-B3BE-677F915C4EBB'
----Description


END