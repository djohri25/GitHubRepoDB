/****** Object:  Function [dbo].[CalAge]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE FUNCTION [dbo].[CalAge](@DOB datetime)
RETURNS varchar(15)
AS
BEGIN
	DECLARE @Result varchar(15)
	DECLARE @Count int
	SET @Result = ''
	SET @Count = datediff(yy, @DOB, getdate())
	IF @Count > 0
		SET @Result = LTRIM(RTRIM(STR(@Count))) + ' year(s)'
	ELSE
	BEGIN
		SET @Count = datediff(mm, @DOB, getdate())
		SET @Result = LTRIM(RTRIM(STR(@Count))) + ' month(s)'
	END

	RETURN @Result
END