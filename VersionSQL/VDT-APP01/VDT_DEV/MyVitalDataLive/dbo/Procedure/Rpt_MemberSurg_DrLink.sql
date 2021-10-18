/****** Object:  Procedure [dbo].[Rpt_MemberSurg_DrLink]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[Rpt_MemberSurg_DrLink]
	@ICENUMBER varchar(15),
	@ReportType varchar(15) = null
AS

SET NOCOUNT ON

declare @temp table (
	YearDate datetime, 
	Condition varchar(50), 
	Treatment varchar(150),
	[Count] int,
	code varchar(20), 
	codingsystem varchar(50),
	CreatedBy varchar(250),
	CreatedByOrganization varchar(250),
	UpdatedBy varchar(250),
	UpdatedByOrganization varchar(250),
	UpdatedByContact varchar(64)
)


Declare @ICEGroup varchar(50),@cust_id int
Select @ICEGroup = IceGroup from [dbo].[MainICENUMBERGroups]
where IceNumber = @ICENUMBER

Create Table #IceNumbers (IceNumber varchar(50))
Insert #IceNumbers
Select IceNumber from [dbo].[MainICENUMBERGroups]
where IceGroup = @ICEGroup

select @cust_id = cust_id from Link_MVDID_CustID lc
                   where lc.MVDId = @ICENUMBER

declare @limitDate datetime

if(len(isnull(@ReportType,'')) > 0 and @ReportType = '21')
begin
	set @limitDate = DATEADD(dd,-120, getdate())
end
else
begin
	set @limitDate = '1/1/1900'
end

insert into @temp
SELECT distinct YearDate, dbo.InitCap(Condition) as Condition, Treatment,
	--(
	--	-- If history record not created return 1
	--	select case count(RecordNumber)
	--		when 0 then 1
	--		else count(RecordNumber)
	--		end
	--	from MainSurgeriesHistory sh
	--	where sh.IceNumber = s.Icenumber and sh.Code = s.Code
	--) 
	0 as [Count],
	code, codingsystem,
	ISNULL(CreatedBy,'') as CreatedBy,
	dbo.InitCap(ISNULL(CreatedByOrganization,'')) as CreatedByOrganization,
	dbo.InitCap(ISNULL(UpdatedBy,'')) as UpdatedBy,
	dbo.InitCap(ISNULL(UpdatedByOrganization,'')) as UpdatedByOrganization,
	ISNULL(UpdatedByContact,'') as UpdatedByContact
FROM MainSurgeries s
WHERE --ICENUMBER = @ICENUMBER
ICENUMBER in (Select IceNUmber From #IceNumbers)  
	AND (
		YearDate is null
		OR
		YearDate > @limitDate
	)  AND   not EXISTS (SELECT * FROM Lookup_AbuseTreatmentCodes lA WHERE RTRIM(LTRIM(lA.Treatment_Cd)) !=  REPLACE(S.code, '.', '')  and  @cust_id = '11') 


-- Don't show on the report certain procedures
delete from @temp
where 
	(codingSystem = 'CPT' and code in (select code from lookupCPTadditionalInfo where ShowOnReportDays = 0 or yeardate < dateAdd(dd,(-1) * ShowOnReportDays,getdate())) )
	OR
	(codingSystem = 'HCPCS' and code in (select code from lookupHCPCSadditionalInfo where ShowOnReportDays = 0 or yeardate < dateAdd(dd,(-1) * ShowOnReportDays,getdate())) )

select YearDate, 
	Condition, 
	Treatment,
	[Count],
	code, 
	codingsystem,
	CreatedBy,
	CreatedByOrganization,
	UpdatedBy,
	UpdatedByOrganization,
	UpdatedByContact
from @temp
ORDER BY YearDate DESC


/*
EXEC [Rpt_MemberSurg_DrLink]

@ICENUMBER = 'PF812653'

*/