/****** Object:  Function [dbo].[Get_HEDISMeasureNote]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 4/9/2014
-- Description:	Returns note about visit due info for W15 hedis test
-- =============================================
CREATE FUNCTION [dbo].[Get_HEDISMeasureNote]
(
	@testAbbreviation varchar(10),
	@mvdid varchar(20)
)
RETURNS varchar(max)
AS
BEGIN
	DECLARE @note varchar(max), @TESTID varchar(10), @dob date, @measureDeadline date, @visitCount int, @DOB_Current  date

	SELECT @TESTID = ISNULL(ID, 0)
	FROM [dbo].[HedisSubmeasures]
	WHERE Abbreviation = @testAbbreviation

	SELECT @note = ''

	SELECT @dob = dob
	FROM MainPersonalDetails p
	WHERE ICENUMBER= @mvdid

	IF(@testAbbreviation = 'W15')
	BEGIN	
		SELECT TOP 1 @visitCount = W15_visitCount
		FROM [Final_HEDIS_Member]
		WHERE mvdid = @mvdid
			AND testID = @testID 
		ORDER BY ID DESC

		SELECT @measureDeadline = DATEADD(day, 90, DATEADD(year, 1, @dob))

		SELECT TOP 1 @note = 'Visit #' + CONVERT(varchar, @visitCount + 1) + ' is due by ' + 
			dbo.Get_HEDISW15_NextVisitDueDate(@mvdid) + '.'
			+ ' All visits are due by ' + CONVERT(varchar,@measureDeadline,101) + '.'
	END
	IF(@testAbbreviation in ('W34','AWC'))
	BEGIN	
		SELECT @DOB_Current = CAST(CONVERT(char, DATEPART(YEAR, GETDATE())) + '.01.01' as date)
		SELECT @DOB_Current = DATEADD(MONTH, DATEPART(MONTH, @DOB) - 1, @DOB_Current) 
	    SELECT @DOB_Current = DATEADD(DAY, DATEPART(DAY, @DOB) - 1, @DOB_Current) 

		IF (GETDATE() > @DOB_Current  )
		BEGIN
			SELECT @note = ' Measure is Past Due '
		END
	END

	RETURN @note
END