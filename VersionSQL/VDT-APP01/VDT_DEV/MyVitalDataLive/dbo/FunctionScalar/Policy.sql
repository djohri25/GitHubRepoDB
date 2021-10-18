/****** Object:  Function [dbo].[Policy]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE FUNCTION [dbo].[Policy](@IceNumber varchar(15))
RETURNS varchar(50)
AS
BEGIN

	
	DECLARE @Result varchar(50)
	
	SELECT TOP 1 @Result = PolicyNumber FROM MainInsurance WHERE ICENUMBER = @IceNumber
	AND InsuranceTypeID = 1

	IF @Result IS NULL SET @Result = ''

	RETURN @Result
END