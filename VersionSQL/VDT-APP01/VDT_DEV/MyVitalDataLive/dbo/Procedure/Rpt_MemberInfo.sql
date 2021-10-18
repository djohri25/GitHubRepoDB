/****** Object:  Procedure [dbo].[Rpt_MemberInfo]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[Rpt_MemberInfo]

	@ICENUMBER varchar(30)
AS

-- =============================================
-- Author:		John Patrick "JP" Gregorio
-- Create date: 07/10/2019
-- Description: Find PCP Info for a specific member
-- Exec dbo.[Rpt_MemberInfo] '163565423208DC82'
-- =============================================


SET NOCOUNT ON

Select
Replace(dbo.fnFullName(c.MemberLastName, c.MemberFirstName, c.MemberMiddleName),'iii', 'III') as FullName
,DateofBirth as DOB
,c.MVDID
,c.Gender
,NULL as BloodType
,NULL as OrganDonorName
,dbo.fnFormatSSN('XXXXX' + RIGHT(SSN,4)) AS SSNFull
,dbo.fnCalAge(DateofBirth) AS Age
,c.Address1
,c.Address2 
,dbo.fnInitCap( isnull(c.Address1 + ' ','') + isnull(c.Address2,'')) as address
,c.City
,c.[State]
,c.ZipCode as PostalCode
,dbo.fnInitCap(isnull(c.City,'')) + upper(isnull(', ' + c.[State] + ' ','')) + isnull(c.ZipCode,'') as cityStateZip
,MaritalStatus
,NULL as EconomicStatus
,dbo.fnFormatPhone(HomePhone) as HPhone
,dbo.fnFormatPhone(WorkPhone) as WPhone
,NULL as CPhone
,lower(Email) as Email
,CASE ISNULL(HeightInches,'')
		WHEN '' THEN ''
		WHEN '0' THEN ''
		ELSE convert(varchar,HeightInches,10)
End as HeightInches
,CASE ISNULL(WeightLbs,'')
		WHEN '' THEN ''
		WHEN '0' THEN ''
		ELSE convert(varchar,WeightLbs,10)
End as WeightLbs
,'' as CreatedBy
,d.name as CreatedByOrganization
,'' as UpdatedBy
,d.name as UpdatedByOrganization
,'' as UpdatedByContact
,d.name as HPName
,a.MemberID as HPID
,dbo.fnFormatSSN('XXXXX' + RIGHT(SSN,4)) as SSN
,dbo.fnFullName(ProviderLastName, ProviderFirstName,'') + ' ~ ' + dbo.fnFormatPhone(rpn.ServicePhone) as 'AssignedPCP'
From dbo.FinalMember c 
Inner Join dbo.FinalEligibility a on c.mvdid=a.mvdid
Inner Join (Select MVDID, max(MemberEffectiveDate) as MemberEffectiveDate, LOB From dbo.FinalEligibility Group by MVDID, LOB) b 
on a.MVDID = b.MVDID and a.MemberEffectiveDate = b.MemberEffectiveDate and a.LOB = b.LOB
Outer Apply (Select Top 1 * From dbo.FinalProvider c where a.PCPNPI=c.NPI Order by AffiliationEffectiveDate desc) RPN
Inner Join dbo.HPCustomer d on c.CustID=d.Cust_ID
Where c.MVDID=@ICENUMBER

/*
declare @HPName varchar(50), @HPID varchar(20)
declare @AssignedPCP varchar(200)


select @HPName = c.Name, @HPID = li.InsMemberId
from Link_MVDID_CustID li 
	inner join HPCustomer c on li.Cust_ID = c.Cust_ID
where li.MVDId = @ICENUMBER

select top 1 @AssignedPCP = dbo.fnFullName(LastName, FirstName,'') + ' ~ ' + dbo.fnFormatPhone(phone)
FROM MainSpecialist 
WHERE ICENUMBER = @ICENUMBER and RoleID = 1

SELECT replace(dbo.fnFullName(LastName, FirstName, MiddleName),'iii', 'III') AS FullName, DOB, 
	ICENUMBER as MVDID,
	Gender = CASE GenderId
		WHEN 0 THEN ''
		WHEN NULL THEN ''
		ELSE (SELECT GenderName FROM LookupGenderID WHERE MainPersonalDetails.GenderId = LookupGenderID.GenderId)
	END,
	BloodType = CASE BloodTypeID
		WHEN 0 THEN ''
		WHEN NULL THEN ''
		ELSE (SELECT BloodTypeName FROM LookupBloodTypeID 
		WHERE LookupBloodTypeID.BloodTypeID = MainPersonalDetails.BloodTypeID)
	END,
	OrganDonorName = CASE ISNULL(OrganDonor,'')
		WHEN '' THEN ''
		WHEN 0 THEN ''
		ELSE 
		(
			SELECT od.OrganDonorName FROM LookupOrganDonorTypeID od  
			WHERE OrganDonorID = MainPersonalDetails.OrganDonor
		)
	END,
 	dbo.fnFormatSSN(
 		'XXXXX' + RIGHT(SSN,4)
 	) AS SSNFull, dbo.fnCalAge(DOB) AS Age,
	Address1, Address2, 
	dbo.fnInitCap( isnull(Address1 + ' ','') + isnull(Address2,'')) as address,
	City, State, PostalCode,
	dbo.fnInitCap(isnull(city,'')) + upper(isnull(', ' + state + ' ','')) + isnull(postalcode,'') as cityStateZip,
	MaritalStatus = CASE MaritalStatusID
		WHEN 0 THEN ''
		WHEN NULL THEN ''
		ELSE (SELECT MaritalStatusName FROM LookupMaritalStatusID WHERE
		LookupMaritalStatusID.MaritalStatusID = MainPersonalDetails.MaritalStatusID)
	END, 
	EconomicStatus = CASE ISNULL(EconomicStatusID,'')
		WHEN '' THEN ''
		WHEN 0 THEN ''
		ELSE 
		(
			SELECT LookupEconomicStatusID.ECONOMICSTATUSNAME FROM dbo.LookupEconomicStatusID  
			WHERE LookupEconomicStatusID.EconomicStatusID = MainPersonalDetails.EconomicStatusID
		)
	END,
	dbo.fnFormatPhone(HomePhone) As HPhone, dbo.fnFormatPhone(WorkPhone) As WPhone, dbo.fnFormatPhone(CellPhone) As CPhone,
	lower(Email) as Email, 
	CASE ISNULL(HeightInches,'')
		WHEN '' THEN ''
		WHEN '0' THEN ''
		ELSE convert(varchar,HeightInches,10)
		end as HeightInches, 
	CASE ISNULL(WeightLbs,'')
		WHEN '' THEN ''
		WHEN '0' THEN ''
		ELSE convert(varchar,WeightLbs,10)
		end as WeightLbs,
	ISNULL(CreatedBy,'') as CreatedBy,
	dbo.fnInitCap(ISNULL(CreatedByOrganization,'')) as CreatedByOrganization,
	dbo.fnInitCap(ISNULL(UpdatedBy,'')) as UpdatedBy,
	dbo.fnInitCap(ISNULL(UpdatedByOrganization,'')) as UpdatedByOrganization,
	ISNULL(UpdatedByContact,'') as UpdatedByContact,
	@HPName as HPName, @HPID as HPID,
	dbo.fnFormatSSN(
 		'XXXXX' + RIGHT(SSN,4)
 	) as SSN,
 	@AssignedPCP as 'AssignedPCP'
FROM MainPersonalDetails
WHERE ICENUMBER = @ICENUMBER

*/