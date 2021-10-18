/****** Object:  Procedure [dbo].[IceMR_CheckAccount]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[IceMR_CheckAccount]
	@IceGroup varchar(10),
	@IceNumber varchar(15)
As

	SET NOCOUNT ON
	DECLARE @Count int
	SELECT @Count = COUNT(*) FROM MainICENUMBERGroups WHERE 
	ICEGROUP = @IceGroup AND ICENUMBER = @IceNumber
	IF @Count = 1
	BEGIN
		DECLARE @CountPersonal int
		SELECT @CountPersonal = COUNT(*) FROM MainPersonalDetails WHERE ICENUMBER = @IceNumber
		IF @CountPersonal = 0
			INSERT INTO MainPersonalDetails (IceNumber, CreationDate) VALUES (@IceNumber, GETUTCDATE())
	END
	SELECT @Count