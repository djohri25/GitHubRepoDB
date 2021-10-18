/****** Object:  Procedure [dbo].[Report_CaseAge]    Committed by VersionSQL https://www.versionsql.com ******/

/*
Author:		Jose Pons
Create date:	2020-12-22
Description:	Generate data for ABCBS report 
			called Case Age Report
Ticket:		4186

Test Case:
Exec [dbo].[Report_CaseAge]
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
20210615		Scott				Add (readuncommitted) as needed
07/23/2021		Bhupinder Singh		Ticket 5717 - Add new columns Auditable and PlanType.
									Update logic for YTD to display data till yesterday only.

Report_CaseAge '01/01/2021','07/01/2021',1--8563
*/

CREATE PROCEDURE [dbo].[Report_CaseAge]
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
--	@LOB				varchar(MAX),
--	@CmOrgRegion		varchar(MAX),
--	@CompanyKey			varchar(MAX),
--	@CaseProgram		varchar(MAX),
--	@CaseManager		varchar(MAX)

--Select
--	@StartDate			= '20200101',
--	@EndDate			= '20201231',
--	@YTD				= 0,
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

	Drop Table If Exists #Cases

	select 
		mmf.[MVDID],
		mmf.[CaseID],
		ccq.[MemberID],
		ccq.[LastName],
		ccq.[FirstName],
		IsNull(mmf.[q4CaseProgram],'n/a')				[CaseProgram],
		mmf.[q1CaseCreateDate]							[CaseOpenDate],
		case 
			when isnull(mmf.[q1CaseCloseDate], '1900-01-01 00:00:00.000' ) = '1900-01-01 00:00:00.000' then null 
			else mmf.[q1CaseCloseDate] end				[CaseCloseDate],
		DateDiff( 
			day, 
			mmf.[q1CaseCreateDate], 
			ISNULL( 
				case when isnull(mmf.[q1CaseCloseDate], '1900-01-01 00:00:00.000' ) = '1900-01-01 00:00:00.000' then null else mmf.[q1CaseCloseDate] end,
				GETDATE()))								[DaysOpen],
		mmf.[q2CloseReason]								[CaseDisposition],
		ccq.[LOB],
		ccq.[CmOrgRegion],
		ccq.[CompanyKey],
		ccq.[CompanyName],
		mmf.[AuditableCase],
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
		#Cases
	from 
		dbo.ABCBS_MemberManagement_Form mmf (readuncommitted)
		--logic to get active forms
		inner join ABCBS_MMFHistory_Form mmf_hist (readuncommitted) 
			on mmf_hist.OriginalFormID = mmf.ID
		inner join HPAlertNote hlan (readuncommitted) 
			on hlan.LinkedFormID = mmf_hist.OriginalFormID 
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
		MMF.[q1CaseCreateDate] between @startdate and @enddate
		and ((@LOB = 'ALL') or (CHARINDEX(ccq.LOB, @LOB) > 0))
		and ((@CmOrgRegion = 'ALL') or (CHARINDEX(ccq.CmOrgRegion, @CmOrgRegion) > 0))
		and ((@CompanyKey = 'ALL') or (CHARINDEX(cast(ccq.CompanyKey as varchar(10)), @CompanyKey) > 0))
		and ((@CaseProgram = 'ALL') or (CHARINDEX(mmf.q4CaseProgram, @CaseProgram) > 0))
		and ((@CaseManager = 'ALL') or (CHARINDEX(MMF.q1CaseOwner, @CaseManager) > 0))
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
		iaf.[q2Score]
	from dbo.[ARBCBS_InitialAssessment_Form] iaf (readuncommitted)
		inner join	#cases c
			on iaf.[MVDID] = c.[MVDID]
				and iaf.[qCaseProgram] = c.[CaseProgram]
	--where
	--	iaf.[FormDate] between [q1CaseCreateDate] and Dateadd( day, 7, [q1CaseCreateDate] )	--Within 7 days of case opened/created
	),
	[cteInitAssmnt] as (
	--Only the first one/oldest if there are many
	select 
		[MVDID],
		LTRIM(RTRIM(REPLACE(REPLACE(REPLACE([q2Score], '[', ''), ']', ''), '"', '')))	[CaseCondition]
	from
		[cteAssmnt]
	where
		[RowNumber] = 1
	)

	select distinct
		c.[CaseID],
		c.[MemberID],
		c.[LastName],
		c.[FirstName],
		c.[CaseProgram],		
		a.[CaseCondition],
		c.[CaseOpenDate],
		c.[CaseCloseDate],
		c.[DaysOpen],
		c.[CaseDisposition],
		c.[LOB],
		c.[CmOrgRegion],
		c.[CompanyKey],
		c.[CompanyName],
		c.PlanType,
		IIF(c.[AuditableCase] = 1,'Y','N') [AuditableCase]
	from
		#Cases c
		inner join [cteInitAssmnt] a (readuncommitted)
			on a.mvdid = c.mvdid
	order by 
		c.[CaseProgram], 
		a.[CaseCondition],
		c.[CaseCloseDate] DESC

END