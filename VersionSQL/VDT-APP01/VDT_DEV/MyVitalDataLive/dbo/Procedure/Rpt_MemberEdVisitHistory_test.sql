/****** Object:  Procedure [dbo].[Rpt_MemberEdVisitHistory_test]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:           SW
-- Create date: 8/11/2008
-- Description:      Returns the list of ED Visit Records.
-- Parameters: 
--            @ICENUMBER - member identifier
-- exec Rpt_MemberEdVisitHistory 'JC732475', 2
-- =============================================
CREATE PROCEDURE [dbo].[Rpt_MemberEdVisitHistory_test] 
       @ICENUMBER varchar(15),
       @ReportType varchar(50) = null
AS

SET NOCOUNT ON


Declare @ICEGroup varchar(50)
Select @ICEGroup = IceGroup from [dbo].[MainICENUMBERGroups]
where IceNumber = @ICENUMBER

Create Table #IceNumbers (IceNumber varchar(50))
Insert #IceNumbers
Select IceNumber from [dbo].[MainICENUMBERGroups]
where IceGroup = @ICEGroup



declare @limitDate datetime

if(len(isnull(@ReportType,'')) > 0 and @ReportType = '21')
begin
       set @limitDate = DATEADD(mm,-6, getdate())
end
else
begin
       set @limitDate = '1/1/1900'
end

SELECT  case when source = 'EMS - Lookup' then convert(varchar(10),dbo.ConvertUTCtoEST(VisitDate),101) 
                     else convert(varchar(10),VisitDate,101)  end as VisitDate
                ,dbo.InitCap(FacilityName) as FacilityName
                ,
                CASE Source
                       when 'EMS - Lookup' then ''                          
                       else (select convert(varchar(10),a.Admit_Date,101) from [DISCHARGE_DATA_History] a where a.ID = v.id)
                     end as VisitDate2

                ,case source 
                     when 'EMS - Lookup' then ''
                     else PhysicianFirstName
                     end as PhysicianFirstName
                ,case source 
                     when 'EMS - Lookup' then ''
                     else PhysicianLastName
                     end as PhysicianLastName
                ,case source 
                     when 'EMS - Lookup' then ''
                     else dbo.InitCap(isNull(PhysicianFirstName+' ', '') + isNull(PhysicianLastName,''))
                     end as  PhysicianFullName
                ,dbo.FormatPhone(PhysicianPhone) As PhysicianPhone
                ,CASE IsHospitalAdmit
                     when '0' then 'N'
                     when '1' then 'Y'
                     END as IsHospAdmit
                ,
                     --dbo.initFirstCap(CASE Source
                     --when 'EMS - Lookup' then a.ChiefComplaint
                     --else ''
                     --end) as ChiefComplaint
                  CASE Source
                       when 'EMS - Lookup' then 
                           (select ChiefComplaint from MVD_AppRecord a where a.RecordID = v.sourceRecordID)
                       else ''
                     end as ChiefComplaint
                ,
              --   dbo.initFirstCap(CASE Source
                     --when 'EMS - Lookup' then a.EmsNote
                     --else ''
                     --end) as Notes
                     CASE Source
                       when 'EMS - Lookup' then 
                           (select EmsNote from MVD_AppRecord a where a.RecordID = v.sourceRecordID)
                       else ''
                     end as Notes
                     , source
                 ,POS = CASE POS
                     WHEN 0 THEN ''
                     WHEN NULL THEN ''
                     ELSE (SELECT Name FROM LookupPOS
                           WHERE LookupPOS.ID = v.POS)
                     END
                     ,c.Specialty
FROM EdVisitHistory v
       left join LookupNPI_Custom c on v.FacilityNPI = c.NPI
WHERE --ICENUMBER = @ICENUMBER 
ICENUMBER in (Select IceNUmber From #IceNumbers)  
       AND VisitDate > @limitDate
ORDER BY v.VisitDate desc