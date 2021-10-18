/****** Object:  Function [dbo].[FormatSSN]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE FUNCTION [dbo].[FormatSSN](@SSN varchar(9))
RETURNS varchar(13)
AS
BEGIN

	DECLARE @Result varchar(11)
	
	SET @Result = ''

	IF @SSN IS NOT NULL
		IF LEN(@SSN) = 9	
			SET @Result = Substring(@SSN,1,3) + '-' + Substring(@SSN,4,2) 
			+ '-' + Substring(@SSN,6,4)
	
	RETURN @Result
END