/****** Object:  Function [dbo].[GetHEDISCurYearOverallPercentage]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[GetHEDISCurYearOverallPercentage]
(
	 @TestID INT
	,@TIN VARCHAR(50)
	,@CustID INT
	,@NPI VARCHAR(50)
)
RETURNS DECIMAL(10,2)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @YearOverallPercentage DECIMAL(10,2)

	SELECT @TIN = NULLIF(@TIN, '')
	SELECT @TIN = NULLIF(@TIN, 'ALL')

	SELECT @NPI = NULLIF(@NPI, '')
	SELECT @NPI = NULLIF(@NPI, 'ALL')
	

	DECLARE
	 @Measure VARCHAR(25)
	,@MeasuramentYearStart DATE
	,@MeasuramentYearEnd DATE
	,@MeasuramentYear DATE
	,@StartMonthID CHAR(6)
	,@EndMonthID CHAR(6)
	,@Today DATE = '12/31/2017' --GETDATE()
	,@MaxKey INT
	
	DECLARE @N TABLE (NPI VARCHAR(20))

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

	DECLARE @ForecastTable TABLE 
	(
	  ForecastKey int, CYear int, CMonth int, Measure varchar(25), Numer INT, Denom INT, PctComplete DECIMAL(38,17)
	 ,Smoothed_Quantity DECIMAL(38,17), Trend DECIMAL(38,17),Forward_Trend DECIMAL(38,17), Forecast DECIMAL(38,17)
	)

	INSERT INTO @ForecastTable (ForecastKey, CYear, CMonth, Measure, Numer, Denom, PctComplete)
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
	GROUP BY TestID, LEFT(MonthID, 4), RIGHT(MonthID, 2) 
	HAVING SUM(CASE WHEN IsTestDue = 1 THEN 1 ELSE 0 END) / CAST(COUNT(*) AS DECIMAL(38,17)) NOT IN (0)

	SELECT TOP (1) @MaxKey = ForecastKey
	FROM @ForecastTable 
	ORDER BY ForecastKey DESC

-- If we are in the first month
IF @MaxKey IN (1,2,3)
	BEGIN
		SELECT @StartMonthID = MIN(MonthID) ,@EndMonthID = MAX(MonthID)	FROM @MonthIDs

		DECLARE @PreviousMeasurenentEndMonthID CHAR(6), @PreviousMeasurenentStartMonthID CHAR(6)
		DECLARE @CurrentMonthPct DECIMAL(38,17), @LastYTDPct DECIMAL(38,17), @FirstMonthLastYrPct DECIMAL(38,17), @YearOverallPercentage2 DECIMAL(10,2)

		SELECT @PreviousMeasurenentEndMonthID = LEFT(CAST(DATEADD(MM, -1, DATEFROMPARTS(LEFT(@StartMonthID, 4), RIGHT(@StartMonthID, 2), '01')) AS CHAR(10)), 4)+SUBSTRING(CAST(DATEADD(MM, -1, DATEFROMPARTS(LEFT(@StartMonthID, 4), RIGHT(@StartMonthID, 2), '01')) AS CHAR(10)), 6,2)
		SELECT @PreviousMeasurenentStartMonthID = LEFT(CAST(DATEADD(MM, -12, DATEFROMPARTS(LEFT(@StartMonthID, 4), @MaxKey, '01')) AS CHAR(10)), 4)+SUBSTRING(CAST(DATEADD(MM, -12, DATEFROMPARTS(LEFT(@StartMonthID, 4), @MaxKey, '01')) AS CHAR(10)), 6,2)

		DECLARE @PR TABLE (MonthID CHAR(6), Numer INT, Denom INT, PctComplete DECIMAL(38,17))
		INSERT INTO @PR (MonthID, Numer, Denom, PctComplete)
		SELECT 
		 MonthID
		,SUM(CASE WHEN IsTestDue = 1 THEN 1 ELSE 0 END) AS Numer
		,COUNT(*) AS Denom
		,SUM(CASE WHEN IsTestDue = 1 THEN 1 ELSE 0 END) / CAST(COUNT(*) AS DECIMAL(38,17)) AS PctComplete
		FROM dbo.Final_HEDIS_Member_FULL F
		WHERE EXISTS (SELECT * FROM dbo.LookupHedis L WHERE L.TestType IN ('Predictive', 'Real') AND L.ID = F.TestID)
		AND CustID = @CustID
		AND MonthID IN (@PreviousMeasurenentEndMonthID, @PreviousMeasurenentStartMonthID)
		AND TestID = @TestID
		AND (@TIN IS NULL OR PCP_TIN = @TIN)
		AND (@NPI IS NULL OR PCP_NPI = @NPI)
		GROUP BY MonthID

		SELECT @LastYTDPct = PctComplete FROM @PR WHERE MonthID = @PreviousMeasurenentEndMonthID
		SELECT @FirstMonthLastYrPct = PctComplete FROM @PR WHERE MonthID = @PreviousMeasurenentStartMonthID
		SELECT @CurrentMonthPct = PctComplete FROM @ForecastTable WHERE ForecastKey = @MaxKey
		SELECT @YearOverallPercentage2 = (@LastYTDPct * (1-(@FirstMonthLastYrPct - @CurrentMonthPct))) * 100

	END
	
	UPDATE @ForecastTable 
	SET  Smoothed_Quantity = MovAvg.Smoothed_Quantity
	FROM
	(
		SELECT 
			a.ForecastKey AS FKey
		,a.Measure AS Prod 
		,AVG(CAST(ISNULL(PctComplete,0.00) AS DECIMAL(18,5))) Smoothed_Quantity
		FROM @ForecastTable a
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
	DECLARE @Formula TABLE 
	(
		ID INT IDENTITY(1,1) PRIMARY KEY NONCLUSTERED, Measure varchar(25), Counts int, SumX DECIMAL(14,4), SumY DECIMAL(14,4), SumXY DECIMAL(14,4)
	, SumXsqrd DECIMAL(14,4), b DECIMAL(38,17), a DECIMAL(38,17)
	)
	
	INSERT INTO @Formula (Measure, Counts, SumX, SumY, SumXY, SumXsqrd)	
	SELECT 
		Measure
	,COUNT(*)
	,SUM(ForecastKey)
	,SUM(Smoothed_Quantity)
	,SUM(Smoothed_Quantity * ForecastKey)
	,SUM(POWER(ForecastKey,2)) 
	FROM @ForecastTable
	WHERE Smoothed_Quantity IS NOT NULL
	GROUP BY Measure

	-- Calculate B (Slope)
	UPDATE a
	SET b = ((b.counts * b.sumXY)-(b.sumX * b.sumY))/ NULLIF((b.Counts * b.sumXsqrd - POWER(b.sumX,2)), 0)
	FROM @Formula a
	JOIN @Formula b on a.Measure = b.Measure

	--UPDATE @Formula
	--SET b = CASE WHEN b < 0 THEN 0 ELSE b END
		
	--Calculate A (Y Intercept)
	UPDATE a
	SET a = ((b.sumY - b.b * b.sumX) / NULLIF(b.Counts, 0))
	FROM @Formula a
	JOIN @Formula b ON a.Measure = b.Measure
		
	-- Update Historical Trend
	--y = a + bx
	--Forecast = Y Intercept + (Slope * ForecastKey)
	UPDATE @ForecastTable 
	SET  Trend = A + (B * ForecastKey)
	FROM @ForecastTable F 
	JOIN @Formula L ON F.Measure = L.Measure

	--**********************************************************************************
	--	Step 3 - Insert Trendline and forecast into Forecast table 
	--**********************************************************************************

	-- Create Forecast
	DECLARE @CurrentMonth AS DATE, @MaxNullKey INT

	SELECT @CurrentMonth = MAX(DATEFROMPARTS(CYear,CMONTH,'01')) FROM @ForecastTable

	UPDATE @Formula SET b = ISNULL(b,0), a = ISNULL(a,0) -- Just added 12/27
	
	WHILE @CurrentMonth < @MeasuramentYearEnd
		BEGIN

			INSERT INTO @ForecastTable (ForecastKey, CYear, CMonth, Measure, Forward_Trend, Forecast)
			SELECT 
				 MAX(Forecastkey) + 1
				,YEAR(@CurrentMonth) -- Dates could be incremented by joining to a date dimension or using Dateadd for a date type
				,MONTH(DATEADD(MM, 1, @CurrentMonth))
				,a.Measure
				, MAX(b.A) + (MAX(b.B) * (MAX(a.Forecastkey) + 1))  * 1 AS Forward_Trend
				,(MAX(b.A) + (MAX(b.B) * (MAX(a.Forecastkey) + 1))) * 1 AS Forecast
			FROM @ForecastTable a
			JOIN @Formula b ON  a.Measure = b.Measure
			GROUP BY a.Measure
				
		SET @CurrentMonth = DATEADD(MM, 1, @CurrentMonth)

		END

	SELECT TOP (1) @MaxKey = ForecastKey
	FROM @ForecastTable 
	ORDER BY ForecastKey DESC
	
	SELECT @YearOverallPercentage = CASE WHEN Forecast IS NOT NULL THEN Forecast * 100 ELSE PctComplete * 100 END
	FROM @ForecastTable
	WHERE ForecastKey = @MaxKey

	SELECT @MaxNullKey = MAX(ForecastKey) FROM @ForecastTable WHERE Denom IS NOT NULL

	IF @YearOverallPercentage <= 0 AND @MaxNullKey >= 1
		SELECT @YearOverallPercentage = PctComplete * 100
		FROM @ForecastTable
		WHERE ForecastKey = @MaxNullKey

	SELECT @YearOverallPercentage = CASE	WHEN @YearOverallPercentage >= 100 THEN 100.00 WHEN @YearOverallPercentage <= 0 THEN 0 ELSE ISNULL(@YearOverallPercentage,0) END
	SELECT @YearOverallPercentage = CASE WHEN @YearOverallPercentage < 0 THEN 0 ELSE @YearOverallPercentage END

	SELECT @YearOverallPercentage = COALESCE(@YearOverallPercentage2,@YearOverallPercentage,0.00)	

	RETURN 	@YearOverallPercentage

END