/****** Object:  Procedure [dbo].[Rpt_MemberSurg]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[Rpt_MemberSurg]  
 @ICENUMBER varchar(30),  
 @ReportType varchar(15) = null  
AS  
  
  -- =============================================
-- Author:		John Patrick "JP" Gregorio
-- Create date: 07/15/2019
-- Description: Find Procedures done for a specific member
-- Notes:
-- Exec dbo.[Rpt_MemberSurg] '1695536802720B68'
-- =============================================


SET NOCOUNT ON  
  
declare @temp table (  
 YearDate datetime,   
 Condition varchar(50),   
 Treatment varchar(1000),  
 [Count] int,  
 code varchar(20),   
 codingsystem varchar(50),  
 CreatedBy varchar(250),  
 CreatedByOrganization varchar(250),  
 UpdatedBy varchar(250),  
 UpdatedByOrganization varchar(250),  
 UpdatedByContact varchar(64)  
)  

 
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
SELECT distinct YearDate, dbo.fnInitCap(Condition) as Condition, Treatment,  
  
 0 as [Count],  
 code, codingsystem,  
 ISNULL(CreatedBy,'') as CreatedBy,  
 dbo.fnInitCap(ISNULL(CreatedByOrganization,'')) as CreatedByOrganization,  
 dbo.fnInitCap(ISNULL(UpdatedBy,'')) as UpdatedBy,  
 dbo.fnInitCap(ISNULL(UpdatedByOrganization,'')) as UpdatedByOrganization,  
 ISNULL(UpdatedByContact,'') as UpdatedByContact  
FROM  dbo.fnMemberProcedureHistory(@ICENUMBER)
WHERE
(  
  YearDate is null  
  OR  
  YearDate > @limitDate  
 )  

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