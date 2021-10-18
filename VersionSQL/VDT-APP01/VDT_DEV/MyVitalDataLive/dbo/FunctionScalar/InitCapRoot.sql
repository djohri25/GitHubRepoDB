/****** Object:  Function [dbo].[InitCapRoot]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		Tim Thein
-- Create date: 05/13/2010
-- Description:	Function capitalizes the first letter of every word in the input string
--              and lowers the case on the rest of the string.  Other arguments provide
--              exceptions to the function.
-- =============================================
CREATE FUNCTION [dbo].[InitCapRoot] 
(
	@input nvarchar(4000),
	-- Words meant to be all uppercase
	@allCaps nvarchar(100),
	-- Words meant to be all lowercase
	@noCaps nvarchar(100)
)
RETURNS nvarchar(4000)
AS
BEGIN
	IF ISNULL(@input, '') = ''
		RETURN @input

	DECLARE @i int
	DECLARE @len int
	DECLARE @start int
	DECLARE @word varchar(4000)
	DECLARE @key varchar(4000)
	DECLARE @result varchar(4000)
	SET @i = 0
	SET @start = 0
	SET @result = LOWER(@input)
	SET @len = LEN(@result)

	WHILE @i <= @len
	BEGIN
		IF SUBSTRING(@result, @i, 1) BETWEEN 'a' AND 'z'
		BEGIN
			SET @start = @i
			WHILE @i <= @len
			BEGIN
				SET @i = @i + 1
				IF SUBSTRING(@result, @i, 1) NOT BETWEEN 'a' AND 'z'
					BREAK
			END
			SET @word = SUBSTRING(@result, @start, @i - @start)
			SET @key = ' ' + @word + ' '
			-- Words meant to be all uppercase
			IF CHARINDEX(@key, @allCaps) > 0
				SET @result = STUFF(@result, @start, @i - @start, UPPER(@word))
			-- Words not meant to be uppercase
			ELSE IF CHARINDEX(@key, @noCaps) = 0 OR @start = 1
				SET @result = STUFF(@result, @start, 1, UPPER(SUBSTRING(@word, 1, 1)))
			-- Special case names like McDonald
			--IF @word LIKE 'mc%'
			--	SET @result = STUFF(@result, @start + 2, 1, UPPER(SUBSTRING(@word, 3, 1)))
			IF @word LIKE 'fitz%'
				SET @result = STUFF(@result, @start + 4, 1, UPPER(SUBSTRING(@word, 5, 1)))
		END
		SET @i = @i + 1
	END
	
	RETURN @result
END