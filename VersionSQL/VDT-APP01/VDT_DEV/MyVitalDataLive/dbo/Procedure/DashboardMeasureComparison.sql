/****** Object:  Procedure [dbo].[DashboardMeasureComparison]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- Example: EXEC dbo.DashboardMeasureComparison @CustID = 10, @Measure = 'AWC'
-- =============================================
CREATE PROCEDURE [dbo].[DashboardMeasureComparison] 
	 @CustID INT
	,@Measure VARCHAR(10) = NULL
AS

BEGIN

	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	DECLARE 
	 @StartDate DATE
	,@EndDate DATE
	,@CurrentDate DATE
	,@StartYear INT = YEAR(GETDATE())
	,@Month INT = MONTH(GETDATE())
	,@StartMonthID CHAR(6)
	,@EndMonthID CHAR(6)

	SELECT 
	 @StartDate = DATEADD(YY, -2, DATEFROMPARTS(@StartYear, '01', '01'))
	,@EndDate = DATEFROMPARTS(@StartYear, '12', '31')
	,@StartMonthID = CAST(@StartYear-2 AS CHAR(4))+'01'
	,@EndMonthID = '201812'

	SET @CurrentDate = @StartDate

	IF OBJECT_ID('tempdb..#Dates') IS NOT NULL DROP TABLE #Dates;
	CREATE TABLE #Dates (ID INT IDENTITY(1,1), PeriodDate DATE, MonthID CHAR(6))

	WHILE @CurrentDate <= @EndDate
	BEGIN

		INSERT INTO #Dates (PeriodDate, MonthID)
		VALUES(@CurrentDate, CAST(YEAR(@CurrentDate) AS CHAR(4))+CASE WHEN LEN(MONTH(@CurrentDate)) = 1 THEN '0'+CAST(MONTH(@CurrentDate) AS CHAR(2)) ELSE CAST(MONTH(@CurrentDate) AS CHAR(2)) END)

		SET @CurrentDate = DATEADD(MM, 1, @CurrentDate)

	END

	SELECT
	 D.MonthID
	,COUNT(F.MonthID) AS MeasurePopulation
--	,SUM(CASE WHEN F.IsTestDue = 1 THEN 1 ELSE 0 END) AS Numer
--	,ISNULL(CAST(ROUND(SUM(CASE WHEN F.IsTestDue = 1 THEN 1 ELSE 0 END) / NULLIF(CAST(COUNT(F.MonthID) AS DECIMAL(18,2)),0) * 100,0) AS DECIMAL(18,2)),0) AS MeasureRate
	,ISNULL(CAST(ROUND(SUM(CASE WHEN F.IsTestDue = 1 THEN 1 ELSE 0 END) / NULLIF(CAST(COUNT(F.MonthID) AS DECIMAL(18,2)),0) * 100, 2) AS DECIMAL(18,2)),0.00) AS MeasureRate
	FROM #Dates D
	LEFT JOIN
	(
		SELECT F.MonthID, F.IsTestDue
		FROM dbo.Final_HEDIS_Member_FULL F
		JOIN dbo.HedisSubmeasures S ON F.TestID = S.ID
		WHERE F.CustID = @CustID
		AND S.Abbreviation = @Measure
		AND F.MonthID >= @StartMonthID 
	) F ON D.MonthID = F.MonthID
	GROUP BY D.MonthID
	ORDER BY D.MonthID

END