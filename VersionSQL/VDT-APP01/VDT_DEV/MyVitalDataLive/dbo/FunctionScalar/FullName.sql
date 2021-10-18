/****** Object:  Function [dbo].[FullName]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE FUNCTION [dbo].[FullName](@LastName varchar(50), @FirstName varchar(50), @MiddleName varchar(50) = NULL)
RETURNS varchar(50)
AS
BEGIN
	DECLARE @FullName varchar(50)
	
	IF @FirstName IS NOT NULL AND LEN(@FirstName) = 0
		SET @FirstName = NULL
	
	IF @MiddleName IS NOT NULL AND LEN(@MiddleName) = 0
		SET @MiddleName = NULL
	
	IF @LastName IS NOT NULL AND LEN(@LastName) = 0
		SET @LastName = NULL
	
	SET @FullName = ISNULL(@LastName + ',', '') + ISNULL(' ' + @FirstName, '') + ISNULL(' ' + @MiddleName, '')
	RETURN dbo.InitCap(@FullName)
END