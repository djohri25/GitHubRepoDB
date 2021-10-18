/****** Object:  Procedure [dbo].[Get_FridgeCardInfo]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[Get_FridgeCardInfo] 

	@ICENUMBER varchar(15)
AS

SET NOCOUNT ON

SELECT ICENUMBER, dbo.FullName(LastName, FirstName, MiddleName) AS FullName, DOB, 
ContactLenses = dbo.ContactLenses(ICENUMBER), Allergy = dbo.Allergies(ICENUMBER),
Gender = CASE GenderId
	WHEN 0 THEN ''
	ELSE (SELECT GenderName FROM LookupGenderID WHERE MainPersonalDetails.GenderId = LookupGenderID.GenderId)
END,
Weight = CASE WeightLbs
	WHEN NULL THEN ''
	ELSE LTRIM(STR(WeightLbs)) + ' Lbs'
END,
Height = CASE HeightInches
	WHEN NULL THEN ''
	ELSE LTRIM(STR(Floor(HeightInches/12))) + ''' ' + 
	LTRIM(STR((HeightInches - Floor(HeightInches/12)*12))) + '"'
END,
BloodType = CASE BloodTypeID
	WHEN 0 THEN ''
	ELSE (SELECT BloodTypeName FROM LookupBloodTypeID WHERE LookupBloodTypeID.BloodTypeID = MainPersonalDetails.BloodTypeID)
END,
Medication = dbo.Medication(ICENUMBER), Insurance = dbo.PriInsurance(ICENUMBER),
Policy = dbo.Policy(ICENUMBER), GroupNo = dbo.GroupNo(ICENUMBER),
PriContact1 = dbo.PriContact1(ICENUMBER), PriContact2 = dbo.PriContact2(ICENUMBER),
PriPhone1 = dbo.PriPhone1(ICENUMBER), PriPhone2 = dbo.PriPhone2(ICENUMBER),
PriPhysician = dbo.PriPhysician(ICENUMBER), PriPhyPhone = dbo.PriPhyPhone(ICENUMBER),
(SELECT SecondaryIceNumber FROM MainICENUMBERGroups	WHERE 
MainICENUMBERGroups.IceNumber = @IceNumber) AS Valet 
FROM MainPersonalDetails

WHERE ICENUMBER = @ICENUMBER