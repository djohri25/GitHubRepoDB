/****** Object:  Procedure [dbo].[Delete_RecordsWithIceNumber]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[Delete_RecordsWithIceNumber] 
	@IceNumber varchar(15)
AS
BEGIN
	
	SET NOCOUNT ON;


    DELETE SubMonitoring WHERE ICENUMBER = @IceNumber

    DELETE SubFamilyHistory WHERE ICENUMBER = @IceNumber

    DELETE MainSurgeries WHERE ICENUMBER = @IceNumber

    DELETE MainSpecialist WHERE ICENUMBER = @IceNumber

    DELETE MainSocialHistory WHERE ICENUMBER = @IceNumber

    DELETE MainPlaces WHERE ICENUMBER = @IceNumber

    DELETE MainMonitoring WHERE ICENUMBER = @IceNumber

    DELETE MainMedication WHERE ICENUMBER = @IceNumber

    DELETE MainLivingArrangements WHERE ICENUMBER = @IceNumber

    DELETE MainInsurance WHERE ICENUMBER = @IceNumber

    DELETE MainImmunization WHERE ICENUMBER = @IceNumber

    DELETE MainHealthTest WHERE ICENUMBER = @IceNumber

	DELETE MainFamilyHistory WHERE ICENUMBER = @IceNumber

	DELETE MainDiseaseCond WHERE ICENUMBER = @IceNumber

	DELETE MainCareInfo WHERE ICENUMBER = @IceNumber
	
	DELETE MainAttachments WHERE ICENUMBER = @IceNumber

	DELETE MainAssistiveDevices WHERE ICENUMBER = @IceNumber

	DELETE MainAllergies WHERE ICENUMBER = @IceNumber

    DELETE MainPersonalDetails WHERE ICENUMBER = @IceNumber
    

END