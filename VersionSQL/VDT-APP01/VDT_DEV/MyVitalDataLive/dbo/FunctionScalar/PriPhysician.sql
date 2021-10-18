/****** Object:  Function [dbo].[PriPhysician]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE FUNCTION [dbo].[PriPhysician](@IceNumber varchar(15))
	RETURNS varchar(50)
AS
BEGIN

	
	DECLARE @Result varchar(50)
	
	SELECT TOP 1 @Result = dbo.FullName(LastName, FirstName, '') FROM MainSpecialist 
	WHERE ICENUMBER = @IceNumber AND RoleID = 1

	RETURN @Result
END