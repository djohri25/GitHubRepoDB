/****** Object:  Procedure [dbo].[Rpt_MemberRefIDs]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[Rpt_MemberRefIDs]  
--Declare  
@IceNumber varchar(15)  ,
@ReportType varchar(10) = NULL 
----------------------------------------------------------------------------------------------------  
--CreatedBy : PPetluri Date : 02/27/2018  
-- Date			Name			Comments  
-- 03/06/2018	ppetluri		Modified to include the report procs as the data was not matching to current model
----------------------------------------------------------------------------------------------------  
As  
BEGIN  
--set @ICENUMBER = 'AM768794'  
--Set @ReportType = NULL--'2'

declare @limitDate datetime
  
Drop Table IF Exists #Temp_RefID   
Create table #Temp_RefID   
(  
 RefID int identity(1,1) NOT NULL,  
 ICENUMBER varchar(30),  
 CreatedBy varchar(200),  
 CreatedByOrganization varchar(200),  
 UpdatedBy varchar(200),  
 UpdatedByOrganization varchar(200),  
 UpdatedByContact varchar(200),  
 Subreport varchar(200)  
)  

 
Drop Table IF Exists #Temp_LabRefID   
Create table #Temp_LabRefID   
(  
 RefID int identity(1,1) NOT NULL,  
 ICENUMBER varchar(30),  
 CreatedBy varchar(200),  
 CreatedByOrganization varchar(200),  
 UpdatedBy varchar(200),  
 UpdatedByOrganization varchar(200),  
 UpdatedByContact varchar(200)--,  
 --Subreport varchar(200)  
)  
  
Drop Table IF Exists #Temp_RefID_Result   
Create table #Temp_RefID_Result   
(  
 RefID int identity(1,1) NOT NULL,  
 ICENUMBER varchar(30),  
 --Ref_CreatedBy varchar(200),  
 --Ref_CreatedByOrganization varchar(200),  
 Ref_UpdatedBy varchar(200),  
 Ref_UpdatedByOrganization varchar(200),  
 Ref_UpdatedByContact varchar(200),  
 IsPharmacy bit  ,
 IsLab	bit
)  
  
Drop Table IF Exists #Temp_RxID   
Create table #Temp_RxID   
(  
 RxID int identity(1,1) NOT NULL,  
 ICENUMBER varchar(30),  
 PharmacyName varchar(200)  
)  
  
Declare @ICEGroup varchar(50)  
Select @ICEGroup = IceGroup from [dbo].[MainICENUMBERGroups]  
where IceNumber = @ICENUMBER  
  
Drop table If exists #IceNumbers  
Create Table #IceNumbers (IceNumber varchar(50))  
Insert #IceNumbers  
Select IceNumber from [dbo].[MainICENUMBERGroups]  
where IceGroup = @ICEGroup  

-- SubDisease  
INSERT INTO #Temp_RefID  
SELECT   
 distinct b.ICENUMBER,  
 dbo.InitCap(ISNULL(CreatedBy,'')) as CreatedBy,  
 dbo.InitCap(ISNULL(CreatedByOrganization,'')) as CreatedByOrganization,  
 dbo.InitCap(ISNULL(UpdatedBy,'')) as UpdatedBy,  
 dbo.InitCap(ISNULL(UpdatedByOrganization,'')) as UpdatedByOrganization,  
 dbo.InitCap(ISNULL(UpdatedByContact,'')) as UpdatedByContact,  
 'SubDisease' as SubReport  
FROM dbo.MainCondition b JOIN SectionPermission s on b.icenumber = s.icenumber   
Join MainMenuTree m on m.ID = s.SectionID  
WHERE --ICENUMBER = @IceNumber  
b.ICENUMBER in (Select IceNUmber From #IceNumbers)  and m.MenuName = 'Diseases/Conditions' and s.Ispermitted = 1   
  
-- SubAllergy  
INSERT INTO #Temp_RefID  
SELECT   
 distinct b.ICENUMBER,  
 dbo.InitCap(ISNULL(CreatedBy,'')) as CreatedBy,  
 dbo.InitCap(ISNULL(CreatedByOrganization,'')) as CreatedByOrganization,  
 dbo.InitCap(ISNULL(UpdatedBy,'')) as UpdatedBy,  
 dbo.InitCap(ISNULL(UpdatedByOrganization,'')) as UpdatedByOrganization,  
 dbo.InitCap(ISNULL(UpdatedByContact,'')) as UpdatedByContact,  
 'SubAllergy' as SubReport  
FROM dbo.MainAllergies b JOIN SectionPermission s on b.icenumber = s.icenumber   
Join MainMenuTree m on m.ID = s.SectionID  
WHERE --ICENUMBER = @IceNumber  
b.ICENUMBER in (Select IceNUmber From #IceNumbers) and m.MenuName = 'Allergies' and s.Ispermitted = 1   
  
 -- SubEmergency 
INSERT INTO #Temp_RefID  
SELECT   
 distinct b.ICENUMBER,  
 dbo.InitCap(ISNULL(CreatedBy,'')) as CreatedBy,  
 dbo.InitCap(ISNULL(CreatedByOrganization,'')) as CreatedByOrganization,  
 dbo.InitCap(ISNULL(UpdatedBy,'')) as UpdatedBy,  
 dbo.InitCap(ISNULL(UpdatedByOrganization,'')) as UpdatedByOrganization,  
 dbo.InitCap(ISNULL(UpdatedByContact,'')) as UpdatedByContact,  
 'SubEmergency' as SubReport  
FROM dbo.MainCareInfo b JOIN SectionPermission s on b.icenumber = s.icenumber   
Join MainMenuTree m on m.ID = s.SectionID  
WHERE --ICENUMBER = @IceNumber  
b.ICENUMBER in (Select IceNUmber From #IceNumbers) and m.MenuName = 'Contact List' and s.Ispermitted = 1   
  
-- SubInsurance  
INSERT INTO #Temp_RefID  
SELECT   
 distinct b.ICENUMBER,  
 dbo.InitCap(ISNULL(CreatedBy,'')) as CreatedBy,  
 dbo.InitCap(ISNULL(CreatedByOrganization,'')) as CreatedByOrganization,  
 dbo.InitCap(ISNULL(UpdatedBy,'')) as UpdatedBy,  
 dbo.InitCap(ISNULL(UpdatedByOrganization,'')) as UpdatedByOrganization,  
 dbo.InitCap(ISNULL(UpdatedByContact,'')) as UpdatedByContact,  
 'SubInsurance' as SubReport  
FROM dbo.MainInsurance b JOIN SectionPermission s on b.icenumber = s.icenumber   
Join MainMenuTree m on m.ID = s.SectionID  
WHERE --ICENUMBER = @IceNumber  
b.ICENUMBER in (Select IceNUmber From #IceNumbers) and m.MenuName = 'Insurance Policies' and s.Ispermitted = 1   

-- SubMedications
declare @tempMed table (
	typeName varchar(50),
	[StartDate] [datetime],
	[StopDate] [datetime],
	[RefillDate] [datetime],
	timesrefilled int,
	[PrescribedBy] [varchar](50),
	[RxDrug] [varchar](100) NULL,
	[RxPharmacy] [varchar](100) NULL,
	[HowMuch] [varchar](50) NULL,
	[HowOften] [varchar](50) NULL,
	[WhyTaking] [varchar](50) NULL,
	[CreatedBy] [nvarchar](250) NULL,
	[CreatedByOrganization] [varchar](250) NULL,
	[UpdatedBy] [nvarchar](250) NULL,
	[UpdatedByOrganization] [varchar](250) NULL,
	[UpdatedByContact] varchar(50),
	[ICENUMBER]	varchar(30),
	[PlanPaidAmount] decimal(18,2)
)

INSERT INTO @tempMed (typeName,	StartDate,	StopDate,RefillDate,timesrefilled,PrescribedBy,RxDrug,RxPharmacy,HowMuch,HowOften,WhyTaking,CreatedBy,CreatedByOrganization,UpdatedBy,UpdatedByOrganization,UpdatedByContact,[PlanPaidAmount])
Exec [dbo].[Rpt_MemberMedi]  @ICENUMBER = @IceNumber, @ReportType  = NULL -- @ReportType

UPDATE @tempMed
SET ICENUMBER = @IceNumber

INSERT INTO #Temp_RefID  
SELECT   
 distinct b.ICENUMBER,  
 dbo.InitCap(ISNULL(CreatedBy,'')) as CreatedBy,  
 dbo.InitCap(ISNULL(CreatedByOrganization,'')) as CreatedByOrganization,  
 dbo.InitCap(ISNULL(UpdatedBy,'')) as UpdatedBy,  
 dbo.InitCap(ISNULL(UpdatedByOrganization,'')) as UpdatedByOrganization,  
 dbo.InitCap(ISNULL(UpdatedByContact,'')) as UpdatedByContact,  
 'SubMedications' as SubReport  
FROM @tempMed b JOIN SectionPermission s on b.icenumber = s.icenumber   
Join MainMenuTree m on m.ID = s.SectionID  
WHERE --ICENUMBER = @IceNumber  
b.ICENUMBER in (Select IceNUmber From #IceNumbers) and m.MenuName = 'Medication' and s.Ispermitted = 1   

-- SubPersonal  
INSERT INTO #Temp_RefID  
SELECT   
 distinct b.ICENUMBER,  
 dbo.InitCap(ISNULL(CreatedBy,'')) as CreatedBy,  
 dbo.InitCap(ISNULL(CreatedByOrganization,'')) as CreatedByOrganization,  
 dbo.InitCap(ISNULL(UpdatedBy,'')) as UpdatedBy,  
 dbo.InitCap(ISNULL(UpdatedByOrganization,'')) as UpdatedByOrganization,  
 dbo.InitCap(ISNULL(UpdatedByContact,'')) as UpdatedByContact,  
 'SubPersonal' as SubReport  
FROM dbo.MainPersonalDetails b JOIN SectionPermission s on b.icenumber = s.icenumber   
Join MainMenuTree m on m.ID = s.SectionID  
WHERE --ICENUMBER = @IceNumber  
b.ICENUMBER in (Select IceNUmber From #IceNumbers) and m.MenuName = 'Personal Information' and s.Ispermitted = 1   
  
-- SubSurgery
declare @tempSurg table (
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
	UpdatedByContact varchar(64),
	ICENUMBER varchar(30)
)
INSERT INTO @tempSurg (YearDate, Condition, Treatment,[Count],code, codingsystem,CreatedBy,CreatedByOrganization,UpdatedBy,UpdatedByOrganization,UpdatedByContact)
Exec [dbo].[Rpt_MemberSurg] @ICENUMBER = @IceNumber, @ReportType  = NULL -- @ReportType

Update @tempSurg
Set ICENUMBER = @IceNumber

INSERT INTO #Temp_RefID  
SELECT   
 distinct b.ICENUMBER,  
 dbo.InitCap(ISNULL(CreatedBy,'')) as CreatedBy,  
 dbo.InitCap(ISNULL(CreatedByOrganization,'')) as CreatedByOrganization,  
 dbo.InitCap(ISNULL(UpdatedBy,'')) as UpdatedBy,  
 dbo.InitCap(ISNULL(UpdatedByOrganization,'')) as UpdatedByOrganization,  
 dbo.InitCap(ISNULL(UpdatedByContact,'')) as UpdatedByContact,  
 'SubSurgery' as SubReport  
FROM @tempSurg b JOIN SectionPermission s  on b.icenumber = s.icenumber 
Join MainMenuTree m on m.ID = s.SectionID  
WHERE --ICENUMBER = @IceNumber  
b.ICENUMBER in (Select IceNUmber From #IceNumbers) and m.MenuName = 'Surgeries' and s.Ispermitted = 1   


-- SubLabData
Declare @tempLab Table (
orderID		varchar(20), 
Request		varchar(300), 
RequestingPhysician	varchar(100), 
RequestDate		date, 
ICENUMBER		varchar(30), 
CreatedBy		varchar(100), 
CreatedByOrganization	varchar(100), 
UpdatedBy	varchar(100), 
UpdatedByOrganization	varchar(100), 
UpdatedByContact	varchar(100), 
SourceName	varchar(100)

)
INSERT INTO @tempLab (orderID, Request, RequestingPhysician, RequestDate, ICENUMBER, CreatedBy, CreatedByOrganization, UpdatedBy, UpdatedByOrganization, UpdatedByContact, SourceName)
exec [dbo].[Rpt_LabData] @ICENUMBER = @IceNumber, @ReportType  = NULL -- @ReportType
 
INSERT INTO #Temp_LabRefID  
SELECT   
 distinct b.ICENUMBER,  
 dbo.InitCap(ISNULL(CreatedBy,'')) as CreatedBy,  
 dbo.InitCap(ISNULL(CreatedByOrganization,'')) as CreatedByOrganization,  
 dbo.InitCap(ISNULL(UpdatedBy,'')) as UpdatedBy,  
 dbo.InitCap(ISNULL(UpdatedByOrganization,'')) as UpdatedByOrganization,  
 dbo.InitCap(ISNULL(UpdatedByContact,'')) as UpdatedByContact
FROM @tempLab   b 
WHERE --ICENUMBER = @IceNumber  
b.ICENUMBER in (Select IceNUmber From #IceNumbers) 
 

-- Pharmacy  
INSERT INTO #Temp_RxID  
SELECT   
 distinct ICENUMBER,  
 RxPharmacy  
FROM dbo.MainMedication b  
WHERE --ICENUMBER = @IceNumber  
ICENUMBER in (Select IceNUmber From #IceNumbers)  
  
 -- Final Insert for RefIDs 
INSERT INTO #Temp_RefID_Result (ICENUMBER, Ref_UpdatedBy, Ref_UpdatedByOrganization, Ref_UpdatedByContact, IsPharmacy, IsLab)  
Select ICENUMBER, Ref_UpdatedBy, Ref_UpdatedByOrganization, Ref_UpdatedByContact, IsPharmacy   , IsLab
FROM (  
Select ICENUMBER, Ref_UpdatedBy, Ref_UpdatedByOrganization, Ref_UpdatedByContact, IsPharmacy, IsLab, ROW_NUMBER() Over(Partition By ICENUMBER, Ref_UpdatedBy, Ref_UpdatedByOrganization ORDER BY LEN(Ref_UpdatedByContact) desc) as rank_val FROM (  
SELECT distinct ICENUMBER,   
    CASE WHEN (ISNULL(UpdatedBy,'') = '' and ISNULL(UpdatedByOrganization,'') = '') THEN Substring(CreatedBy+',',1, CHARINDEX(',',CreatedBy+',')-1)  
      WHEN UPPER(UpdatedBy) = 'PATIENT' then ''  
    ELSE Substring(UpdatedBy+',',1, CHARINDEX(',',UpdatedBy+',')-1) END Ref_UpdatedBy,  
    CASE WHEN (ISNULL(UpdatedBy,'') = '' and ISNULL(UpdatedByOrganization,'') = '') THEN CreatedByOrganization  
      WHEN UPPER(UpdatedBy) = 'PATIENT' then ''  
      ELSE UpdatedByOrganization END Ref_UpdatedByOrganization,  
    CASE WHEN LEN(UpdatedByContact) >= 10 then [dbo].[FormatPhone](UpdatedByContact)   
    ELSE '' END Ref_UpdatedByContact,   
    0 as IsPharmacy   , 0 as IsLab
 FROM #Temp_RefID) A ) B Where B.rank_val = 1  
 
 -- Final Insert for RxIDs 
INSERT INTO #Temp_RefID_Result (ICENUMBER, Ref_UpdatedBy, Ref_UpdatedByOrganization, Ref_UpdatedByContact, IsPharmacy, IsLab)  
Select Distinct ICENUMBER, PharmacyName as Ref_UpdatedBy, '', '', 1 as IsPharmacy, 0 as IsLab from #Temp_RxID  

-- Final Insert for Lab RefIDs
INSERT INTO #Temp_RefID_Result (ICENUMBER, Ref_UpdatedBy, Ref_UpdatedByOrganization, Ref_UpdatedByContact, IsPharmacy, IsLab)  
Select ICENUMBER, Ref_UpdatedBy, Ref_UpdatedByOrganization, Ref_UpdatedByContact, 0 as IsPharmacy, IsLab   
FROM (  
Select ICENUMBER, Ref_UpdatedBy, Ref_UpdatedByOrganization, Ref_UpdatedByContact, IsLab, ROW_NUMBER() Over(Partition By ICENUMBER, Ref_UpdatedBy, Ref_UpdatedByOrganization ORDER BY LEN(Ref_UpdatedByContact) desc) as rank_val FROM (  
SELECT distinct ICENUMBER,   
    CASE WHEN (ISNULL(UpdatedBy,'') = '' and ISNULL(UpdatedByOrganization,'') = '') THEN Substring(CreatedBy+',',1, CHARINDEX(',',CreatedBy+',')-1)  
      WHEN UPPER(UpdatedBy) = 'PATIENT' then ''  
    ELSE Substring(UpdatedBy+',',1, CHARINDEX(',',UpdatedBy+',')-1) END Ref_UpdatedBy,  
    CASE WHEN (ISNULL(UpdatedBy,'') = '' and ISNULL(UpdatedByOrganization,'') = '') THEN CreatedByOrganization  
      WHEN UPPER(UpdatedBy) = 'PATIENT' then ''  
      ELSE UpdatedByOrganization END Ref_UpdatedByOrganization,  
    CASE WHEN LEN(UpdatedByContact) >= 10 then [dbo].[FormatPhone](UpdatedByContact)   
    ELSE '' END Ref_UpdatedByContact,   
    1 as IsLab   
 FROM #Temp_LabRefID) A ) B Where B.rank_val = 1  

-- O/P  
SELECT * FROM #Temp_RefID_Result  
  
Drop table #IceNumbers  
Drop table #Temp_RefID  
Drop table #Temp_RxID  
Drop table #Temp_RefID_Result  
  
END  