/****** Object:  Procedure [dbo].[Vdt_GetUserProfile]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[Vdt_GetUserProfile]
	
	@IceGroup varchar(15)
AS

	SET NOCOUNT ON

	SELECT IceNumber, MainAccount, SecondaryIceNumber,
	(SELECT LastName FROM MainPersonalDetails WHERE 
	MainPersonalDetails.IceNumber = MainICENUMBERGroups.IceNumber) AS LastName,
	(SELECT FirstName FROM MainPersonalDetails WHERE 
	MainPersonalDetails.IceNumber = MainICENUMBERGroups.IceNumber) AS FirstName,
	HVUserID, HVRecordID
	FROM MainICENUMBERGroups WHERE IceGroup = @IceGroup
	ORDER BY MainAccount DESC, LastName