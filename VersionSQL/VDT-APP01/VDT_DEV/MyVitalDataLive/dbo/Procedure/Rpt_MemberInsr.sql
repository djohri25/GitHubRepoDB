/****** Object:  Procedure [dbo].[Rpt_MemberInsr]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[Rpt_MemberInsr]

	@ICENUMBER varchar(15)
AS

SET NOCOUNT ON

declare @AssignedPCP varchar(200)

Declare @ICEGroup varchar(50)
Select @ICEGroup = IceGroup from [dbo].[MainICENUMBERGroups]
where IceNumber = @ICENUMBER

Create Table #IceNumbers (IceNumber varchar(50))
Insert #IceNumbers
Select IceNumber from [dbo].[MainICENUMBERGroups]
where IceGroup = @ICEGroup


select top 1 @AssignedPCP = dbo.FullName(LastName, FirstName,'') + ' ~ ' + dbo.FormatPhone(phone)
FROM MainSpecialist 
WHERE --ICENUMBER = @ICENUMBER 
ICENUMBER in (Select IceNUmber From #IceNumbers) 
and RoleID = 1
order by creationdate desc

SELECT  dbo.InitCap(Name) as Name, dbo.InitCap(PolicyHolderName) as PolicyHolderName, 
	PolicyNumber, dbo.FormatPhone(Phone) AS WPhone,
	(SELECT InsuranceTypeName FROM LookupInsuranceTypeID
	WHERE LookupInsuranceTypeID.InsuranceTypeID = MainInsurance.InsuranceTypeID) AS InsType,
	GroupNumber, 
	dbo.InitCap(isnull(Address1 + ' ','') + isnull(Address2,'')) as address,
	dbo.InitCap(isnull(city + ', ','')) + upper(isnull(state + ' ','')) + isnull(postal,'') as cityStateZip,
	dbo.FormatPhone(Phone) As Phone,dbo.FormatPhone(FaxPhone) As Fax, Website, Medicaid, MedicareNumber,
	EffectiveDate, TerminationDate,
	ISNULL(CreatedBy,'') as CreatedBy,
	dbo.InitCap(ISNULL(CreatedByOrganization,'')) as CreatedByOrganization,
	dbo.InitCap(ISNULL(UpdatedBy,'')) as UpdatedBy,
	dbo.InitCap(ISNULL(UpdatedByOrganization,'')) as UpdatedByOrganization,
	ISNULL(UpdatedByContact,'') as UpdatedByContact,
	@AssignedPCP as 'AssignedPCP'
FROM MainInsurance WHERE --ICENUMBER = @ICENUMBER 
ICENUMBER in (Select IceNUmber From #IceNumbers) 
ORDER BY InsuranceTypeID, TerminationDate desc