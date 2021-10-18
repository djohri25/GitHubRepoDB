/****** Object:  Function [dbo].[FormatIPAddress]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE FUNCTION [dbo].[FormatIPAddress]
	(
	@IPAddress varchar(16)
	)
RETURNS varchar(16)
AS
BEGIN
	DECLARE @s varchar(16), @r varchar(16), @i int, @j int
	SET @i = 1
	SET @j = 1
	SET @s = @IPAddress
	SET @r = ''
	WHILE @j < LEN(@s)
	BEGIN
		SET @j = CHARINDEX('.', @s, @i)
		IF @j = 0
			SET @j = LEN(@s)+1
		SET @r = @r + ISNULL(REPLICATE('0', 3+@i-@j), '') + SUBSTRING(@s, @i, @j-@i+1)
		SET @i = @j + 1
	END
	RETURN @r
END