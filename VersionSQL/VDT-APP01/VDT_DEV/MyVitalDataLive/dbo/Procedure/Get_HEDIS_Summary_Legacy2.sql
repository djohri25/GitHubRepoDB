/****** Object:  Procedure [dbo].[Get_HEDIS_Summary_Legacy2]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- Changes:	05/08/2018	MDeLuca	Added calls by @LOB
-- =============================================
CREATE PROCEDURE [dbo].[Get_HEDIS_Summary_Legacy]
	@Product int = 0,
	@CustID int,
	@TIN varchar(50) = 'ALL',
	@NPI varchar(50) = 'ALL',
	@LOB varchar(50) = 'ALL',
	@MonthID char(6) = NULL,
	@Page int = 1,
	@RecsPerPage int = NULL,
	@SortBy varchar(50) = 'testAbbr',
	@SortDirection varchar(10) = 'asc',
	@EMS varchar(50) = NULL, --Only used by Dr Link
	@UserID_SSO varchar(50) = NULL, --Only used by Dr Link
	@TotalRecords int OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	IF @MonthID IS NULL
		SELECT @MonthID = MAX(MonthID) FROM dbo.Final_HEDIS_Member_FULL WHERE CustID = @CustID

	DECLARE @SiteActive varchar(50)
	DECLARE @SQL nvarchar(4000)
	DECLARE @Count int = 0
	DECLARE @ID int, @Abbreviation varchar(50)
	DECLARE @Abbreviations TABLE (ID int Identity (1,1), Abbreviation varchar(50), testName varchar(100), GoalPerc DECIMAL(8,2), LOB VARCHAR(10))
	DECLARE @AbbreviationsFinal TABLE (ID int Identity (1,1), Abbreviation varchar(50), LOB VARCHAR(10))
	CREATE TABLE #TEMP_RESULTS
	(testID INT, testAbbr VARCHAR(10), testName VARCHAR(100), testType VARCHAR(20), PrevYearPerc DECIMAL(8,2), CurYearToDatePerc DECIMAL(8,2), CurYearOverall DECIMAL(8,2), GoalPerc DECIMAL(8,2), QualifyingMemCount INT, CompletedMemCount INT, DueMemCount INT, YearToDateGoalStatus INT, CurYearOverallGoalStatus INT, MonthID CHAR(6))
	CREATE TABLE #TEMP_RESULTS_FINAL
	(testID INT, testAbbr VARCHAR(10), testName VARCHAR(100), testType VARCHAR(20), PrevYearPerc DECIMAL(8,2), CurYearToDatePerc DECIMAL(8,2), CurYearOverall DECIMAL(8,2), GoalPerc DECIMAL(8,2), QualifyingMemCount INT, CompletedMemCount INT, DueMemCount INT, YearToDateGoalStatus INT, CurYearOverallGoalStatus INT, MonthID CHAR(6))
	
	IF (@Product = 0)
	BEGIN
		IF (@EMS IS NULL AND @UserID_SSO IS NULL)
		BEGIN
			SET @SiteActive = 'PlanLink_Active'
		END
		ELSE
		BEGIN
			SET @SiteActive = 'DRLink_Active'
		END
	END
	ELSE IF (@Product = 1)
	BEGIN
		 SET @SiteActive = 'DRLink_Active'
	END
	ELSE IF (@Product = 2)
	BEGIN
		 SET @SiteActive = 'PlanLink_Active'
	END
	ELSE IF (@Product = 3)
	BEGIN
		 SET @SiteActive = 'AffinityQuality_Active'
	END

	SET @SQL =
		'SELECT DISTINCT a.Abbreviation, a.Name, b.Goal, ISNULL(''' + @LOB + ''', ''ALL'') AS LOB
		FROM [dbo].[HedisSubmeasures] a
		INNER JOIN [dbo].[HedisScorecard] b ON a.ID = b.SubmeasureID
		LEFT JOIN [dbo].[HedisScorecard_TIN] d ON b.ID = d.ScoreCardID AND (ISNULL(d.TIN, 0) = ''' + @TIN + ''' OR ''' + @TIN + ''' = ''ALL'')
		WHERE b.CustID = ' + CONVERT(varchar(10), @CustID) + '
			AND (ISNULL(b.' + @SiteActive + ', 0) = 1 OR ISNULL(d.' + @SiteActive + ', 0) = 1)
		ORDER BY Abbreviation'

	INSERT INTO @Abbreviations
	EXEC SP_EXECUTESQL @SQL

	SET @Count = (SELECT COUNT(*) FROM @Abbreviations)

	--Pagination & Sorting (parameters that can be determined before calculations)
	IF (@SortBy IN ('testAbbr', 'testName', 'GoalPerc'))
	BEGIN
		;WITH PostCTE AS 
		(
			SELECT Abbreviation, ROW_NUMBER() OVER
				(ORDER BY
					CASE WHEN @SortDirection = 'ASC' THEN
						CASE @SortBy
							WHEN 'testAbbr' THEN Abbreviation
							WHEN 'testName' THEN testName
							WHEN 'GoalPerc' THEN CAST(GoalPerc AS VARCHAR(50))
							ELSE Abbreviation
						END
					END ASC,
					CASE WHEN @SortDirection = 'DESC' THEN
					CASE @SortBy
							WHEN 'testAbbr' THEN Abbreviation
							WHEN 'testName' THEN testName
							WHEN 'GoalPerc' THEN CAST(GoalPerc AS VARCHAR(50))
							ELSE Abbreviation
						END
					END DESC
				) AS RowNumber
			,ISNULL(LOB, 'ALL') AS LOB
			FROM @Abbreviations
		)
		INSERT INTO @AbbreviationsFinal (Abbreviation, LOB)
		SELECT Abbreviation, LOB
		FROM PostCTE
		WHERE RowNumber > ((@Page - 1) * ISNULL(@RecsPerPage, 0)) AND RowNumber <= (((@Page - 1) * ISNULL(@RecsPerPage, 0)) + ISNULL(@RecsPerPage, 100000))
	END
	ELSE
	BEGIN
		INSERT INTO @AbbreviationsFinal (Abbreviation, LOB)
		SELECT Abbreviation, LOB
		FROM @Abbreviations
		ORDER BY Abbreviation
	END

	WHILE EXISTS (SELECT TOP 1 * FROM @AbbreviationsFinal)
	BEGIN
		SELECT TOP 1  @ID = ID, @Abbreviation = Abbreviation, @LOB = LOB FROM @AbbreviationsFinal
		
		INSERT #TEMP_RESULTS
			EXEC [dbo].[Get_HEDIS_Summary_ByMeasure] @Abbreviation = @Abbreviation, @CustID = @CustID, @LOB = @LOB, @NPI = @NPI, @TIN = @TIN, @MonthID = @MonthID

		DELETE @AbbreviationsFinal WHERE ID = @ID
	END

	--Pagination & Sorting (values in these columns can only be retrieved after the calculations)
	IF (@SortBy IN ('PrevYearPerc', 'CurYearToDatePerc', 'CurYearOverall', 'QualifyingMemCount', 'CompletedMemCount', 'DueMemCount', 'YearToDateGoalStatus', 'CurYearOverallGoalStatus'))
	BEGIN
		;WITH PostCTE AS
		(
			SELECT *, ROW_NUMBER() OVER
				(ORDER BY
					CASE WHEN @SortDirection = 'ASC' THEN
						CASE @SortBy
							WHEN 'PrevYearPerc' THEN CAST(PrevYearPerc AS DECIMAL(8,2))
							WHEN 'CurYearToDatePerc' THEN CAST(CurYearToDatePerc AS DECIMAL(8,2))
							WHEN 'CurYearOverall' THEN CAST(CurYearOverall AS DECIMAL(8,2))
							WHEN 'QualifyingMemCount' THEN CAST(QualifyingMemCount AS DECIMAL(8,2))
							WHEN 'CompletedMemCount' THEN CAST(CompletedMemCount AS DECIMAL(8,2))
							WHEN 'DueMemCount' THEN CAST(DueMemCount AS DECIMAL(8,2))
							WHEN 'YearToDateGoalStatus' THEN CAST(YearToDateGoalStatus AS DECIMAL(8,2))
							WHEN 'CurYearOverallGoalStatus' THEN CAST(CurYearOverallGoalStatus AS DECIMAL(8,2))
						END
					END ASC,
					CASE WHEN @SortDirection = 'DESC' THEN
					CASE @SortBy
							WHEN 'PrevYearPerc' THEN CAST(PrevYearPerc AS DECIMAL(8,2))
							WHEN 'CurYearToDatePerc' THEN CAST(CurYearToDatePerc AS DECIMAL(8,2))
							WHEN 'CurYearOverall' THEN CAST(CurYearOverall AS DECIMAL(8,2))
							WHEN 'QualifyingMemCount' THEN CAST(QualifyingMemCount AS DECIMAL(8,2))
							WHEN 'CompletedMemCount' THEN CAST(CompletedMemCount AS DECIMAL(8,2))
							WHEN 'DueMemCount' THEN CAST(DueMemCount AS DECIMAL(8,2))
							WHEN 'YearToDateGoalStatus' THEN CAST(YearToDateGoalStatus AS DECIMAL(8,2))
							WHEN 'CurYearOverallGoalStatus' THEN CAST(CurYearOverallGoalStatus AS DECIMAL(8,2))
						END
					END DESC
				) AS RowNumber
			FROM #TEMP_RESULTS
		)
		INSERT INTO #TEMP_RESULTS_FINAL
		SELECT testID, testAbbr, testName, testType, PrevYearPerc, CurYearToDatePerc, CurYearOverall, GoalPerc, QualifyingMemCount, CompletedMemCount, DueMemCount, YearToDateGoalStatus, CurYearOverallGoalStatus, MonthID
		FROM PostCTE
		WHERE RowNumber > ((@Page - 1) * ISNULL(@RecsPerPage, 0)) AND RowNumber <= (((@Page - 1) * ISNULL(@RecsPerPage, 0)) + ISNULL(@RecsPerPage, 100000))
	END
	ELSE
	BEGIN
		INSERT INTO #TEMP_RESULTS_FINAL
		SELECT *
		FROM #TEMP_RESULTS
	END

	IF (ISNULL(@EMS, '') != '' OR ISNULL(@UserID_SSO, '') != '')
	BEGIN
		-- Record SP Log
		DECLARE @params nvarchar(1000) = null
		SET @params = '@NPI=' + @NPI + ';' +
					  '@LOB=' + @LOB + ';' +
					  '@CustID=' + CONVERT(varchar(50), @CustID) + ';' +
					  '@TIN=' + ISNULL(@TIN, 'null') + ';' +
					  '@MonthID=' + ISNULL(@MonthID, 'null') + ';'
		EXEC [dbo].[Set_StoredProcedures_Log] '[dbo].[Get_HEDIS_Summary]', @EMS, @UserID_SSO, @params
	END

	SET @TotalRecords = @Count
	SELECT * FROM #TEMP_RESULTS_FINAL
END