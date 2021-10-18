/****** Object:  Procedure [dbo].[Report_ConsultDetail]    Committed by VersionSQL https://www.versionsql.com ******/

/*
 Author:		Jose Pons
 Create date:	2021-08-04
 Description:	Generate data for ABCBS report 
				called Consult Detail Report
 Ticket:		5703

Modified		Modified By		Details
20210804		Jose			Initial version
20210813		Jose			Change base tables to [Consult_Form] and [HPALertNote] 

*/

--DROP PROCEDURE [dbo].[Report_ConsultDetail]
CREATE PROCEDURE [dbo].[Report_ConsultDetail]
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
--	@StartDate			date			= '20210701',
--	@EndDate			date			= '20210830',
--	@YTD				bit				= 0,
--	@LOB				varchar(MAX)	= 'ALL',
--	@CmOrgRegion		varchar(MAX)	= 'ALL',
--	@CompanyKey			varchar(MAX)	= 'ALL',
--	@CaseProgram		varchar(MAX)	= 'ALL',
--	@CaseManager		varchar(MAX)	= 'ALL'



if (@YTD = 1)
begin
	set @startdate =  DATEADD(yy, DATEDIFF(yy, 0, GETDATE()), 0)
end


;with [cteCasesOpen] as (
select distinct 
	[MVDID],
	cast( [q1CaseCreateDate] as date )		[CaseCreateDate]
from 
	dbo.[ABCBS_MemberManagement_Form] (readuncommitted)
where
	isnull( [qCloseCase], '' ) = 'No'
),
[cteConsultRequest] as (
select 
	cf.[ID],
	cf.[MVDID],
	cf.[FormAuthor],
	cf.[FormDate], 
	cf.[UrgencyLevel],
	cf.[q20ConsultType],
	cf.[q23MedDirConsult],
	cf.[q22PharmaConsult],
	cf.[q24WorkConsult],
	cf.[q25SpecialityConsult],
	cf.[q33Diet],
	cf.[q30Speciality],
	cf.[q1ConsultResponseDate],
	cf.[ResponseUrgencyLevel]
from
	dbo.[HPAlertNote] hpa (readuncommitted) 
inner join
	dbo.[Consult_Form] cf (readuncommitted)
on 
	hpa.MVDID = cf.MVDID 
	and hpa.[LinkedFormType] = 'Consult'
	and hpa.LinkedFormID = cf.ID
	and	ISNULL( hpa.[IsDelete], 0) <> 1
where 
	hpa.[Note] like '%Request%' 
),
[cteConsultResponse] as (
select
	[MVDID],
	[LinkedFormID],
	[CreatedBy]
from
	dbo.[HPAlertNote] (readuncommitted) 
where 
	[LinkedFormType] = 'Consult'
	and [Note] like '%Response%' 
	and	ISNULL( [IsDelete], 0) <> 1
group by
	[MVDID],
	[LinkedFormID],
	[CreatedBy]
)
select 
	ccq.[MemberID],
	ccq.[CaseProgram],
	ccq.[CmOrgRegion],
	ccq.[LOB],
	ccq.[CompanyKey],
	ccq.[CompanyName],
	datediff( year, ccq.[DOB], cf.[FormDate] )								[MemberAge], 
	case 
		when co.[MVDID] is not null then 'Y'
		else 'N' end														[OpenCase],
	cf.[FormDate]															[ConsultDate],
	isnull( crb.[LastName]+', ', '')+isnull( crb.[FirstName], '')			[ConsultRequestedBy],
	[UrgencyLevel]															[PriorityLevel],
	ISNULL( cf.[q20ConsultType], '' )										[ConsultType],
	LTrim(Replace(Replace(Replace(  
		Case ISNULL( cf.[q20ConsultType], '' )
			When 'Medical Director' Then cf.[q23MedDirConsult]
			when 'Pharmacist' then cf.[q22PharmaConsult]
			when 'Social Worker' then cf.[q24WorkConsult]
			when 'Specialty CM' then cf.[q25SpecialityConsult]
			when 'Dietician' then cf.[q33Diet]
			when 'Dietitian' then cf.[q33Diet]
			when 'Case Management' then cf.[q30Speciality]
			Else NULL End, '[', ''), ']', ''), '"', '' ))					[ConsultReason],
	cf.[q1ConsultResponseDate]												[ConsultResponseDate],
	isnull( crf.[LastName]+', ', '')+isnull( crf.[FirstName], '')			[ConsultResponseFrom],	
	cf.[ResponseUrgencyLevel]												[ResponsePriorityLevel],
	case 
		when e.[PlanIdentifier] ='H9699' and e.[BenefitGroup] in ('004','001','002','003')	then 'Health Advantage Blue Classic (HMO)'
		when e.[PlanIdentifier] ='H9699' and e.[BenefitGroup] = '006'						then 'Health Advantage Blue Premier (HMO)'
		when e.[PlanIdentifier] ='H4213' and e.[BenefitGroup] in ('016','001','003','004')	then 'BlueMedicare Value (PFFS)'
		when e.[PlanIdentifier] ='H4213' and e.[BenefitGroup] in ('017','001','005','006')	then 'BlueMedicare Preferred (PFFS)'
		when e.[PlanIdentifier] ='H3554' and e.[BenefitGroup] in ('001','002')				then 'BlueMedicare Saver Choice (PPO)'
		when e.[PlanIdentifier] ='H3554' and e.[BenefitGroup] in ('003','004','005','006')	then 'BlueMedicare Value Choice (PPO)'
		when e.[PlanIdentifier] ='H3554' and e.[BenefitGroup] in ('007','008','009','010')	then 'BlueMedicare Premier Choice (PPO)'
		when e.[PlanIdentifier] ='H6158' and e.[BenefitGroup] in ('001','002')				then 'BlueMedicare Premier (PPO)'
		else NULL end														[PlanType]
