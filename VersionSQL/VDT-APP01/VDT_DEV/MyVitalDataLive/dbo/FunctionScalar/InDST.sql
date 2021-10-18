/****** Object:  Function [dbo].[InDST]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE FUNCTION [dbo].[InDST]
	(
	@input datetime
	)
RETURNS BIT
BEGIN
	-- DST
	-- begins 2nd Sunday of March, 2am
	-- ends   1st Sunday of November, 2am
	-- SELECT dbo.InDST('3/8/2009 1:59:59am'), dbo.InDST('3/8/2009 2am'), dbo.InDST('11/1/2009 1:59:59am'), dbo.InDST('11/1/2009 2am')
	-- should produce 0, 1, 1, 0
	DECLARE @year CHAR(4), @startDate datetime, @endDate datetime, @date datetime
	-- get year of input
	SET @year = CAST(YEAR(@input) AS CHAR(4))
	-- calculate start of DST
	SET @date = '3/1/' + @year
	-- start with the last day of the previous month
	SET @date = DATEADD(DD, -1, @date)
	-- calculate moving forward to the first sunday
	SET @date = DATEADD(DW, 8 - DATEPART(DW, @date), @date)
	-- add a week to get to the second sunday
	SET @date = DATEADD(WW, 1, @date)
	-- add 2 hours for 2am
	SET @date = DATEADD(HH, 2, @date)
	SET @startDate = @date
	-- calculate end of DST using similar method as above
	SET @date = '11/1/' + @year
	SET @date = DATEADD(DD, -1, @date) 
	SET @date = DATEADD(DW, 8 - DATEPART(DW, @date), @date)
	SET @date = DATEADD(HH, 2, @date)
	SET @endDate = @date

	IF @input >= @startDate AND @input < @endDate
		RETURN 1
	RETURN 0
END