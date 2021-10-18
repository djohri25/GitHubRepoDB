/****** Object:  Procedure [dbo].[Vdt_DeleteAdminAccount]    Committed by VersionSQL https://www.versionsql.com ******/

create Procedure [dbo].[Vdt_DeleteAdminAccount]
	@Email varchar(50)
	
AS

	SET NOCOUNT ON

	DELETE MainVTAdmin WHERE Email = @Email