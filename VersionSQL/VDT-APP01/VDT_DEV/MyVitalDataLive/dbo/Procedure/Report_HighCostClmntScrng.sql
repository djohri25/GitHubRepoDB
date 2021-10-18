/****** Object:  Procedure [dbo].[Report_HighCostClmntScrng]    Committed by VersionSQL https://www.versionsql.com ******/

/*
 Author:		Jose Pons
 Create date:	2020-12-16
 Description:	Generate data for ABCBS report 
				called High Cost Claimant Screening Report
 Ticket:		4068

Modified		Modified By				Details
20210602		Jose					Optimized query adding CustID to the search
06/09/2021		Bhupinder Singh			The link to the HPAlertNote was using OriginalFormId instead of ID to get the data.
07/23/2021		Bhupinder Singh			#5712 Add new PlanType column. Change YTD logic to get data till yesterday.

Report_HighCostClmntScrng '06/02/2020','07/22/2021',1--7010
*/

CREATE PROCEDURE [dbo].[Report_HighCostClmntScrng]
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
--	@CaseManager		varchar(MAX)	='ALL' 


	DECLARE
		@CustID int = 16,
		@MaxMonId VARCHAR(6)

	if (@YTD = 1)
	begin
		set @startdate =  DATEADD(yy, DATEDIFF(yy, 0, GETDATE()), 0)
		set @enddate = DATEADD(dd,-1,CAST(GETDATE() AS DATE))
	end

	select @MaxMonId = Max(MonthID) 
	from dbo.[ComputedMemberTotalPaidClaimsRollling12] (readuncommitted)
	where [CustID] = @CustID and MonthID between LEFT(CONVERT(varchar, @StartDate,112),6) and LEFT(CONVERT(varchar, @EndDate,112),6)

	drop table if exists #cases

	select 
		--MMF.ID, 
		mmf.[MVDID], 
		mmf.[CaseID],
		ccq.[MemberID],
		ccq.[FirstName],
		ccq.[LastName],
		mmf.[ReferralDate],
		mmf.[qViableReason],
		mmf.[q1ConsentRef],
		mmf.[q6ConsentVerbal],
		mmf.[q1CaseCreateDate],
		mmf.[q1CaseOwner],
		mmf.[CaseProgram],
		mmf.[q5ConsentMemberManaged],
		--mmf.[MemberCondition],
		--mmf.[auditableCase],
		--mmf.[q2CloseReason],
		mmf.[q1CaseCloseDate],
		mmf.[AuditableCase],
		mmf.[q2ConsentDate],
		mmf.[qNoReason],
		ccq.[LOB],
		ccq.[CmOrgRegion],
		ccq.[CompanyKey],
		ccq.[CompanyName]--,
		--CASE WHEN IH.PlanIdentifier='H9699' AND IH.BenefitGroup IN (004,001,002,003) THEN 'Health Advantage Blue Classic (HMO)'
		--		WHEN IH.PlanIdentifier='H9699'  AND IH.BenefitGroup IN (006)			  THEN 'Health Advantage Blue Premier (HMO)'
		--		WHEN IH.PlanIdentifier='H4213'  AND IH.BenefitGroup IN (016,001,003,004) THEN 'BlueMedicare Value (PFFS)'
		--		WHEN IH.PlanIdentifier='H4213'  AND IH.BenefitGroup IN (017,001,005,006) THEN 'BlueMedicare Preferred (PFFS)'
		--		WHEN IH.PlanIdentifier='H3554'  AND IH.BenefitGroup IN (001,002)		  THEN 'BlueMedicare Saver Choice (PPO)'
		--		WHEN IH.PlanIdentifier='H3554'  AND IH.BenefitGroup IN (003,004,005,006) THEN 'BlueMedicare Value Choice (PPO)'
		--		WHEN IH.PlanIdentifier='H3554'  AND IH.BenefitGroup IN (007,008,009,010) THEN 'BlueMedicare Premier Choice (PPO)'
		--		WHEN IH.PlanIdentifier='H6158'  AND IH.BenefitGroup IN (001,002)		  THEN 'BlueMedicare Premier (PPO)'
		--ELSE NULL 
		--END  AS PlanType
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
		inner join dbo.ComputedCareQueue CCQ (readuncommitted) 
			on CCQ.MVDID = MMF.MVDID --190,451/0.09
		--LEFT JOIN [dbo].[FinalEligibility] IH (readuncommitted) 
		--	ON mmf.MVDID = IH.MVDID 
		--	--AND IsNull(IH.FakeSpanInd,'N') != 'Y' 
		--	--and IsNull(IH.SpanVoidInd,'N') != 'Y'
		--	And CAST(mmf.[q1CaseCreateDate] AS DATE) Between IH.MemberEffectiveDate AND IH.MemberTerminationDate --193,116/0.19
	where 
		CAST(MMF.[q1CaseCreateDate] AS Date) between @startdate and @enddate
		and ((@OnlyAuditable = 0) or (@OnlyAuditable = 1 and MMF.AuditableCase = 1))
		and ((@LOB = 'ALL') or (CHARINDEX(CCQ.LOB, @LOB) > 0))
		and ((@CmOrgRegion = 'ALL') or (CHARINDEX(CCQ.CmOrgRegion, @CmOrgRegion) > 0))
		and ((@CompanyKey = 'ALL') or (CHARINDEX(cast(CCQ.CompanyKey as varchar(10)), @CompanyKey) > 0))
		and ((@CaseProgram = 'ALL') or (CHARINDEX(MMF.CaseProgram, @CaseProgram) > 0))
		and ((@CaseManager = 'ALL') or (CHARINDEX(MMF.q1CaseOwner, @CaseManager) > 0))
		and IsNull(MMF.q2CloseReason,'--') != 'Void';
	
	with cte as (
	SELECT	C.*,
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
	FROM	#cases C
	LEFT JOIN [dbo].[FinalEligibility] IH (readuncommitted) 
			ON C.MVDID = IH.MVDID 
			AND IsNull(IH.FakeSpanInd,'N') != 'Y' 
			and IsNull(IH.SpanVoidInd,'N') != 'Y'
			And CAST(C.[q1CaseCreateDate] AS DATE) Between IH.MemberEffectiveDate AND IH.MemberTerminationDate
)

	select distinct
		c.[CmOrgRegion],
		c.[CompanyKey],
		c.[CompanyName],
		c.[MemberID],
		c.[LastName] + ', ' + c.[FirstName] [MemberName],
		tc.[TotalPaidAmount]				[TotalClaimsPaid],
		c.[ReferralDate]					[ScreenedCMDate], 
		case when IsNull(c.[qViableReason],'No') = 'No' THEN 'N' ELSE 'Y' END	[StatusScreening],
		case when IsNull(c.[q1ConsentRef],'No') = 'No' THEN 'N' ELSE 'Y' END	[SuccessfullyContactedMember],
		case when IsNull(c.[q6ConsentVerbal],'No') = 'No' THEN 'N' ELSE 'Y' END	[ConsentCaptured],
		c.[q1CaseCreateDate]				[DateOpened],
		c.[q1CaseOwner]						[CaseManager],		
		IsNull(c.[CaseProgram],'n/a')		[CaseProgram], 
		case when IsNull(c.[q5ConsentMemberManaged],'No') = 'No' THEN 'N' ELSE 'Y' END	[ChronicCondition],
		c.[q1CaseCloseDate]					[CompletedDate],
		IIF(c.[AuditableCase]=1,'Y','N')	[AuditableCase],
		c.[q2ConsentDate]					[ConsentDate],
		c.[qNoReason]						[NoConsentReason],
		c.[LOB]								[LOB],
		c.PlanType
		--case when DATEDIFF( day, q1CaseCreateDate, IsNull( [q1CaseCloseDate],'2040-12-31')) <= 7 then 'Y' else 'N' end as Completed,
	from cte c
		join dbo.[ComputedMemberTotalPaidClaimsRollling12] tc (readuncommitted) 
			on 
				tc.[MVDID] = tc.[MVDID] 
				and tc.[MemberID] = c.[MemberID]
				and tc.[CustID] = @CustID 
				and tc.MonthID= @MaxMonId 
				and IsNull(tc.HighDollarClaim,0) = 1
	order by 
		IsNull(c.[CaseProgram],'n/a'), 
		tc.[TotalPaidAmount], 
		c.[q1CaseOwner]

END