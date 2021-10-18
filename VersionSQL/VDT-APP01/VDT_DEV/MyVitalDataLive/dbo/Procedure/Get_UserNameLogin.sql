/****** Object:  Procedure [dbo].[Get_UserNameLogin]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[Get_UserNameLogin]
	@UserName varchar(100),
	@Password varchar(20),
	@IceNumber varchar(15) OUT,
	@IceGroup varchar(15) OUT,
	@IsReadOnly bit OUT
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @Count int
	
	SELECT @IceGroup = ICEGROUP, @IsReadOnly = IsReadOnly FROM MainUserName 
	WHERE UserName = @UserName AND Password = @Password and Active = 1

	IF @IceGroup IS NULL
	BEGIN
		SET @IceGroup = ''
		SET @IceNumber = ''
		SET @IsReadOnly = 1
	END
	ELSE
	BEGIN
		SELECT TOP 1 @IceNumber = ICENUMBER FROM MainICENUMBERGroups WHERE
		ICEGROUP = @IceGroup ORDER BY CreationDate
		IF @IceNumber IS NULL
			SET @IceNumber = ''
	END
END