/****** Object:  Procedure [dbo].[Get_CardInfo]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		
-- Create date: 
-- Description:	Returns information displayed on member's Card
-- =============================================
CREATE PROCEDURE [dbo].[Get_CardInfo] 
	@ICENUMBER varchar(15)
AS

SET NOCOUNT ON

SELECT ICENUMBER,dbo.FullName(LastName, FirstName, MiddleName) AS FullName, DOB, 
	dbo.initCap( isnull(Address1 + ' ','') + isnull(Address2,'')) as AddLn1, 
	dbo.initCap(isnull(City + ' ','')) + isnull(State + ' ','') + isnull(PostalCode + ' ','') as AddLn2,
	ContactLenses = dbo.ContactLenses(ICENUMBER), Allergy = dbo.Allergies(ICENUMBER),
	Gender = CASE GenderId
		WHEN 0 THEN ''
		ELSE (SELECT GenderName FROM LookupGenderID 
			WHERE MainPersonalDetails.GenderId = LookupGenderID.GenderId)
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
		ELSE (SELECT BloodTypeName FROM LookupBloodTypeID 
			WHERE LookupBloodTypeID.BloodTypeID = MainPersonalDetails.BloodTypeID)
	END,
	Medication = dbo.Medication(ICENUMBER), Conditions = dbo.Conditions(ICENUMBER), 
	Insurance = dbo.initCap( dbo.PriInsurance(ICENUMBER)),
	Policy = dbo.Policy(ICENUMBER), GroupNo = dbo.GroupNo(ICENUMBER),
	PriContact1 = dbo.PriContact1(ICENUMBER), PriContact2 = dbo.PriContact2(ICENUMBER),
	PriPhone1 = dbo.PriPhone1(ICENUMBER), PriPhone2 = dbo.PriPhone2(ICENUMBER),
	PriPhysician = dbo.PriPhysician(ICENUMBER), PriPhyPhone = dbo.PriPhyPhone(ICENUMBER),
	(SELECT SecondaryIceNumber FROM MainICENUMBERGroups	
		WHERE MainICENUMBERGroups.IceNumber = @IceNumber) AS Valet,
	dbo.Get_PrimaryContactName(ICENUMBER) as PrimContactName,
	dbo.Get_PrimaryContactPhone(ICENUMBER) as PrimContactPhone,
	dbo.HasAllergies(ICENUMBER) as hasAllergies,
	dbo.HasMedications(ICENUMBER) as hasMedications,
	dbo.HasConditions(ICENUMBER) as hasConditions,
	dbo.HasSurgeries(ICENUMBER) as hasSurgeries,
	year(creationdate) as memberSince,
	modifydate LastUpdate
FROM MainPersonalDetails
WHERE ICENUMBER = @ICENUMBER