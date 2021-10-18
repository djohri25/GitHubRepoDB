/****** Object:  Procedure [dbo].[GenerateRandomString]    Committed by VersionSQL https://www.versionsql.com ******/

/***************************************************************************
* Created By: 
* Date:  
* Purpose: Generate a random string of given length
*
* Comments: Right now max length is SET to 100. 
*		If you specify a @charactersToUse, the bit flags get ignored.
*		All spaces are stripped from the @charactersToUse.
*		Characters can repeat. 
***************************************************************************/
CREATE procedure [dbo].[GenerateRandomString] 
	@useNumbers bit,
	@useLowerCase bit,
	@useUpperCase bit,
	@charactersToUse as varchar(100),
	@stringLength as smallint,
	@result varchar(100) OUT
AS
BEGIN
	SET NOCOUNT ON
	IF @stringLength <= 0
		RAISERROR('Cannot generate a random string of zero length.',16,1)

	DECLARE @characters varchar(100)
	DECLARE @count int

	SET @count = 0
	SET @result = ''

	-- If you specify a character set to use, the bit flags get ignored.
	IF LEN(@charactersToUse) > 0
		SET @charactersToUse = REPLACE(@charactersToUse,' ','')
	ELSE
	BEGIN
		SET @charactersToUse = ''
		IF @useNumbers = 1
			SET @charactersToUse = @charactersToUse + '0123456789'

		IF @useLowerCase = 1
			SET @charactersToUse = @charactersToUse + 'abcdefghijklmnopqrstuvwxyz'

		IF @useUpperCase = 1
			SET @charactersToUse = @charactersToUse + 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
	END

	IF LEN(@charactersToUse) = 0
		RAISERROR('Cannot use an empty character set.',16,1)

	WHILE @count < @stringLength
	BEGIN
		SET @result = @result + SUBSTRING(@charactersToUse, ABS(CHECKSUM(NEWID())) % LEN(@charactersToUse) + 1, 1)
		SET @count = @count + 1
	END
END