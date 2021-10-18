/****** Object:  Procedure [dbo].[Report_ConsultCount]    Committed by VersionSQL https://www.versionsql.com ******/

/*
 Author:		Jose Pons
 Create date:	2020-12-21
 Description:	Generate data for ABCBS report 
				called Consult Count Report
 Ticket:		4124

Modified		Modified By		Details
20210603		Jose			Tweak date range condition
20210604		Jose			Remove mmf_hist dupes
20210607		Jose			Remove next tables from the query: 
									dbo.[ABCBS_MemberManagement_Form] mmf (readuncommitted)
									inner join dbo.[ABCBS_MMFHistory_Form] mmf_hist (readuncommitted) 
									inner join dbo.[HPAlertNote] hlan (readuncommitted) 
20210824		Bhupinder		#5993 - Added SplitString function to filter on Company key.
*/

CREATE PROCEDURE [dbo].[Report_ConsultCount]
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
--	@StartDate			date			= '20210601',
--	@EndDate			date			= '20210606',
--	@YTD				bit				= 0,
--	@LOB				varchar(MAX)	= 'ALL',
--	@CmOrgRegion		varchar(MAX)	= 'ALL',
--	@CompanyKey			varchar(MAX)	= 'ALL'



if (@YTD = 1)
begin
	set @startdate =  DATEADD(yy, DATEDIFF(yy, 0, GETDATE()), 0)
end

Drop Table If Exists #Forms

select --distinct
	--ccq.[MVDID],
	--ccq.[MemberID],
	----mmf_hist.[OriginalFormID],
	ccq.[LOB],
	ccq.[CmOrgRegion],
	ccq.[CompanyKey],
	ccq.[CompanyName],
	ISNULL( cf.[q20ConsultType], '' )	[ConsultType]		--Medical Director/ Pharmacist/ Social Worker/ Specialty CM/ Dietician/ Case Management
into
	#Forms
from 
	--dbo.[ABCBS_MemberManagement_Form] mmf (readuncommitted)
	----logic to get active forms
	--inner join dbo.[ABCBS_MMFHistory_Form] mmf_hist (readuncommitted) 
	--	on mmf_hist.[OriginalFormID] = mmf.[ID]
	--inner join dbo.[HPAlertNote] hlan (readuncommitted) 
	--	on hlan.[LinkedFormID] = mmf_hist.[OriginalFormID] 
	--	and hlan.[LinkedFormType] = 'ABCBS_MMFHistory' 
	--	and	ISNULL(hlan.[IsDelete],0) != 1
	
	dbo.[Consult_Form] cf (readuncommitted)
	inner join dbo.[ComputedCareQueue] ccq (readuncommitted) 
		on cf.[MVDID] = ccq.[MVDID]
where 
	--cast( MMF.[q1CaseCreateDate] as date ) between @startdate and @enddate
	cast( cf.[FormDate] as date ) between @startdate and @enddate
	and ((@LOB = 'ALL') or (CHARINDEX(ccq.[LOB], @LOB) > 0))
	and ((@CmOrgRegion = 'ALL') or (CHARINDEX(ccq.[CmOrgRegion], @CmOrgRegion) > 0))
	--and ((@CompanyKey = 'ALL') or (CHARINDEX(cast(ccq.[CompanyKey] as varchar(10)), @CompanyKey) > 0))
	and ((@CompanyKey = 'ALL') or cast(ccq.[CompanyKey] as varchar(10)) IN (SELECT Item FROM dbo.SplitString(@CompanyKey, ',')))
	--and IsNull(mmf.[q2CloseReason],'--') != 'Void'
	--and MemberID = 'R5768718002'



--Run counts
select
	[LOB],
	[CmOrgRegion],
	[CompanyKey],
	[CompanyName],
	sum(Case 
		when [ConsultType] = 'Medical Director' then 1	
		else 0 end)				[MDConsults],
	sum(Case 
		when [ConsultType] = 'Pharmacist' then 1	
		else 0 end)				[PharmacyConsults],
	sum(Case 
		when [ConsultType] = 'Social Worker' then 1	
		else 0 end)				[SocialWorkConsults],
	sum(Case 
		when [ConsultType] = 'Specialty CM' then 1	
		else 0 end)				[SpecialtyCMConsults],
	sum(Case 
		when [ConsultType] in ( 'Dietician', 'Dietitian' ) then 1	
		else 0 end)				[DieticianConsults],
	sum(Case 
		when [ConsultType] = 'Case Management' then 1 
		else 0 end)				[CMConsults]
from
	#Forms
group by
	[LOB],
	[CmOrgRegion],
	[CompanyKey],
	[CompanyName]
order by 
	[LOB],
	[CmOrgRegion],
	[CompanyKey]

END