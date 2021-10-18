/****** Object:  Function [dbo].[GroupNo]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE FUNCTION [dbo].[GroupNo](@IceNumber varchar(15))
RETURNS varchar(50)
AS
BEGIN

	
	DECLARE @Result varchar(50)
	
	SELECT TOP 1 @Result = GroupNumber FROM MainInsurance WHERE ICENUMBER = @IceNumber
	AND InsuranceTypeID = 1

	IF @Result IS NULL SET @Result = ''

	RETURN @Result
END