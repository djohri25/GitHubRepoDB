/****** Object:  Procedure [dbo].[Vdt_GetUserAccount]    Committed by VersionSQL https://www.versionsql.com ******/

create Procedure [dbo].[Vdt_GetUserAccount]
	
	
AS

	SET NOCOUNT ON

	SELECT UserName, IceGroup, IsReadOnly, Active FROM MainUserName
	ORDER BY UserName