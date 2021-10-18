/****** Object:  Function [dbo].[FormatPhoneExt]    Committed by VersionSQL https://www.versionsql.com ******/

create FUNCTION [dbo].[FormatPhoneExt](@Phone varchar(10), @Extension varchar(10))
RETURNS varchar(25)
AS
BEGIN

	DECLARE @Result varchar(25)
	
	SET @Result = ''

	IF @Phone IS NOT NULL AND LEN(@Phone) = 10	
		SET @Result = '(' + Substring(@Phone,1,3) + ')' + Substring(@Phone,4,3) 
			+ '-' + Substring(@Phone,7,4)
	
	if(ISNULL(@Extension,'') <> '')
	begin
		select @Result = @Result + ' ext.' + @Extension
	end
		
	RETURN @Result
END