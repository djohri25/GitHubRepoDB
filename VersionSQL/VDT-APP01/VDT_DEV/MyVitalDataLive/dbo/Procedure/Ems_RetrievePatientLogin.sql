/****** Object:  Procedure [dbo].[Ems_RetrievePatientLogin]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[Ems_RetrievePatientLogin]
	@IceNo varchar(15),
	@IceGrp varchar(15) OUT,
	@Email varchar(50) OUT
		
AS

	SET NOCOUNT ON

	SELECT @IceGrp = ICEGROUP FROM MainICENUMBERGroups WHERE ICENUMBER = @IceNo

	SELECT @Email = UserName FROM MainUserName WHERE IceGroup = @IceGrp