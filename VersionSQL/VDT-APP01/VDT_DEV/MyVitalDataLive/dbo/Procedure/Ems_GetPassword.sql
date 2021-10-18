/****** Object:  Procedure [dbo].[Ems_GetPassword]    Committed by VersionSQL https://www.versionsql.com ******/

create Procedure [dbo].[Ems_GetPassword]
	@Email varchar(50)
	
AS

	SET NOCOUNT ON

	SELECT Password FROM MainEMS WHERE Email = @Email