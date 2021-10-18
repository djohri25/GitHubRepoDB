/****** Object:  Function [dbo].[fnFormatPhone]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE FUNCTION [dbo].[fnFormatPhone](@Phone varchar(100))
RETURNS varchar(100)
AS
BEGIN

SET @Phone = LTRIM(RTRIM(@Phone))

	DECLARE @Result varchar(100)
	
	SET @Result = ''

	IF @Phone IS NOT NULL AND LEN(@Phone) = 10	
		SET @Result = '(' + Substring(@Phone,1,3) + ')' + Substring(@Phone,4,3) 
			+ '-' + Substring(@Phone,7,4)
	ELSE
	SET @Result = @Phone

	RETURN @Result
END