/****** Object:  Procedure [dbo].[Report_Referrals]    Committed by VersionSQL https://www.versionsql.com ******/

/*
 Author:		Jose Pons
 Create date:	2020-12-21
 Description:	Generate data for ABCBS report 
				called Referrals Report
 Ticket:		4145

Modified		Modified By		Details
20201223		Jose Pons		Enable CompanyKey and CompanyName search using @CompanyKey
20210225		Jose Pons		Fix dupes on the output
07/26/2021		Bhupinder Singh	Added new column PlanType.
10/15/2021		Bhupinder Singh	#6179 - Results where not being filtered by CaseManager.

Report_Referrals '01/01/2021','07/25/2021',1 --19,037
*/

CREATE PROCEDURE [dbo].[Report_Referrals]
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
--	@LOB				varchar(MAX)	= 'ALL',
--	@CmOrgRegion		varchar(MAX)	= 'ALL',
--	@CompanyKey			varchar(MAX)	= 'ALL',
--	@CaseProgram		varchar(MAX)	= 'ALL'


if (@YTD = 1)
begin
	set @startdate =  DATEADD(yy, DATEDIFF(yy, 0, GETDATE()), 0)
	set @enddate = DATEADD(dd,-1,CAST(GETDATE() AS DATE))
end

Drop Table If Exists #cases

select 
	ccq.[MemberID],
	ccq.[LastName],
	ccq.[FirstName],
	ccq.[State],
	ccq.[County],
	ccq.[RiskGroupID],
	mmf.[ReferralDate]							[ReferralDate],
	mmf.[ReferralSource]						[ReferralSource],
	mmf.[ReferralReason]						[ReferralReason],
	mmf.[ReferralOwner]							[ReferralOwner],
	mmf.[qNonViableReason1]						[NonViableReason],
	mmf.[q19AssignedUser]						[AssignedUser],
	mmf.[q1ConsentRef]							[ConsentGiven],
	mmf.[q2ConsentNonViable]					[NoConsentReason],
	CASE WHEN IsNull(mmf.q1ConsentRef,'No') = 'Yes' AND IsNull(mmf.qViableReason,'No') = 'Yes' THEN
		DateDiff( 
			day, 
			ISNULL(mmf.[ReferralDate], GetDate()), 
			ISNULL(mmf.[q1CaseCreateDate], GetDate()) ) + 1
		ELSE 0	END								[DaysToDisposition],
	IsNull(mmf.[CaseProgram],'n/a')			[CaseProgram], 
	case when IsNull(mmf.[qViableReason],'No') = 'No' THEN 'N' ELSE 'Y' END [Viable], --Y/N flag
	ccq.[LOB],
	ccq.[CmOrgRegion],
	ccq.[CompanyName],
	mmf.[q1CaseOwner],
	mmf.[auditableCase],
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
	--mmf.[CaseID],
	--mmf.[q1CaseCreateDate],
	--,
	--mmf.[q2CloseReason],
Into #cases
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
		And mmf.[q1CaseCreateDate] Between MemberEffectiveDate AND MemberTerminationDate
where 
	CAST(mmf.[ReferralDate] AS DATE) between @startdate and @enddate
	and ((@LOB = 'ALL') or (CHARINDEX(ccq.LOB, @LOB) > 0))
	and ((@CmOrgRegion = 'ALL') or (CHARINDEX(ccq.CmOrgRegion, @CmOrgRegion) > 0))
	and ((@CaseProgram = 'ALL') or (CHARINDEX(mmf.CaseProgram, @CaseProgram) > 0))
	and IsNull(mmf.q2CloseReason,'--') != 'Void'
	and ((@CompanyKey = 'ALL') 
		or (CHARINDEX(cast(ccq.[CompanyKey] as varchar(10)), @CompanyKey) > 0 
			or ccq.[CompanyName] LIKE '%'+@CompanyKey+'%'))
	--and [MemberID] = '00028277W01'
order by 
	mmf.[CaseProgram], 
	[ReferralSource], 
	[ReferralDate];

	with CPUsers as (
		select distinct ID, UserName, FirstName, LastName from AspNetUsers
	), CPUserInfo as (
		select distinct UserID,Department,Supervisor from AspNetUserInfo
	)

select distinct 
	[MemberID],
	c.[LastName],
	c.[FirstName],
	[State],
	[County],
	ISNULL([RiskGroupID], 0) [RiskScore], 
	[ReferralDate],
	[ReferralSource],
	[ReferralReason],
	[ReferralOwner],
	[NonViableReason],
	[AssignedUser],
	[ConsentGiven],
	[NoConsentReason],
	[DaysToDisposition],
	[CaseProgram], 
	[Viable], 
	[LOB],
	[CmOrgRegion],
	[CompanyName],
	ANI.Supervisor,
	[auditableCase] Auditable,
	PlanType
from CPusers AN
		join CPuserInfo ANI on AN.ID = ANI.UserID
		right join #cases c on c.q1CaseOwner = AN.UserName
where ((@CaseManager = 'ALL') or ReferralOwner IN (SELECT Item FROM dbo.SplitString(@CaseManager, ',')))
END