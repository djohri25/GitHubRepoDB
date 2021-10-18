/****** Object:  Procedure [dbo].[Vdt_UpdateAdminPassword]    Committed by VersionSQL https://www.versionsql.com ******/

create Procedure [dbo].[Vdt_UpdateAdminPassword]
	@Email varchar(50),
	@Password varchar(50)
	
AS

	SET NOCOUNT ON

	UPDATE MainVTAdmin 
	SET Password = @Password
	WHERE Email = @Email