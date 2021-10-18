/****** Object:  Procedure [dbo].[Vdt_AdminAccountPassword]    Committed by VersionSQL https://www.versionsql.com ******/

create  Procedure [dbo].[Vdt_AdminAccountPassword]	
	@Email varchar(50)
		
AS

	SET NOCOUNT ON

	SELECT Password FROM MainVTAdmin WHERE Email = @Email