/****** Object:  Procedure [dbo].[GenerateMVDId]    Committed by VersionSQL https://www.versionsql.com ******/

/*
 * Generates a number MyVitalData ID number for the user specified by first and last name
 *	using the following structure:
 * - Initial of the first name. If not provided generate random letter
 * - Initial of the last name. If not provided generate random letter
 * - Five randomly generated numbers
 * - Checksum of the above characters
*/
CREATE PROCEDURE [dbo].[GenerateMVDId](@firstName varchar(50),@lastName varchar(50), @newID varchar(10) output)
AS
BEGIN
	SET NOCOUNT ON
	declare @randomString varchar(10)

	select @firstName = replace(@firstName,'.',''),
		@lastName = replace(@lastName,'.','')

	-- Generate random letter if firstname not provided
	if(isnull(@firstName,'') = '' OR left(@firstName,1) not between 'A' and 'Z')
	begin
		EXEC GenerateRandomString 
		  @useNumbers = 0,
		  @useLowerCase = 0,
		  @useUpperCase = 1,
		  @charactersToUse = 'ABCDEFGHJKLMNPQRSTUVWXYZ',
		  @stringLength = 1,
		  @result = @randomString output

		set @newID = @randomString
	end
	else
	begin
		-- use the first letter of the firstname
		set @newID = upper(left(@firstName,1))
	end

	-- Generate random letter if latName not provided
	if(isnull(@lastName,'')= '' OR left(@lastName,1) not between 'A' and 'Z')
	begin
		EXEC GenerateRandomString 
		  @useNumbers = 0,
		  @useLowerCase = 0,
		  @useUpperCase = 1,
		  @charactersToUse = 'ABCDEFGHJKLMNPQRSTUVWXYZ',
		  @stringLength = 1,
		  @result = @randomString output

		set @newID = @newID + @randomString
	end
	else
	begin
		-- use the first letter of the firstname
		set @newID =  @newID + upper(left(@lastName,1))
	end

	-- Generate 5 random digits
	EXEC GenerateRandomString 
	 @useNumbers = 1,
	 @useLowerCase = 0,
	 @useUpperCase = 0,
	 @charactersToUse = '0123456789',
	 @stringLength = 5,
	 @result = @randomString output

	set @newID = @newID + @randomString

	-- Add checksum
	set @newID = @newID + convert(varchar, dbo.GetChecksum(@newID))
end