/****** Object:  Function [dbo].[PriContact1]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE FUNCTION [dbo].[PriContact1](@IceNumber varchar(15))
RETURNS varchar(50)
AS
BEGIN

	
	DECLARE @Result varchar(50)
	
	SELECT TOP 1 @Result = dbo.FullName(LastName, FirstName, MiddleName) FROM MainCareInfo WHERE ICENUMBER = @IceNumber
	AND CareTypeID = 2

	IF @Result IS NULL SET @Result = ''

	RETURN @Result
END