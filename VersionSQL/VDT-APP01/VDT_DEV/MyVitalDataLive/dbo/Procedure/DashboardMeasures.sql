/****** Object:  Procedure [dbo].[DashboardMeasures]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[DashboardMeasures]
 @CustID INT
,@Measure VARCHAR(10) = NULL
,@BenchmarkYear VARCHAR(20) = NULL
,@TIN VARCHAR(15) = NULL
,@LOB varchar(50) = NULL
,@Product INT = NULL
WITH RECOMPILE
AS

-- =============================================
-- Author: Marc De Luca
-- Create date: 01/30/2017
-- Description: Provides measure benchmark for a dashboard graph
-- Example: EXEC dbo.DashboardMeasures @CustID = 11, @Measure = 'CDC10', @TIN = '753070138', @BenchmarkYear = '2016'
-- 03/16/2018	MDeLuca	Added date check
-- 05/28/2018	MDeLuca	Added @LOB and @Product	
-- 09/04/2018	MDeLuca	Added IN ('Predictive', 'Real', '3Percent', '5Percent')
-- =============================================

BEGIN

	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET NOCOUNT ON;

	IF @Product IS NULL
		SET @Product = 2

	DECLARE @Today DATE, @TodayUTC DATE

	SELECT @Today = CASE WHEN @CustID = 16 THEN '03/31/2016' ELSE GETDATE() END

	SET @TIN = ISNULL(@TIN,'')

	SET @Measure = NULLIF(@Measure,'')

	DECLARE 
	 @CurrentID AS INT = 1
	,@MaxID INT
	,@SQLString NVARCHAR(MAX)
	,@CurrentMonth DATE
	,@RollingMonths TINYINT = 23
	,@StartDate DATE
	,@CurrentDate DATE
	,@MaxMonthID CHAR(6)

	IF @BenchmarkYear IS NULL
	BEGIN
		SELECT @MaxMonthID = MAX(MonthID) FROM dbo.Final_HEDIS_Member_FULL WHERE CustID = @CustID
		SET @CurrentMonth = DATEFROMPARTS(LEFT(@MaxMonthID, 4), RIGHT(@MaxMonthID,2), '01')
	END

	IF @BenchmarkYear IS NOT NULL
		SET @CurrentMonth = CASE WHEN @CustID = 16 THEN DATEFROMPARTS('2016', MONTH(@Today), '01') ELSE DATEFROMPARTS(@BenchmarkYear, MONTH(@Today), '01') END

	SELECT @StartDate = DATEADD(MM,-@RollingMonths, @CurrentMonth)

	SET @CurrentDate = @StartDate

	IF OBJECT_ID('tempdb..#Dates') IS NOT NULL DROP TABLE #Dates;
	CREATE TABLE #Dates (ID INT IDENTITY(1,1), MeasureDate DATE, MonthID CHAR(6), TimePeriod VARCHAR(25), MonthIndicator TINYINT, FirstMonthID CHAR(6), LastMonthID CHAR(6))

	WHILE @CurrentDate <= @CurrentMonth
	BEGIN

		INSERT INTO #Dates (MeasureDate, MonthID)
		VALUES(@CurrentDate, CAST(YEAR(@CurrentDate) AS CHAR(4))+CASE WHEN LEN(MONTH(@CurrentDate)) = 1 THEN '0'+CAST(MONTH(@CurrentDate) AS CHAR(2)) ELSE CAST(MONTH(@CurrentDate) AS CHAR(2)) END)

		SET @CurrentDate = DATEADD(MM, 1, @CurrentDate)

	END

	UPDATE #Dates
	SET	 
	 TimePeriod = CASE WHEN ID BETWEEN 1 AND 12 THEN 'PriorYear' ELSE 'CurrentYear' END
	,MonthIndicator = CASE ID	WHEN 1 THEN 1 WHEN 13 THEN 1 WHEN 2 THEN 2 WHEN 14 THEN 2
						WHEN 3 THEN 3 WHEN 15 THEN 3 WHEN 4 THEN 4 WHEN 16 THEN 4
						WHEN 5 THEN 5 WHEN 17 THEN 5 WHEN 6 THEN 6 WHEN 18 THEN 6
						WHEN 7 THEN 7 WHEN 19 THEN 7 WHEN 8 THEN 8 WHEN 20 THEN 8
						WHEN 9 THEN 9 WHEN 21 THEN 9 WHEN 10 THEN 10 WHEN 22 THEN 10
						WHEN 11 THEN 11 WHEN 23 THEN 11 WHEN 12 THEN 12 WHEN 24 THEN 12
						END

	UPDATE D
	SET  D.FirstMonthID = X.FirstMonthID
			,D.LastMonthID =  X.LastMonthID
	FROM #Dates D
	JOIN
	(
		SELECT 
		ID
		,FirstMonthID = FIRST_VALUE(MonthID) OVER (ORDER BY ID ASC)
		,LastMonthID =  FIRST_VALUE(MonthID) OVER (ORDER BY ID DESC)
		FROM #Dates D
	) X ON D.ID = X.ID

	IF OBJECT_ID('tempdb..#Measures') IS NOT NULL DROP TABLE #Measures;
	CREATE TABLE #Measures (Measure VARCHAR(10), MeasureName VARCHAR(100), MonthID CHAR(6), Denom INT, Numer INT)

	INSERT INTO #Measures (Measure, MeasureName, MonthID, Denom, Numer)
	SELECT H.Abbreviation, H.Name AS MeasureName, M.MonthID, COUNT(*) AS Denom, SUM(CASE WHEN M.IsTestDue = 1 THEN 1 ELSE 0 END) AS Numer
	FROM dbo.Final_HEDIS_Member_FULL M
	JOIN dbo.LookupHedis H ON M.TestID = H.ID AND H.TestType IN ('Predictive', 'Real', '3Percent', '5Percent')
	WHERE CustID = @CustID
	AND MonthID IN (SELECT DISTINCT MonthID FROM #Dates)
	AND (@Measure IS NULL OR H.Abbreviation = @Measure)
	AND (ISNULL(@TIN,'') = '' OR M.PCP_TIN = @TIN)
	AND (@LOB IS NULL OR M.LOB = @LOB)
	AND EXISTS
	(
		SELECT 1
		FROM [dbo].[HedisScorecard] HS
		JOIN [dbo].[HedisSubmeasures] HSM ON HS.SubmeasureID = HSM.ID
		WHERE HS.CustID = @CustID
		AND HS.LOB IS NULL
		AND HSM.[ID] = M.TestID
		AND (@Product IS NULL 
		OR (@Product = 1 AND ISNULL(HS.[DRLink_Active], 0) = 1)
		OR (@Product = 2 AND ISNULL(HS.[PlanLink_Active], 0) = 1)
		OR (@Product = 3 AND ISNULL(HS.[AffinityQuality_Active], 0) = 1)
				)
	)
	GROUP BY H.Abbreviation, H.Name, M.MonthID

	CREATE INDEX IX_Measure_MonthID ON #Measures (Measure, MonthID)
	CREATE INDEX IX_MonthID ON #Measures (Measure)
	
	--DELETE M
	--FROM #Measures M
	--WHERE NOT EXISTS (SELECT 1 FROM #Measures X WHERE X.Measure = M.Measure GROUP BY Measure HAVING COUNT(*) > 2)

		DELETE M
		FROM #Measures M
		WHERE NOT EXISTS (SELECT 1 FROM #Measures X WHERE X.Measure = M.Measure GROUP BY Measure HAVING SUM(Numer) > 0)

	DROP TABLE IF EXISTS #M;
	CREATE TABLE #M (ID INT IDENTITY(1,1) PRIMARY KEY CLUSTERED, Measure VARCHAR(10))

	INSERT INTO #M (Measure)
	SELECT DISTINCT Measure
	FROM #Measures
	ORDER BY Measure

	SELECT @MaxID = MAX(ID) FROM #M

	WHILE @MaxID >= @CurrentID
	BEGIN
			SELECT @Measure = Measure FROM #M WHERE ID = @CurrentID

			IF (SELECT SUM(Numer) FROM #Measures WHERE Measure = @Measure) > 0
			BEGIN

			SELECT
			 Measure
			,MeasureName
			,MonthID = CASE WHEN TimePeriod = 'PriorYear' THEN FirstMonthID ELSE LastMonthID END
			,TimePeriod Yr
			,SUM(CASE WHEN MonthIndicator = 1 THEN CAST(Numer/NULLIF(CAST(Denom AS DECIMAL(18,5)),0) AS DECIMAL(5,2)) ELSE 0 END) '0'
			,SUM(CASE WHEN MonthIndicator = 2 THEN CAST(Numer/NULLIF(CAST(Denom AS DECIMAL(18,5)),0) AS DECIMAL(5,2)) ELSE 0 END) '1'
			,SUM(CASE WHEN MonthIndicator = 3 THEN CAST(Numer/NULLIF(CAST(Denom AS DECIMAL(18,5)),0) AS DECIMAL(5,2)) ELSE 0 END) '2'
			,SUM(CASE WHEN MonthIndicator = 4 THEN CAST(Numer/NULLIF(CAST(Denom AS DECIMAL(18,5)),0) AS DECIMAL(5,2)) ELSE 0 END) '3'
			,SUM(CASE WHEN MonthIndicator = 5 THEN CAST(Numer/NULLIF(CAST(Denom AS DECIMAL(18,5)),0) AS DECIMAL(5,2)) ELSE 0 END) '4'
			,SUM(CASE WHEN MonthIndicator = 6 THEN CAST(Numer/NULLIF(CAST(Denom AS DECIMAL(18,5)),0) AS DECIMAL(5,2)) ELSE 0 END) '5'
			,SUM(CASE WHEN MonthIndicator = 7 THEN CAST(Numer/NULLIF(CAST(Denom AS DECIMAL(18,5)),0) AS DECIMAL(5,2)) ELSE 0 END) '6'
			,SUM(CASE WHEN MonthIndicator = 8 THEN CAST(Numer/NULLIF(CAST(Denom AS DECIMAL(18,5)),0) AS DECIMAL(5,2)) ELSE 0 END) '7'
			,SUM(CASE WHEN MonthIndicator = 9 THEN CAST(Numer/NULLIF(CAST(Denom AS DECIMAL(18,5)),0) AS DECIMAL(5,2)) ELSE 0 END) '8'
			,SUM(CASE WHEN MonthIndicator = 10 THEN CAST(Numer/NULLIF(CAST(Denom AS DECIMAL(18,5)),0) AS DECIMAL(5,2)) ELSE 0 END) '9'
			,SUM(CASE WHEN MonthIndicator = 11 THEN CAST(Numer/NULLIF(CAST(Denom AS DECIMAL(18,5)),0) AS DECIMAL(5,2)) ELSE 0 END) '10'
			,SUM(CASE WHEN MonthIndicator = 12 THEN CAST(Numer/NULLIF(CAST(Denom AS DECIMAL(18,5)),0) AS DECIMAL(5,2)) ELSE 0 END) '11'
			FROM #Dates D
			JOIN #Measures M ON D.MonthID = M.MonthID 
			WHERE M.Measure = @Measure
			GROUP BY Measure, MeasureName, TimePeriod, CASE WHEN TimePeriod = 'PriorYear' THEN FirstMonthID ELSE LastMonthID END
			ORDER BY Measure, MeasureName, TimePeriod DESC

			END
		SET @CurrentID = @CurrentID + 1
	END

END