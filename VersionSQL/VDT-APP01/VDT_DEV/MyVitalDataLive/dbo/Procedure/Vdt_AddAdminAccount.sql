/****** Object:  Procedure [dbo].[Vdt_AddAdminAccount]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE  Procedure [dbo].[Vdt_AddAdminAccount]
	@UserName varchar(50),
	@Email varchar(50),
	@Password varchar(50)
	
AS

	SET NOCOUNT ON

	IF NOT EXISTS (SELECT * FROM MainVTAdmin WHERE Email = @Email)
		INSERT INTO MainVTAdmin (Name, Email, Password) VALUES
		(@UserName, @Email, @Password)