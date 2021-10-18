/****** Object:  Function [dbo].[MVDIsNull]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE FUNCTION
MVDIsNull
(
	@p_str nvarchar(max)
)
RETURNS bit
AS
BEGIN
	RETURN
	CASE
	WHEN @p_str IS NULL THEN 1
	WHEN @p_str = '' THEN 1
	WHEN @p_str = 'NULL' THEN 1
	ELSE 0
	END;
END;