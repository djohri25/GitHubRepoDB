/****** Object:  Procedure [dbo].[Vdt_GetAccount]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[Vdt_GetAccount]
	@Email varchar(50),
	@Password varchar(50)
	
	
AS

	SET NOCOUNT ON

	DECLARE @Count int

	SELECT @Count = COUNT(*) FROM MainVtAdmin WHERE Email = @Email AND Password = @Password

	-- Log Last Time Logon
	IF @Count = 1
		UPDATE MainVtAdmin SET LastLogin = GETUTCDATE() WHERE Email = @Email		

	SELECT @Count