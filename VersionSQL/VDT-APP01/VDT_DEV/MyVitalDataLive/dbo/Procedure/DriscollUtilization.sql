/****** Object:  Procedure [dbo].[DriscollUtilization]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		Marc De Luca
-- Create date: 01/01/2017
-- Description:	Driscoll utilization 
-- =============================================

CREATE PROCEDURE [dbo].[DriscollUtilization]
	 @Measure VARCHAR(10)
	,@StartDate DATE
	,@EndDate DATE
	,@Denom INT -- 10, 50
AS

-- EXEC dbo.DriscollUtilization @Measure = 'W15', @StartDate = '1/1/2014', @EndDate = '12/31/2016', @Denom = 10

BEGIN

	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	IF OBJECT_ID('tempdb..#Dates') IS NOT NULL DROP TABLE #Dates;
	CREATE TABLE #Dates (MonthID VARCHAR(6), Yr INT, Mo INT)

	DECLARE @CurrentDate DATE

	SELECT @EndDate = DATEADD(dd, 1, @EndDate)

	SET @CurrentDate = @StartDate

	WHILE @CurrentDate < @EndDate
	BEGIN

		INSERT INTO #Dates (MonthID, Yr, Mo)
		VALUES(LEFT(CAST(CAST(@CurrentDate AS DATE) AS VARCHAR(10)), 4)+SUBSTRING(CAST(CAST(@CurrentDate AS DATE) AS VARCHAR(10)),6,2), YEAR(@CurrentDate), MONTH(@CurrentDate))

		SET @CurrentDate = DATEADD(MM, 1, @CurrentDate) 

	END

	IF OBJECT_ID('tempdb..#M') IS NOT NULL DROP TABLE #M;
	SELECT DISTINCT M.GroupName TIN, D.MonthID
	INTO #M
	FROM dbo.MDGroup M
	OUTER APPLY (SELECT DISTINCT MonthID FROM #Dates) D
	WHERE CustID_Import = 11
	AND M.GroupName NOT IN ('XXXXXXXXX', 'dchpbeta1', 'dchpbeta2', 'dchpbeta3')
	AND M.GroupName <> ''
	ORDER BY TIN, MonthID

	IF OBJECT_ID('tempdb..#LoginsByTinByMonthID') IS NOT NULL DROP TABLE #LoginsByTinByMonthID;
	SELECT
	 M.TIN
	,M.MonthID
	,RIGHT(M.MonthID, 2) Mo
	,LEFT(M.MonthID,4) Yr
	,ISNULL(L.LoginsPerMonth,0) LoginsPerMonth
	,SUM(ISNULL(L.LoginsPerMonth,0)) OVER(PARTITION BY M.TIN, LEFT(M.MonthID,4) ORDER BY M.TIN, LEFT(M.MonthID,4), RIGHT(M.MonthID, 2) ROWS UNBOUNDED PRECEDING) AS CumulativeLoginsPerYear
	INTO #LoginsByTinByMonthID
	FROM #M M
	LEFT JOIN
	(
		SELECT 
		 TIN
		,MonthID
		,Yr
		,Mo
		,UserLogins AS LoginsPerMonth
		FROM 
		(
			 SELECT 
			 [UserTIN] TIN
			,LEFT(CAST(CAST(Created AS DATE) AS VARCHAR(10)), 4)+SUBSTRING(CAST(CAST(Created AS DATE) AS VARCHAR(10)),6,2) AS MonthID
			,YEAR(LEFT(CAST(CAST(Created AS DATE) AS VARCHAR(10)), 4)) AS Yr
			,SUBSTRING(CAST(CAST(Created AS DATE) AS VARCHAR(10)),6,2) AS Mo
			,COUNT([UserID]) AS UserLogIns
			FROM [dbo].[SSO_Log]
			WHERE action = 'Logged in' and created between @StartDate and @EndDate
			GROUP BY 
			 [UserTIN]
			,LEFT(CAST(CAST(Created AS DATE) AS VARCHAR(10)), 4)+SUBSTRING(CAST(CAST(Created AS DATE) AS VARCHAR(10)),6,2)
			,YEAR(LEFT(CAST(CAST(Created AS DATE) AS VARCHAR(10)), 4))
			,SUBSTRING(CAST(CAST(Created AS DATE) AS VARCHAR(10)),6,2)
		) L
	) L ON M.TIN = L.TIN AND M.MonthID = L.MonthID

	IF OBJECT_ID('tempdb..#LoginsByTinPerMonth') IS NOT NULL DROP TABLE #LoginsByTinPerMonth;
	SELECT
	 TIN
	,Yr
	,Mo
	,SUM(LoginsPerMonth) TotalLogins
	,CumulativeLoginsPerYear
	INTO #LoginsByTinPerMonth
	FROM #LoginsByTinByMonthID
	GROUP BY TIN, Yr, Mo, CumulativeLoginsPerYear

	CREATE NONCLUSTERED INDEX IX_LoginsByTinPerMonth_TotalLogins ON #LoginsByTinPerMonth ([TotalLogins]) INCLUDE ([TIN],[Yr],[Mo],[CumulativeLoginsPerYear])
	CREATE NONCLUSTERED INDEX IX_LoginsByTinPerMonth_CumulativeLoginsPerYear ON #LoginsByTinPerMonth ([CumulativeLoginsPerYear]) INCLUDE ([TIN],[Yr],[Mo])

	IF OBJECT_ID('tempdb..#Measure') IS NOT NULL DROP TABLE #Measure;
	CREATE TABLE #Measure (TIN NCHAR(100), MonthID CHAR(6), Yr VARCHAR(4), Mo VARCHAR(2), Numer INT, Denom INT)

	--IF @Measure = 'W15'
	--BEGIN
	--	INSERT INTO #Measure (TIN, MonthID, Yr, Mo, Numer, Denom)
	--	SELECT 	
	--	 TIN	
	--	,MonthID
	--	,LEFT(MonthID,4) Yr
	--	,RIGHT(MonthID,2) Mo
	--	,SUM(CASE WHEN IsComplete = 1 THEN 1 ELSE 0 END) AS [Numer]	
	--	,COUNT(*) AS [Denom]
	--	FROM [VD-RPT01].[_All_2015_Predictive_HEDIS].[dbo].[Final_W15Member]	
	--	WHERE CustID = 11	
	--	AND TIN NOT IN ('XXXXXXXXX', 'dchpbeta1', 'dchpbeta2', 'dchpbeta3')
	--	AND TIN <> ''
	--	AND DATEFROMPARTS(LEFT(MonthID,4), RIGHT(MonthID,2), '01') BETWEEN @StartDate AND @EndDate

	--	GROUP BY TIN, MonthID	
	--END

	--IF @Measure = 'W34'
	--BEGIN
	--	INSERT INTO #Measure (TIN, MonthID, Yr, Mo, Numer, Denom)
	--	SELECT 	
	--	 TIN	
	--	,MonthID
	--	,LEFT(MonthID,4) Yr
	--	,RIGHT(MonthID,2) Mo
	--	,SUM(CASE WHEN IsComplete = 1 THEN 1 ELSE 0 END) AS [Numer]	
	--	,COUNT(*) AS [Denom]
	--	FROM [VD-RPT01].[_All_2015_Predictive_HEDIS].[dbo].[Final_W34Member]	
	--	WHERE CustID = 11	
	--	AND TIN NOT IN ('XXXXXXXXX', 'dchpbeta1', 'dchpbeta2', 'dchpbeta3')
	--	AND TIN <> ''
	--	AND DATEFROMPARTS(LEFT(MonthID,4), RIGHT(MonthID,2), '01') BETWEEN @StartDate AND @EndDate
	--	GROUP BY TIN, MonthID	
	--END

	--IF @Measure = 'AWC'
	--BEGIN
	--	INSERT INTO #Measure (TIN, MonthID, Yr, Mo, Numer, Denom)
	--	SELECT 	
	--	 TIN	
	--	,MonthID
	--	,LEFT(MonthID,4) Yr
	--	,RIGHT(MonthID,2) Mo
	--	,SUM(CASE WHEN IsComplete = 1 THEN 1 ELSE 0 END) AS [Numer]
	--	,COUNT(*) AS [Denom]
	--	FROM [VD-RPT01].[_All_2015_Predictive_HEDIS].[dbo].[Final_AWCMember]	
	--	WHERE CustID = 11	
	--	AND TIN NOT IN ('XXXXXXXXX', 'dchpbeta1', 'dchpbeta2', 'dchpbeta3')
	--	AND TIN <> ''
	--	AND DATEFROMPARTS(LEFT(MonthID,4), RIGHT(MonthID,2), '01') BETWEEN @StartDate AND @EndDate
	--	GROUP BY TIN, MonthID	
	--END

		IF @Measure = 'W15'
	BEGIN
		INSERT INTO #Measure (TIN, MonthID, Yr, Mo, Numer, Denom)
		SELECT PCP_TIN, MonthID, LEFT(MonthID,4) Yr, RIGHT(MonthID,2) Mo, SUM(CASE WHEN IsTestDue = 1 THEN 1 ELSE 0 END) AS [Numer], COUNT(*) AS [Denom]
		FROM dbo.Final_HEDIS_Member_FULL F
		JOIN dbo.HedisSubmeasures S ON F.TestID = S.ID
		WHERE CustID = 11
		AND S.Abbreviation = @Measure
		AND PCP_TIN NOT IN ('XXXXXXXXX', 'dchpbeta1', 'dchpbeta2', 'dchpbeta3')
		AND PCP_TIN <> ''
		AND DATEFROMPARTS(LEFT(MonthID,4), RIGHT(MonthID,2), '01') BETWEEN @StartDate AND @EndDate
		GROUP BY PCP_TIN, MonthID	
	END

	IF @Measure = 'W34'
	BEGIN
		INSERT INTO #Measure (TIN, MonthID, Yr, Mo, Numer, Denom)
		SELECT PCP_TIN, MonthID, LEFT(MonthID,4) Yr, RIGHT(MonthID,2) Mo, SUM(CASE WHEN IsTestDue = 1 THEN 1 ELSE 0 END) AS [Numer], COUNT(*) AS [Denom]
		FROM dbo.Final_HEDIS_Member_FULL F
		JOIN dbo.HedisSubmeasures S ON F.TestID = S.ID
		WHERE CustID = 11
		AND S.Abbreviation = @Measure
		AND PCP_TIN NOT IN ('XXXXXXXXX', 'dchpbeta1', 'dchpbeta2', 'dchpbeta3')
		AND PCP_TIN <> ''
		AND DATEFROMPARTS(LEFT(MonthID,4), RIGHT(MonthID,2), '01') BETWEEN @StartDate AND @EndDate
		GROUP BY PCP_TIN, MonthID	
	END

	IF @Measure = 'AWC'
	BEGIN
		INSERT INTO #Measure (TIN, MonthID, Yr, Mo, Numer, Denom)
		SELECT PCP_TIN, MonthID, LEFT(MonthID,4) Yr, RIGHT(MonthID,2) Mo, SUM(CASE WHEN IsTestDue = 1 THEN 1 ELSE 0 END) AS [Numer], COUNT(*) AS [Denom]
		FROM dbo.Final_HEDIS_Member_FULL F
		JOIN dbo.HedisSubmeasures S ON F.TestID = S.ID
		WHERE CustID = 11
		AND S.Abbreviation = @Measure
		AND PCP_TIN NOT IN ('XXXXXXXXX', 'dchpbeta1', 'dchpbeta2', 'dchpbeta3')
		AND PCP_TIN <> ''
		AND DATEFROMPARTS(LEFT(MonthID,4), RIGHT(MonthID,2), '01') BETWEEN @StartDate AND @EndDate
		GROUP BY PCP_TIN, MonthID	
	END
	
	CREATE NONCLUSTERED INDEX IX_Denom ON #Measure ([Denom]) INCLUDE ([TIN],[Yr],[Mo],[Numer]);
	CREATE NONCLUSTERED INDEX IX_Denom_TIN_Yr_Mo ON #Measure ([TIN],[Yr],[Mo],[Denom]) INCLUDE ([Numer]);

		-- Total population
		SELECT
		 D.Yr
		,D.Mo
		,ISNULL(SUM([Numer]),0) Numer
		,ISNULL(SUM([Denom]),0) Denom
		,'Total population' AS [Login]
		,@Measure AS [Measure Type]
		,'Denom>'+cast(@Denom as varchar(2)) AS [Sub-Cat]
		FROM #Dates D
		LEFT JOIN #Measure M ON D.Yr = M.Yr AND D.Mo = M.Mo AND M.[Denom] > @Denom
		GROUP BY D.Yr, D.MO
		ORDER BY D.Yr, D.MO

		-- 0 Logins
		SELECT
		 D.Yr
		,D.Mo
		,ISNULL(SUM([Numer]),0) Numer
		,ISNULL(SUM([Denom]),0) Denom
		,'0 Logins' AS [Login]
		,@Measure AS [Measure Type]
		,'Denom>'+cast(@Denom as varchar(2)) AS [Sub-Cat]
		FROM #Dates D
		LEFT JOIN #Measure M ON D.Yr = M.Yr AND D.Mo = M.Mo AND M.[Denom] > @Denom
		AND EXISTS 
		(
			SELECT * 
			FROM #LoginsByTinPerMonth l
			WHERE l.CumulativeLoginsPerYear = 0
			AND l.TIN = M.TIN
			AND l.Yr = D.Yr
			AND l.Mo = D.MO
		)
		GROUP BY D.Yr, D.MO
		ORDER BY D.Yr, D.MO

		-- Logins >= 1
		SELECT
		 D.Yr
		,D.Mo
		,ISNULL(SUM([Numer]),0) Numer
		,ISNULL(SUM([Denom]),0) Denom
		,'Logins > 1' AS [Login]
		,@Measure AS [Measure Type]
		,'Denom>'+cast(@Denom as varchar(2)) AS [Sub-Cat]
		FROM #Dates D
		LEFT JOIN #Measure M ON D.Yr = M.Yr AND D.Mo = M.Mo AND M.[Denom] > @Denom
		AND EXISTS 
		(
			SELECT * 
			FROM #LoginsByTinPerMonth l
			WHERE l.CumulativeLoginsPerYear >= 1
			AND l.TIN = M.TIN
			AND l.Yr = D.Yr
			AND l.Mo = D.MO
		)
		GROUP BY D.Yr, D.MO
		ORDER BY D.Yr, D.MO

		-- Logins > 3
		SELECT
		 D.Yr
		,D.Mo
		,ISNULL(SUM([Numer]),0) Numer
		,ISNULL(SUM([Denom]),0) Denom
		,'Logins > 3' AS [Login]
		,@Measure AS [Measure Type]
		,'Denom>'+cast(@Denom as varchar(2)) AS [Sub-Cat]
		FROM #Dates D
		LEFT JOIN #Measure M ON D.Yr = M.Yr AND D.Mo = M.Mo AND M.[Denom] > @Denom
		AND EXISTS 
		(
			SELECT * 
			FROM #LoginsByTinPerMonth l
			WHERE l.CumulativeLoginsPerYear > 3
			AND l.TIN = M.TIN
			AND l.Yr = D.Yr
			AND l.Mo = D.MO
		)
		GROUP BY D.Yr, D.MO
		ORDER BY D.Yr, D.MO

		-- Logins > 6
		SELECT
		 D.Yr
		,D.Mo
		,ISNULL(SUM([Numer]),0) Numer
		,ISNULL(SUM([Denom]),0) Denom
		,'Logins > 6' AS [Login]
		,@Measure AS [Measure Type]
		,'Denom>'+cast(@Denom as varchar(2)) AS [Sub-Cat]
		FROM #Dates D
		LEFT JOIN #Measure M ON D.Yr = M.Yr AND D.Mo = M.Mo AND M.[Denom] > @Denom
		AND EXISTS 
		(
			SELECT * 
			FROM #LoginsByTinPerMonth l
			WHERE l.CumulativeLoginsPerYear > 6
			AND l.TIN = M.TIN
			AND l.Yr = D.Yr
			AND l.Mo = D.MO
		)
		GROUP BY D.Yr, D.MO
		ORDER BY D.Yr, D.MO

		-- Logins > 12
		SELECT
		 D.Yr
		,D.Mo
		,ISNULL(SUM([Numer]),0) Numer
		,ISNULL(SUM([Denom]),0) Denom
		,'Logins > 12' AS [Login]
		,@Measure AS [Measure Type]
		,'Denom>'+cast(@Denom as varchar(2)) AS [Sub-Cat]
		FROM #Dates D
		LEFT JOIN #Measure M ON D.Yr = M.Yr AND D.Mo = M.Mo AND M.[Denom] > @Denom
		AND EXISTS 
		(
			SELECT * 
			FROM #LoginsByTinPerMonth l
			WHERE l.CumulativeLoginsPerYear > 12
			AND l.TIN = M.TIN
			AND l.Yr = D.Yr
			AND l.Mo = D.MO
		)
		GROUP BY D.Yr, D.MO
		ORDER BY D.Yr, D.MO

		-- Logins 0 – 1
		SELECT
		 D.Yr
		,D.Mo
		,ISNULL(SUM([Numer]),0) Numer
		,ISNULL(SUM([Denom]),0) Denom
		,'Logins 0-1' AS [Login]
		,@Measure AS [Measure Type]
		,'Denom>'+cast(@Denom as varchar(2)) AS [Sub-Cat]
		FROM #Dates D
		LEFT JOIN #Measure M ON D.Yr = M.Yr AND D.Mo = M.Mo AND M.[Denom] > @Denom
		AND EXISTS 
		(
			SELECT * 
			FROM #LoginsByTinPerMonth l
			WHERE l.CumulativeLoginsPerYear BETWEEN 0 AND 1
			AND l.TIN = M.TIN
			AND l.Yr = D.Yr
			AND l.Mo = D.MO
		)
		GROUP BY D.Yr, D.MO
		ORDER BY D.Yr, D.MO

		-- Logins 2 – 3
		SELECT
		 D.Yr
		,D.Mo
		,ISNULL(SUM([Numer]),0) Numer
		,ISNULL(SUM([Denom]),0) Denom
		,'Logins 2-3' AS [Login]
		,@Measure AS [Measure Type]
		,'Denom>'+cast(@Denom as varchar(2)) AS [Sub-Cat]
		FROM #Dates D
		LEFT JOIN #Measure M ON D.Yr = M.Yr AND D.Mo = M.Mo AND M.[Denom] > @Denom
		AND EXISTS 
		(
			SELECT * 
			FROM #LoginsByTinPerMonth l
			WHERE l.CumulativeLoginsPerYear BETWEEN 2 AND 3
			AND l.TIN = M.TIN
			AND l.Yr = D.Yr
			AND l.Mo = D.MO
		)
		GROUP BY D.Yr, D.MO
		ORDER BY D.Yr, D.MO

		-- Logns 4 – 6
		SELECT
		 D.Yr
		,D.Mo
		,ISNULL(SUM([Numer]),0) Numer
		,ISNULL(SUM([Denom]),0) Denom
		,'Logins 4-6' AS [Login]
		,@Measure AS [Measure Type]
		,'Denom>'+cast(@Denom as varchar(2)) AS [Sub-Cat]
		FROM #Dates D
		LEFT JOIN #Measure M ON D.Yr = M.Yr AND D.Mo = M.Mo AND M.[Denom] > @Denom
		AND EXISTS 
		(
			SELECT * 
			FROM #LoginsByTinPerMonth l
			WHERE l.CumulativeLoginsPerYear BETWEEN 4 AND 6
			AND l.TIN = M.TIN
			AND l.Yr = D.Yr
			AND l.Mo = D.MO
		)
		GROUP BY D.Yr, D.MO
		ORDER BY D.Yr, D.MO

		-- Logins 7-12
		SELECT
		 D.Yr
		,D.Mo
		,ISNULL(SUM([Numer]),0) Numer
		,ISNULL(SUM([Denom]),0) Denom
		,'Logins 7-12' AS [Login]
		,@Measure AS [Measure Type]
		,'Denom>'+cast(@Denom as varchar(2)) AS [Sub-Cat]
		FROM #Dates D
		LEFT JOIN #Measure M ON D.Yr = M.Yr AND D.Mo = M.Mo AND M.[Denom] > @Denom
		AND EXISTS 
		(
			SELECT * 
			FROM #LoginsByTinPerMonth l
			WHERE l.CumulativeLoginsPerYear BETWEEN 7 AND 12
			AND l.TIN = M.TIN
			AND l.Yr = D.Yr
			AND l.Mo = D.MO
		)
		GROUP BY D.Yr, D.MO
		ORDER BY D.Yr, D.MO

		-- Logins >= 13
		SELECT
		 D.Yr
		,D.Mo
		,ISNULL(SUM([Numer]),0) Numer
		,ISNULL(SUM([Denom]),0) Denom
		,'Logins >= 13' AS [Login]
		,@Measure AS [Measure Type]
		,'Denom>'+cast(@Denom as varchar(2)) AS [Sub-Cat]
		FROM #Dates D
		LEFT JOIN #Measure M ON D.Yr = M.Yr AND D.Mo = M.Mo AND M.[Denom] > @Denom
		AND EXISTS 
		(
			SELECT * 
			FROM #LoginsByTinPerMonth l
			WHERE l.CumulativeLoginsPerYear >= 13
			AND l.TIN = M.TIN
			AND l.Yr = D.Yr
			AND l.Mo = D.MO
		)
		GROUP BY D.Yr, D.MO
		ORDER BY D.Yr, D.MO

END