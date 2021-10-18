/****** Object:  Procedure [dbo].[IceMR_GetLoginAccount]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[IceMR_GetLoginAccount]
	@UserName varchar(50) OUT,
	@Password varchar(50) OUT,
	@IceGroup varchar(15)
	
As

	SET NOCOUNT ON
	
	SELECT @UserName = UserName, @Password = Password FROM MainUserName
	WHERE ICEGROUP = @IceGroup
	IF @UserName IS NULL
	BEGIN
		SET @UserName = ''
		SET @Password = ''
	END