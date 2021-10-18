/****** Object:  Function [dbo].[InitFirstCap]    Committed by VersionSQL https://www.versionsql.com ******/

/*
	Function capitalizes the first letter of every word in the input string.
	It makes the rest of the letters lowercase
*/

CREATE FUNCTION [dbo].[InitFirstCap] ( @InputString varchar(4000) ) 
RETURNS VARCHAR(4000)
AS
BEGIN

DECLARE @Char           CHAR(1)
DECLARE @OutputString   VARCHAR(255)

SET @OutputString = LOWER(@InputString)

SET @Char = SUBSTRING(@InputString, 1, 1)

if( len(@InputString) > 0)
begin
	select @OutputString = UPPER(@Char) + SUBSTRING(@OutputString, 2, len(@OutputString)-1)
end
else
begin 
	set @outputString = ''
end

RETURN @OutputString

END