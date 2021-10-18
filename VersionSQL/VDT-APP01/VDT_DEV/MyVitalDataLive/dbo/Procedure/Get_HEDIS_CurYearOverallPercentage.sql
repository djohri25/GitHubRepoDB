/****** Object:  Procedure [dbo].[Get_HEDIS_CurYearOverallPercentage]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:	Marc De Luca
-- Create date: 07/07/2017
-- Description:	Calculates estimated percentage of members with completed HEDIS test for the current year
-- Example:	
-- EXEC dbo.Get_HEDIS_CurYearOverallPercentage @TestID = 2, @TIN = '043777705', @CustID = 11, @NPI = '1336104017', @PCP_GroupID = NULL, @CurYearToDatePerc = 36.2547, @YearOverallPercentage = 0
-- Changes:	MDeLuca	01/15/2018	Made changes for new Get_HEDIS_CurYearOverallPercentage
--					MDeLuca	02/05/2018	Using previous years data to calc for months 1,2 and 3
--					MDeLuca	02/05/2018	Added IN ('Predictive', 'Real', '3Percent', '5Percent')
-- =============================================
CREATE PROCEDURE [dbo].[Get_HEDIS_CurYearOverallPercentage]	
	 @TestID INT
	,@TIN VARCHAR(50)
	,@CustID INT
	,@NPI VARCHAR(50)
	,@PCP_GroupID INT = NULL
	,@CurYearToDatePerc DECIMAL(10,2) = NULL
	,@YearOverallPercentage DECIMAL(10,2) OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT @TIN = NULLIF(@TIN, '')
	SELECT @TIN = NULLIF(@TIN, 'ALL')

	SELECT @NPI = NULLIF(@NPI, '')
	SELECT @NPI = NULLIF(@NPI, 'ALL')
	
	SELECT @PCP_GroupID = NULLIF(@PCP_GroupID, 0)
	SELECT @PCP_GroupID = NULLIF(@PCP_GroupID, '')

	DECLARE
	 @Measure VARCHAR(25)
	,@MeasuramentYearStart DATE
	,@MeasuramentYearEnd DATE
	,@MeasuramentYear DATE
	,@StartMonthID CHAR(6)
	,@EndMonthID CHAR(6)
	,@Today DATE = GETDATE()
	,@MaxKey INT
	
	DROP TABLE IF EXISTS #N;
	CREATE TABLE #N (NPI VARCHAR(20))

	IF @PCP_GroupID IS NOT NULL
	BEGIN
		INSERT INTO #N (NPI)
		SELECT DISTINCT NPI
		FROM dbo.Link_MDGroupNPI
		WHERE MDGroupID = @PCP_GroupID
	END

	DECLARE @MonthIDs TABLE(MonthID CHAR(6))

	SELECT 
	 @Measure = Abbreviation
	,@MeasuramentYearStart = DATEFROMPARTS(CASE WHEN MONTH(@Today) < MONTH(MeasuramentYearStart) THEN YEAR(@Today)-1 ELSE YEAR(@Today) END, MONTH(MeasuramentYearStart), '01')
	,@MeasuramentYearEnd = DATEADD(MM, 11, DATEFROMPARTS(CASE WHEN MONTH(@Today) < MONTH(MeasuramentYearStart) THEN YEAR(@Today)-1 ELSE YEAR(@Today) END, MONTH(MeasuramentYearStart), '01'))
	FROM dbo.LookupHedis 
	WHERE ID = @TestID

	SET @MeasuramentYear = @MeasuramentYearStart
	
	WHILE @MeasuramentYear <= @MeasuramentYearEnd
	BEGIN

		INSERT INTO @MonthIDs (MonthID)
		SELECT CAST(LEFT(@MeasuramentYear,4) AS CHAR(4)) + CASE WHEN LEN(MONTH(@MeasuramentYear)) = 1 THEN '0'+CAST(MONTH(@MeasuramentYear) AS CHAR(1)) ELSE CAST(MONTH(@MeasuramentYear) AS CHAR(2)) END

		SET @MeasuramentYear = DATEADD(MM, 1, @MeasuramentYear)

	END

	DROP TABLE IF EXISTS #ForecastTable;
	CREATE TABLE #ForecastTable 
	(
	  ForecastKey int, CYear int, CMonth int, Measure varchar(25), Numer INT, Denom INT, PctComplete DECIMAL(38,17)
	 ,Smoothed_Quantity DECIMAL(38,17), Trend DECIMAL(38,17),Forward_Trend DECIMAL(38,17), Forecast DECIMAL(38,17)
	)

	INSERT INTO #ForecastTable (ForecastKey, CYear, CMonth, Measure, Numer, Denom, PctComplete)
	SELECT 
	 ForecastKey = ROW_NUMBER() OVER(ORDER BY LEFT(MonthID, 4), RIGHT(MonthID, 2)) 
	,LEFT(MonthID, 4) AS CYear
	,RIGHT(MonthID, 2) AS CMonth
	,ISNULL(@Measure, '') AS Measure	
	,SUM(CASE WHEN IsTestDue = 1 THEN 1 ELSE 0 END) AS Numer
	,COUNT(*) AS Denom
	,SUM(CASE WHEN IsTestDue = 1 THEN 1 ELSE 0 END) / CAST(COUNT(*) AS DECIMAL(38,17)) AS PctComplete
	FROM dbo.Final_HEDIS_Member_FULL F
	WHERE CustID = @CustID
	AND TestID = @TestID
	AND MonthID IN (SELECT MonthID FROM @MonthIDs)
	AND (@TIN IS NULL OR PCP_TIN = @TIN)
	AND (@NPI IS NULL OR PCP_NPI = @NPI)
	AND (@PCP_GroupID IS NULL OR PCP_NPI IN (SELECT NPI FROM #N))
	GROUP BY TestID, LEFT(MonthID, 4), RIGHT(MonthID, 2) 
	HAVING SUM(CASE WHEN IsTestDue = 1 THEN 1 ELSE 0 END) / CAST(COUNT(*) AS DECIMAL(38,17)) NOT IN (0)

	SELECT TOP (1) @MaxKey = ForecastKey
	FROM #ForecastTable 
	ORDER BY ForecastKey DESC

-- If we are in the first month
IF @MaxKey IN (1,2,3)
	BEGIN
		SELECT @StartMonthID = MIN(MonthID) ,@EndMonthID = MAX(MonthID)	FROM @MonthIDs

		DECLARE @PreviousMeasurenentEndMonthID CHAR(6), @PreviousMeasurenentStartMonthID CHAR(6)
		DECLARE @CurrentMonthPct DECIMAL(38,17), @LastYTDPct DECIMAL(38,17), @FirstMonthLastYrPct DECIMAL(38,17), @YearOverallPercentage2 DECIMAL(10,2)

		SELECT @PreviousMeasurenentEndMonthID = LEFT(CAST(DATEADD(MM, -1, DATEFROMPARTS(LEFT(@StartMonthID, 4), RIGHT(@StartMonthID, 2), '01')) AS CHAR(10)), 4)+SUBSTRING(CAST(DATEADD(MM, -1, DATEFROMPARTS(LEFT(@StartMonthID, 4), RIGHT(@StartMonthID, 2), '01')) AS CHAR(10)), 6,2)
		SELECT @PreviousMeasurenentStartMonthID = LEFT(CAST(DATEADD(MM, -12, DATEFROMPARTS(LEFT(@StartMonthID, 4), @MaxKey, '01')) AS CHAR(10)), 4)+SUBSTRING(CAST(DATEADD(MM, -12, DATEFROMPARTS(LEFT(@StartMonthID, 4), @MaxKey, '01')) AS CHAR(10)), 6,2)

		DROP TABLE IF EXISTS #PR
		SELECT 
		 MonthID
		,SUM(CASE WHEN IsTestDue = 1 THEN 1 ELSE 0 END) AS Numer
		,COUNT(*) AS Denom
		,SUM(CASE WHEN IsTestDue = 1 THEN 1 ELSE 0 END) / CAST(COUNT(*) AS DECIMAL(38,17)) AS PctComplete
		INTO #PR
		FROM dbo.Final_HEDIS_Member_FULL F
		WHERE EXISTS (SELECT * FROM dbo.LookupHedis L WHERE L.TestType IN ('Predictive', 'Real', '3Percent', '5Percent') AND L.ID = F.TestID)
		AND CustID = @CustID
		AND MonthID IN (@PreviousMeasurenentEndMonthID, @PreviousMeasurenentStartMonthID)
		AND TestID = @TestID
		AND (@TIN IS NULL OR PCP_TIN = @TIN)
		AND (@NPI IS NULL OR PCP_NPI = @NPI)
		AND (@PCP_GroupID IS NULL OR PCP_NPI IN (SELECT NPI FROM #N))
		GROUP BY MonthID

		SELECT @LastYTDPct = PctComplete FROM #PR WHERE MonthID = @PreviousMeasurenentEndMonthID
		SELECT @FirstMonthLastYrPct = PctComplete FROM #PR WHERE MonthID = @PreviousMeasurenentStartMonthID
		SELECT @CurrentMonthPct = PctComplete FROM #ForecastTable WHERE ForecastKey = @MaxKey
		SELECT @YearOverallPercentage2 = (@LastYTDPct * (1-(@FirstMonthLastYrPct - @CurrentMonthPct))) * 100

	END
	
	UPDATE #ForecastTable 
	SET  Smoothed_Quantity = MovAvg.Smoothed_Quantity
	FROM
	(
		SELECT 
			a.ForecastKey AS FKey
		,a.Measure AS Prod 
		,AVG(CAST(ISNULL(PctComplete,0.00) AS DECIMAL(18,5))) Smoothed_Quantity
		FROM #ForecastTable a
		GROUP BY a.ForecastKey, a.Measure
	) MovAvg
	WHERE Measure = MovAvg.Prod AND ForecastKey = MovAvg.FKey

	--****************************************************************************************
	--	Step 2 - Create a second table variable to hold the trend formula by item.  
	--		This step is performed with an insert and update to make the calculations more clear
	--		It could just as easily be performed with a single insert.
	--		Lastly, update the trend for historical data and calculate seasonality
	--*****************************************************************************************

	-- Create table to store calculations by Item
	IF OBJECT_ID('tempdb..#Formula') IS NOT NULL DROP TABLE #Formula;
	CREATE TABLE #Formula
	(
		ID INT IDENTITY(1,1) PRIMARY KEY NONCLUSTERED, Measure varchar(25), Counts int, SumX DECIMAL(14,4), SumY DECIMAL(14,4), SumXY DECIMAL(14,4)
	, SumXsqrd DECIMAL(14,4), b DECIMAL(38,17), a DECIMAL(38,17)
	)
	
	INSERT INTO #Formula (Measure, Counts, SumX, SumY, SumXY, SumXsqrd)	
	SELECT 
		Measure
	,COUNT(*)
	,SUM(ForecastKey)
	,SUM(Smoothed_Quantity)
	,SUM(Smoothed_Quantity * ForecastKey)
	,SUM(POWER(ForecastKey,2)) 
	FROM #ForecastTable
	WHERE Smoothed_Quantity IS NOT NULL
	GROUP BY Measure

	-- Calculate B (Slope)
	UPDATE a
	SET b = ((b.counts * b.sumXY)-(b.sumX * b.sumY))/ NULLIF((b.Counts * b.sumXsqrd - POWER(b.sumX,2)), 0)
	FROM #Formula a
	JOIN #Formula b on a.Measure = b.Measure

	--UPDATE #Formula
	--SET b = CASE WHEN b < 0 THEN 0 ELSE b END
		
	--Calculate A (Y Intercept)
	UPDATE a
	SET a = ((b.sumY - b.b * b.sumX) / NULLIF(b.Counts, 0))
	FROM #Formula a
	JOIN #Formula b ON a.Measure = b.Measure
		
	-- Update Historical Trend
	--y = a + bx
	--Forecast = Y Intercept + (Slope * ForecastKey)
	UPDATE #ForecastTable 
	SET  Trend = A + (B * ForecastKey)
	FROM #ForecastTable 
	JOIN #Formula ON #Formula.Measure = #ForecastTable.Measure

	--**********************************************************************************
	--	Step 3 - Insert Trendline and forecast into Forecast table 
	--**********************************************************************************

	-- Create Forecast
	DECLARE @CurrentMonth AS DATE, @MaxNullKey INT

	SELECT @CurrentMonth = MAX(DATEFROMPARTS(CYear,CMONTH,'01')) FROM #ForecastTable

	UPDATE #Formula SET b = ISNULL(b,0), a = ISNULL(a,0) -- Just added 12/27
	
	WHILE @CurrentMonth < @MeasuramentYearEnd
		BEGIN

			INSERT INTO #ForecastTable (ForecastKey, CYear, CMonth, Measure, Forward_Trend, Forecast)
			SELECT 
				 MAX(Forecastkey) + 1
				,YEAR(@CurrentMonth) -- Dates could be incremented by joining to a date dimension or using Dateadd for a date type
				,MONTH(DATEADD(MM, 1, @CurrentMonth))
				,a.Measure
				, MAX(b.A) + (MAX(b.B) * (MAX(a.Forecastkey) + 1))  * 1 AS Forward_Trend
				,(MAX(b.A) + (MAX(b.B) * (MAX(a.Forecastkey) + 1))) * 1 AS Forecast
			FROM #ForecastTable a
			JOIN #Formula b ON  a.Measure = b.Measure
			GROUP BY a.Measure
				
		SET @CurrentMonth = DATEADD(MM, 1, @CurrentMonth)

		END

	SELECT TOP (1) @MaxKey = ForecastKey
	FROM #ForecastTable 
	ORDER BY ForecastKey DESC
	
	SELECT @YearOverallPercentage = CASE WHEN Forecast IS NOT NULL THEN Forecast * 100 ELSE PctComplete * 100 END
	FROM #ForecastTable
	WHERE ForecastKey = @MaxKey

	SELECT @MaxNullKey = MAX(ForecastKey) FROM #ForecastTable WHERE Denom IS NOT NULL

	IF @YearOverallPercentage <= 0 AND @MaxNullKey >= 1
		SELECT @YearOverallPercentage = PctComplete * 100
		FROM #ForecastTable
		WHERE ForecastKey = @MaxNullKey

	SELECT @YearOverallPercentage = CASE	WHEN @YearOverallPercentage >= 100 THEN 100.00 WHEN @YearOverallPercentage <= 0 THEN 0 ELSE ISNULL(@YearOverallPercentage,0) END
	SELECT @YearOverallPercentage = CASE WHEN @YearOverallPercentage < 0 THEN 0 ELSE @YearOverallPercentage END

	SELECT @YearOverallPercentage = COALESCE(@YearOverallPercentage2,@YearOverallPercentage,0.00)	

END