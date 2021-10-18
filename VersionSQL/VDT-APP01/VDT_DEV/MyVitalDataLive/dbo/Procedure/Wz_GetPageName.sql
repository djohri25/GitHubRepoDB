/****** Object:  Procedure [dbo].[Wz_GetPageName]    Committed by VersionSQL https://www.versionsql.com ******/

create PROCEDURE [dbo].[Wz_GetPageName]

	@Id int

AS

BEGIN
	SET NOCOUNT ON;

	SELECT MenuName, MenuLink FROM MainMenuTree WHERE Id = @Id

END