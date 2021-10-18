/****** Object:  Function [dbo].[RemoveLeadChars]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		sw
-- Create date: 2/10/2009
-- Description:	Removes leading characters from the string
-- =============================================
CREATE FUNCTION [dbo].[RemoveLeadChars]
(
	@inputStr varchar(max), @trimChar char
)
RETURNS varchar(max)
AS
BEGIN
	while ( substring(@inputStr,1,1) = @trimChar)
	begin
		set @inputStr = substring(@inputStr,2,len(@inputStr))
	end

	select @inputStr = LTRIM(RTRIM(@inputStr))
	-- Return the result of the function
	RETURN @inputStr

END