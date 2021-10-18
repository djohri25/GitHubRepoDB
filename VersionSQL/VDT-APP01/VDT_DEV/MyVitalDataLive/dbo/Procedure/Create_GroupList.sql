/****** Object:  Procedure [dbo].[Create_GroupList]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[Create_GroupList]

	@IceGroup varchar(15)

AS

BEGIN
	SET NOCOUNT ON;

	SELECT ICENUMBER, (SELECT dbo.FullName(LastName, FirstName, MiddleName) FROM MainPersonalDetails 
	WHERE MainPersonalDetails.ICENUMBER = MainICENUMBERGroups.ICENUMBER) AS ProfileName, HVUserID, HVRecordID	
	FROM MainICENUMBERGroups WHERE ICEGROUP = @IceGroup

END