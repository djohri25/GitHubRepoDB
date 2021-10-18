/****** Object:  Function [dbo].[Get_NumberOfDaysFromWD]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE FUNCTION
Get_NumberOfDaysFromWD
(
	@p_week_days_str nvarchar(255) = '0'
)
RETURNS bigint
AS
BEGIN
	DECLARE @v_wd_yn int = 0;
	DECLARE @v_w_position bigint = 0;
	DECLARE @v_d_position bigint = 0;
	DECLARE @v_space_position bigint = 0;
	DECLARE @v_num_weeks bigint = 0
	DECLARE @v_num_days bigint = 0;

	SET @v_wd_yn =
	CASE
	WHEN @p_week_days_str LIKE '%W%' THEN 1
	WHEN @p_week_days_str LIKE '%D%' THEN 1
	ELSE 0
	END;

	IF @v_wd_yn = 0
		RETURN CAST( ROUND( CAST( @p_week_days_str AS float ), 0 ) AS bigint );

	SET @v_w_position = CHARINDEX( 'W', @p_week_days_str );
	SET @v_d_position = CHARINDEX( 'D', @p_week_days_str );
	SET @v_space_position = CHARINDEX( ' ', @p_week_days_str );

	SET @v_space_position =
		CASE
		WHEN @v_w_position > @v_space_position THEN @v_w_position
		ELSE @v_space_position
		END;

	IF ( @v_w_position > 0 )
		SET @v_num_weeks = SUBSTRING( @p_week_days_str, 1, @v_w_position - 1 );

	IF ( @v_d_position > 0 )
		SET @v_num_days = SUBSTRING( @p_week_days_str, @v_space_position + 1, @v_d_position - @v_space_position - 1 );

	RETURN ( @v_num_weeks * 7 ) + @v_num_days;
END;