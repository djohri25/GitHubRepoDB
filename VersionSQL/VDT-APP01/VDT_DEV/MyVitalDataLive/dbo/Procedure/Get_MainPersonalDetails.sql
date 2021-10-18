/****** Object:  Procedure [dbo].[Get_MainPersonalDetails]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[Get_MainPersonalDetails]  
	@ICENUMBER varchar(15),
	@Language BIT = 1,
	@EMS varchar(50) = null,
	@UserID_SSO varchar(50) = null
As
set nocount on

If Exists (Select ICENUMBER from MainPersonalDetails where ICENUMBER = @ICENUMBER)
BEGIN

	Select 
	ICENUMBER,
	LastName,
	MiddleName,
	FirstName,
	IsNull(GenderID, 0) As GenderId,
	(	
		SELECT TOP 1 
			CASE @Language
				WHEN  1 
				THEN GenderName 
				WHEN  0 
				THEN GenderNameSpanish
			END
		From LookupGenderId Where
	GenderId = IsNull(MainPersonalDetails.GenderId, 0)) 
	As GenderName,
	Substring(SSN,1,3) As SSN1,
	Substring(SSN,4,2) As SSN2,
	Substring(SSN,6,4) As SSN3,
	Substring(SSN,1,3) + '-' +	Substring(SSN,4,2) + '-' + Substring(SSN,6,4) As FullSSN,	
	DOB,
	Month(DOB) As DOBM,
	Day(DOB) As DOBD,
	Year(DOB) As DOBY,
	Address1,
	Address2,
	City,
	IsNull(State, '') As State,
	PostalCode,
	Substring(HomePhone,1,3) As HomePhoneArea,
	Substring(HomePhone,4,3) As HomePhonePrefix,
	Substring(HomePhone,7,4) As HomePhoneSuffix,
	Substring(CellPhone,1,3) As CellPhoneArea,
	Substring(CellPhone,4,3) As CellPhonePrefix,
	Substring(CellPhone,7,4) As CellPhoneSuffix,
	Substring(WorkPhone,1,3) As WorkPhoneArea,
	Substring(WorkPhone,4,3) As WorkPhonePrefix,
	Substring(WorkPhone,7,4) As WorkPhoneSuffix,
	Substring(FaxPhone,1,3) As FaxPhoneArea,
	Substring(FaxPhone,4,3) As FaxPhonePrefix,
	Substring(FaxPhone,7,4) As FaxPhoneSuffix,
	dbo.FormatPhone(HomePhone) As FullHome,
	dbo.FormatPhone(CellPhone) As FullCell,
	dbo.FormatPhone(WorkPhone) As FullWork,
	dbo.FormatPhone(FaxPhone) As FullFax,
	Email,
	IsNull(BloodTypeID, 0) As BloodTypeId,
	(Select BloodTypeName From LookupBloodTypeId Where
	BloodTypeId = IsNull(MainPersonalDetails.BloodTypeId, 0)) 
	As BloodTypeName,
	IsNull(OrganDonor, 0) As OrganDonorId,
	(SELECT TOP 1 
		CASE @Language
			WHEN  1 
				THEN OrganDonorName 
			WHEN 0 
				THEN OrganDonorNameSpanish
		END
		From LookupOrganDonorTypeID Where
	OrganDonorID = IsNull(MainPersonalDetails.OrganDonor, 0)) 
	As OrganDonorName,
	OrganDonor,
	HeightInches,
	Floor(HeightInches/12) As HeightFoot,
	(HeightInches - Floor(HeightInches/12)*12 ) As HeightInch,
	WeightLbs,
	IsNull(MaritalStatusID, 0) As MaritalStatusID,
	(
	SELECT TOP 1 
		CASE @Language
			WHEN  1 
				THEN MaritalStatusName 
			WHEN 0 
				THEN MaritalStatusNameSpanish
		END
	From LookupMaritalStatusId Where
	MaritalStatusId = IsNull(MainPersonalDetails.MaritalStatusID, 0)) 
	As MaritalStatusName,
	IsNull(EconomicStatusID, 0) as EconomicStatusID,
	(
	SELECT TOP 1 
		CASE @Language
			WHEN  1 
				THEN EconomicStatusName 
			WHEN 0 
				THEN EconomicStatusNameSpanish
		END  
	From LookupEconomicStatusId Where
	EconomicStatusId = IsNull(MainPersonalDetails.EconomicStatusId, 0)) 
	As EconomicStatusName,
	Occupation,
	Hours,
	MobileDescription = 'Personal Information',
	(Select SecondaryIceNumber From MainICENUMBERGroups
	Where MainICENUMBERGroups.IceNumber = @IceNumber) AS Valet 
	From MainPersonalDetails Where ICENUMBER = @ICENUMBER
	
	-- Record SP Log
	declare @params nvarchar(1000) = null
	set @params = LEFT('@ICENUMBER=' + ISNULL(@ICENUMBER, 'null') + ';' +
					   '@Language=' + CAST(@Language AS CHAR(1)) + ';', 1000);
	exec [dbo].[Set_StoredProcedures_Log] '[dbo].[Get_MainPersonalDetails]', @EMS, @UserID_SSO, @params

END