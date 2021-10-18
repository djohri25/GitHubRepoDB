/****** Object:  Procedure [dbo].[spLoadExistingProfiles]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[spLoadExistingProfiles]
	@IceGroup varchar(15)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT ICENUMBER, (SELECT dbo.FullName(LastName, FirstName, MiddleName) FROM MainPersonalDetails 
	WHERE MainPersonalDetails.ICENUMBER = MainICENUMBERGroups.ICENUMBER) AS ProfileName
	FROM MainICENUMBERGroups WHERE ICEGROUP = @IceGroup

END