from 	
	[cteConsultRequest] cf 
	inner join dbo.[ComputedCareQueue] ccq (readuncommitted) 
		on cf.[MVDID] = ccq.[MVDID]

	left join [dbo].[FinalEligibility] e (readuncommitted) 
		on cf.[MVDID] = e.[MVDID] 
			And IsNull(e.[FakeSpanInd],'N') <> 'Y' 
			And IsNull(e.[SpanVoidInd],'N') <> 'Y'
			And e.[MemberEffectiveDate] Between @startDate AND @endDate

	left join [AspNetIdentity].[dbo].[AspNetUsers] crb (readuncommitted)
		on cf.[FormAuthor] = crb.[username] 

	left join [cteCasesOpen] co
		on cf.[MVDID] = co.[MVDID] 
			and cast( cf.[FormDate] as date) = co.[CaseCreateDate]
	
	left join [cteConsultResponse] cr
		on cf.[MVDID] = cr.[MVDID] 
			and cf.[ID] = cr.[LinkedFormID]
	
	left join [AspNetIdentity].[dbo].[AspNetUsers] crf (readuncommitted)
		on cr.[CreatedBy] = crf.[username]
where 
	--ccq.MemberID = '02159445W00'  
	--cast( MMF.[q1CaseCreateDate] as date ) between @startdate and @enddate
	cast( cf.[FormDate] as date ) between @startdate and @enddate
	and ((@LOB = 'ALL') or (CHARINDEX(ccq.[LOB], @LOB) > 0))
	and ((@CmOrgRegion = 'ALL') or (CHARINDEX(ccq.[CmOrgRegion], @CmOrgRegion) > 0))
	and ((@CompanyKey = 'ALL') or (CHARINDEX(cast(ccq.[CompanyKey] as varchar(10)), @CompanyKey) > 0))
	--and IsNull(mmf.[q2CloseReason],'--') != 'Void'
	And ((@CaseProgram = 'ALL') Or (CHARINDEX(ccq.[CaseProgram], @CaseProgram) > 0))
	And ((@CaseManager = 'ALL') Or (CHARINDEX(ccq.[CaseOwner], @CaseManager) > 0))

--select top 1000 * 
--from dbo.[ComputedCareQueue] ccq
--inner join dbo.[Consult_Form] cf on ccq.MVDID = cf.MVDID
--where ccq.MVDID = '16004DD504ED8B1F368D'
------cf.[q20ConsultType] = 'Specialty CM'

----16003B2AB4F38BA0E4D4
----1600408FC47BAB5AE74C
----1600425584D528D6F33A
----16004417441588636581
----16004DD504ED8B1F368D

--select top 100 * from dbo.[Consult_Form] where MVDID = '16004DD504ED8B1F368D' 
--select top 100 * from dbo.[ARBCBS_Contact_Form] where MVDID = '16004DD504ED8B1F368D' order by q1ContactDate

--select top 100 * from dbo.[ABCBS_MemberManagement_Form] where MVDID = '16004DD504ED8B1F368D' 
--select top 100 * from dbo.[ABCBS_MMFHistory_Form] where MVDID = '16004DD504ED8B1F368D'


END