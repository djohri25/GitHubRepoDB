/****** Object:  Procedure [Rules].[Rolling12MonthVistRollup]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		Marc De Luca	
-- Create date: 02/27/2017
-- Description:	Populated Rules.MainPersonalStats
-- Example:	EXEC Rules.Rolling12MonthVistRollup
-- =============================================
CREATE PROCEDURE [Rules].[Rolling12MonthVistRollup]
	@Cust_ID INT = NULL
AS
BEGIN

	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET NOCOUNT ON;

	DECLARE 
	 @StartDate DATE = GETDATE()
	,@EndDate DATE
	,@RollingMonths INT = 14
	,@CurrentMonth DATE
	,@MaxMonth10 INT
	,@MaxMonth11 INT
	,@MaxMonth13 INT
	,@MaxMonth14 INT


	SELECT @EndDate = DATEADD(MM, -1, DATEFROMPARTS(YEAR(@StartDate),MONTH(@StartDate),'01'))

	SELECT @StartDate = DATEADD(MM, -@RollingMonths, @StartDate)

	SELECT @StartDate = DATEFROMPARTS(YEAR(@StartDate),MONTH(@StartDate),'01')

	SELECT @CurrentMonth = @StartDate

	IF (OBJECT_ID('tempdb..#M') IS NOT NULL) DROP TABLE #M
	CREATE TABLE #M (MonthID CHAR(6))

	WHILE @CurrentMonth <= @EndDate
	BEGIN

		INSERT INTO #M (MonthID)
		SELECT CAST(YEAR(@CurrentMonth) AS CHAR(4))+CASE WHEN LEN(CAST(MONTH(@CurrentMonth) AS CHAR(2))) = 1 THEN '0'+CAST(MONTH(@CurrentMonth) AS CHAR(2)) ELSE CAST(MONTH(@CurrentMonth) AS CHAR(2)) END

		SET @CurrentMonth = DATEADD(MM, 1, @CurrentMonth) 

	END

	IF (OBJECT_ID('tempdb..#IP') IS NOT NULL) DROP TABLE #IP;
	CREATE TABLE #IP (MVDID VARCHAR(30) );

	IF (OBJECT_ID('tempdb..#DM') IS NOT NULL) DROP TABLE #DM;
	CREATE TABLE #DM (Cust_ID INT, MVDId VARCHAR(30), MemberID VARCHAR(20), MonthID CHAR(6) );

	-- PCP
	IF (OBJECT_ID('tempdb..#PCP') IS NOT NULL) DROP TABLE #PCP
	SELECT I.Cust_ID, I.MVDId, I.InsMemberId AS MemberID, YEAR(VisitDate) AS VisitYear, MONTH(VisitDate) AS VisitMonth, COUNT(*) PCPVisits, 0 IsProcessed
	INTO #PCP
	FROM dbo.EDVisitHistory ED
	JOIN dbo.Link_MemberId_MVD_Ins I ON ED.ICENUMBER = I.MVDID
	WHERE ICENUMBER IS NOT NULL
	AND I.Cust_ID IN (10,11,13,14)
	AND (@Cust_ID IS NULL OR I.Cust_ID = @Cust_ID)
	AND VisitType = 'Physician'
	AND VisitDate >= DATEADD(MM, -@RollingMonths, @StartDate)
	AND VisitDate < DATEADD(DD, 1, GETDATE())
	GROUP BY I.Cust_ID, I.MVDId, I.InsMemberId, YEAR(VisitDate), MONTH(VisitDate)

	CREATE NONCLUSTERED INDEX [IX_PCP_MVDId_MemberID] ON #PCP ([MVDId],[MemberID])
	CREATE NONCLUSTERED INDEX [IX_PCP_IsProcessed] ON #PCP (IsProcessed) INCLUDE (MVDId)
	CREATE NONCLUSTERED INDEX [IX_Cust_ID] ON #PCP ([Cust_ID]) INCLUDE ([VisitYear],[VisitMonth])
	CREATE NONCLUSTERED INDEX IX_ICENUMBER_IsProcessed ON #PCP (Cust_ID, MVDId, MemberID, IsProcessed)

	SELECT @MaxMonth10 = MAX(MonthID) FROM dbo.Final_ALLMember WHERE CUstid = 10
	SELECT @MaxMonth11 = MAX(MonthID) FROM dbo.Final_ALLMember WHERE CUstid = 11
	SELECT @MaxMonth13 = MAX(MonthID) FROM dbo.Final_ALLMember WHERE CUstid = 13
	SELECT @MaxMonth14 = MAX(MonthID) FROM dbo.Final_ALLMember WHERE CUstid = 14

	DELETE FROM #PCP WHERE Cust_ID = 10 AND CAST(VisitYear AS CHAR(4))+CASE WHEN LEN(VisitMonth) = 1 THEN '0'+CAST(VisitMonth AS CHAR(1)) ELSE CAST(VisitMonth AS CHAR(2)) END > @MaxMonth10
	DELETE FROM #PCP WHERE Cust_ID = 11 AND CAST(VisitYear AS CHAR(4))+CASE WHEN LEN(VisitMonth) = 1 THEN '0'+CAST(VisitMonth AS CHAR(1)) ELSE CAST(VisitMonth AS CHAR(2)) END > @MaxMonth11
	DELETE FROM #PCP WHERE Cust_ID = 13 AND CAST(VisitYear AS CHAR(4))+CASE WHEN LEN(VisitMonth) = 1 THEN '0'+CAST(VisitMonth AS CHAR(1)) ELSE CAST(VisitMonth AS CHAR(2)) END > @MaxMonth13
	DELETE FROM #PCP WHERE Cust_ID = 14 AND CAST(VisitYear AS CHAR(4))+CASE WHEN LEN(VisitMonth) = 1 THEN '0'+CAST(VisitMonth AS CHAR(1)) ELSE CAST(VisitMonth AS CHAR(2)) END > @MaxMonth14

	WHILE EXISTS (SELECT * FROM #PCP WHERE IsProcessed = 0)
	BEGIN

		TRUNCATE TABLE #IP
		INSERT INTO #IP (MVDID)
		SELECT DISTINCT TOP (50000) MVDID -- Take 50000 at a time
		FROM #PCP
		WHERE IsProcessed = 0

		TRUNCATE TABLE #DM		
		INSERT INTO #DM (Cust_ID, MVDID, MemberID, MonthID)
		SELECT DISTINCT I.Cust_ID, I.MVDId, I.InsMemberId AS MemberID, M.MonthID
		FROM #M M
		CROSS JOIN #PCP E
		JOIN dbo.Link_MemberId_MVD_Ins I ON E.MVDID = I.MVDID AND E.MemberID = I.InsMemberId
		WHERE EXISTS (SELECT * FROM #IP WHERE MVDID = E.MVDID)

		IF (OBJECT_ID('tempdb..#Final1') IS NOT NULL) DROP TABLE #Final1;
		SELECT D.Cust_ID, D.MVDId, D.MemberID, D.MonthID, ISNULL(E.PCPVisits,0) PCPVisits, ROW_NUMBER() OVER (PARTITION BY D.Cust_ID, D.MVDId, D.MemberID ORDER BY D.MonthID) RowNum
		INTO #Final1
		FROM #DM D
		LEFT JOIN #PCP E ON D.Cust_ID = E.Cust_ID AND D.MVDId = E.MVDId AND D.MemberID = E.MemberID
		AND D.MonthID = CAST(E.VisitYear AS CHAR(4))+CASE WHEN LEN(VisitMonth) = 1 THEN '0'+CAST(VisitMonth AS CHAR(1)) ELSE CAST(VisitMonth AS CHAR(2)) END

		IF (OBJECT_ID('tempdb..#Totals1') IS NOT NULL) DROP TABLE #Totals1;
		SELECT Cust_ID, MVDId, MemberID, MonthID
		,Rolling12MonthPhysicianVisits = CASE WHEN RowNum BETWEEN RowNum-11 AND RowNum THEN SUM(PCPVisits) OVER (PARTITION BY Cust_ID, MVDId, MemberID ORDER BY MonthID ROWS BETWEEN 11 PRECEDING AND CURRENT ROW) END
		INTO #Totals1
		FROM #Final1 F

		CREATE NONCLUSTERED INDEX [IX_Rolling12MonthPhysicianVisits] ON #Totals1 ([Rolling12MonthPhysicianVisits])
		CREATE NONCLUSTERED INDEX IX_Cust_ID_ICENUMBER_MonthID_Rolling12MonthPhysicianVisits ON #Totals1 (Cust_ID, MVDId, MemberID, MonthID) INCLUDE (Rolling12MonthPhysicianVisits) 

		DELETE FROM #Totals1 WHERE Rolling12MonthPhysicianVisits = 0

		DELETE FROM #Totals1 WHERE MonthID NOT IN (SELECT DISTINCT TOP (2) MonthID FROM #Totals1 ORDER BY MonthID DESC)

		MERGE Rules.MainPersonalStats AS target  
		USING 
		(
			SELECT Cust_ID, MVDId, MemberID, MonthID, Rolling12MonthPhysicianVisits
			FROM #Totals1
			 ) AS source (Cust_ID, MVDId, MemberID, MonthID, Rolling12MonthPhysicianVisits)
			ON (target.Cust_ID = source.Cust_ID AND target.MVDId = source.MVDId and target.MemberID = source.MemberID and target.MonthID = source.MonthID)  
			WHEN MATCHED THEN   
				UPDATE 
				SET Target.Rolling12MonthPhysicianVisits = Source.Rolling12MonthPhysicianVisits
				,Target.ModifyDate = GETDATE()
		WHEN NOT MATCHED THEN  
			INSERT (Cust_ID, MVDId, MemberID, MonthID, Rolling12MonthPhysicianVisits)  
			VALUES (source.Cust_ID, source.MVDId, source.MemberID, source.MonthID, source.Rolling12MonthPhysicianVisits);

		UPDATE PCP
		SET IsProcessed = 1
		FROM #PCP PCP
		WHERE EXISTS (SELECT * FROM #IP WHERE MVDId = PCP.MVDId)
		AND IsProcessed = 0

	END

	-- ER
	IF (OBJECT_ID('tempdb..#ER') IS NOT NULL) DROP TABLE #ER
	SELECT I.Cust_ID, I.MVDId, I.InsMemberId AS MemberID, YEAR(VisitDate) AS VisitYear, MONTH(VisitDate) AS VisitMonth, COUNT(*) ERVisits, 0 IsProcessed
	INTO #ER
	FROM dbo.EDVisitHistory ED
	JOIN dbo.Link_MemberId_MVD_Ins I ON ED.ICENUMBER = I.MVDID
	WHERE ICENUMBER IS NOT NULL
	AND I.Cust_ID IN (10,11,13,14)
	AND (@Cust_ID IS NULL OR I.Cust_ID = @Cust_ID)
	AND VisitType = 'ER'
	AND VisitDate >= DATEADD(MM, -@RollingMonths, @StartDate)
	AND VisitDate < DATEADD(DD, 1, GETDATE())
	GROUP BY I.Cust_ID, I.MVDId, I.InsMemberId, YEAR(VisitDate), MONTH(VisitDate)

	CREATE NONCLUSTERED INDEX [IX_Cust_ID_VisitYear_VisitMonth] ON #ER ([Cust_ID]) INCLUDE ([VisitYear],[VisitMonth])
	CREATE NONCLUSTERED INDEX IX_ICENUMBER_IsProcessed ON #ER (Cust_ID, MVDId, MemberID, IsProcessed)

	DELETE FROM #ER WHERE Cust_ID = 10 AND CAST(VisitYear AS CHAR(4))+CASE WHEN LEN(VisitMonth) = 1 THEN '0'+CAST(VisitMonth AS CHAR(1)) ELSE CAST(VisitMonth AS CHAR(2)) END > @MaxMonth10
	DELETE FROM #ER WHERE Cust_ID = 11 AND CAST(VisitYear AS CHAR(4))+CASE WHEN LEN(VisitMonth) = 1 THEN '0'+CAST(VisitMonth AS CHAR(1)) ELSE CAST(VisitMonth AS CHAR(2)) END > @MaxMonth11
	DELETE FROM #ER WHERE Cust_ID = 13 AND CAST(VisitYear AS CHAR(4))+CASE WHEN LEN(VisitMonth) = 1 THEN '0'+CAST(VisitMonth AS CHAR(1)) ELSE CAST(VisitMonth AS CHAR(2)) END > @MaxMonth13
	DELETE FROM #ER WHERE Cust_ID = 14 AND CAST(VisitYear AS CHAR(4))+CASE WHEN LEN(VisitMonth) = 1 THEN '0'+CAST(VisitMonth AS CHAR(1)) ELSE CAST(VisitMonth AS CHAR(2)) END > @MaxMonth14

	WHILE EXISTS (SELECT * FROM #ER WHERE IsProcessed = 0)
	BEGIN

		TRUNCATE TABLE #IP
		INSERT INTO #IP (MVDID)
		SELECT DISTINCT TOP (50000) MVDID -- Take 50000 at a time
		FROM #ER
		WHERE IsProcessed = 0

		TRUNCATE TABLE #DM		
		INSERT INTO #DM (Cust_ID, MVDID, MemberID, MonthID)
		SELECT DISTINCT I.Cust_ID, I.MVDId, I.InsMemberId AS MemberID, M.MonthID
		FROM #M M
		CROSS JOIN #ER E
		JOIN dbo.Link_MemberId_MVD_Ins I ON E.MVDID = I.MVDID AND E.MemberID = I.InsMemberId
		WHERE EXISTS (SELECT * FROM #IP WHERE MVDID = E.MVDID)

		IF (OBJECT_ID('tempdb..#Final2') IS NOT NULL) DROP TABLE #Final2;
		SELECT D.Cust_ID, D.MVDId, D.MemberID, D.MonthID, ISNULL(E.ERVisits,0) ERVisits, ROW_NUMBER() OVER (PARTITION BY D.Cust_ID, D.MVDId, D.MemberID ORDER BY D.MonthID) RowNum
		INTO #Final2
		FROM #DM D
		LEFT JOIN #ER E ON D.Cust_ID = E.Cust_ID AND D.MVDId = E.MVDId AND D.MemberID = E.MemberID
		AND D.MonthID = CAST(E.VisitYear AS CHAR(4))+CASE WHEN LEN(VisitMonth) = 1 THEN '0'+CAST(VisitMonth AS CHAR(1)) ELSE CAST(VisitMonth AS CHAR(2)) END

		IF (OBJECT_ID('tempdb..#Totals2') IS NOT NULL) DROP TABLE #Totals2;
		SELECT Cust_ID, MVDId, MemberID, MonthID
		,Rolling12MonthERVisits = CASE WHEN RowNum BETWEEN RowNum-11 AND RowNum THEN SUM(ERVisits) OVER (PARTITION BY Cust_ID, MVDId, MemberID ORDER BY MonthID ROWS BETWEEN 11 PRECEDING AND CURRENT ROW) END
		INTO #Totals2
		FROM #Final2 F

		CREATE NONCLUSTERED INDEX [IX_Rolling12MonthERVisits] ON #Totals2([Rolling12MonthERVisits])
		CREATE NONCLUSTERED INDEX IX_Cust_ID_ICENUMBER_MonthID_Rolling12MonthERVisits ON #Totals2 (Cust_ID, MVDId, MemberID, MonthID) INCLUDE (Rolling12MonthERVisits) 

		DELETE FROM #Totals2 WHERE Rolling12MonthERVisits = 0

		DELETE FROM #Totals2 WHERE MonthID NOT IN (SELECT DISTINCT TOP (2) MonthID FROM #Totals2 ORDER BY MonthID DESC)

		MERGE Rules.MainPersonalStats AS target  
		USING 
		(
			SELECT Cust_ID, MVDId, MemberID, MonthID, Rolling12MonthERVisits
			FROM #Totals2
			 ) AS source (Cust_ID, MVDId, MemberID, MonthID, Rolling12MonthERVisits)
			ON (target.Cust_ID = source.Cust_ID AND target.MVDId = source.MVDId and target.MemberID = source.MemberID and target.MonthID = source.MonthID)  
			WHEN MATCHED THEN   
				UPDATE 
				SET Target.Rolling12MonthERVisits = Source.Rolling12MonthERVisits
					,Target.ModifyDate = GETDATE()
		WHEN NOT MATCHED THEN  
			INSERT (Cust_ID, MVDId, MemberID, MonthID, Rolling12MonthERVisits)  
			VALUES (source.Cust_ID, source.MVDId, source.MemberID, source.MonthID, source.Rolling12MonthERVisits);

		UPDATE ER
		SET IsProcessed = 1
		FROM #ER ER
		WHERE EXISTS (SELECT * FROM #IP WHERE MVDId = ER.MVDId)
		AND IsProcessed = 0

	END

	-- LAB
	IF (OBJECT_ID('tempdb..#LAB') IS NOT NULL) DROP TABLE #LAB
	SELECT I.Cust_ID, I.MVDId, I.InsMemberId AS MemberID, YEAR(VisitDate) AS VisitYear, MONTH(VisitDate) AS VisitMonth, COUNT(*) LABVisits, 0 IsProcessed
	INTO #LAB
	FROM dbo.EDVisitHistory ED
	JOIN dbo.Link_MemberId_MVD_Ins I ON ED.ICENUMBER = I.MVDID
	WHERE ICENUMBER IS NOT NULL
	AND I.Cust_ID IN (10,11,13,14)
	AND (@Cust_ID IS NULL OR I.Cust_ID = @Cust_ID)
	AND VisitType = 'LAB'
	AND VisitDate >= DATEADD(MM, -@RollingMonths, @StartDate)
	AND VisitDate < DATEADD(DD, 1, GETDATE())
	GROUP BY I.Cust_ID, I.MVDId, I.InsMemberId, YEAR(VisitDate), MONTH(VisitDate)

	CREATE NONCLUSTERED INDEX [IX_IsProcessed] ON #LAB ([IsProcessed]) INCLUDE ([MVDId])
	CREATE NONCLUSTERED INDEX IX_ICENUMBER_IsProcessed ON #LAB (Cust_ID, MVDId, MemberID, IsProcessed)
	CREATE NONCLUSTERED INDEX [IX_Cust_ID_VisitYear_VisitMonth] ON #LAB ([Cust_ID]) INCLUDE ([VisitYear],[VisitMonth])

	DELETE FROM #LAB WHERE Cust_ID = 10 AND CAST(VisitYear AS CHAR(4))+CASE WHEN LEN(VisitMonth) = 1 THEN '0'+CAST(VisitMonth AS CHAR(1)) ELSE CAST(VisitMonth AS CHAR(2)) END > @MaxMonth10
	DELETE FROM #LAB WHERE Cust_ID = 11 AND CAST(VisitYear AS CHAR(4))+CASE WHEN LEN(VisitMonth) = 1 THEN '0'+CAST(VisitMonth AS CHAR(1)) ELSE CAST(VisitMonth AS CHAR(2)) END > @MaxMonth11
	DELETE FROM #LAB WHERE Cust_ID = 13 AND CAST(VisitYear AS CHAR(4))+CASE WHEN LEN(VisitMonth) = 1 THEN '0'+CAST(VisitMonth AS CHAR(1)) ELSE CAST(VisitMonth AS CHAR(2)) END > @MaxMonth13
	DELETE FROM #LAB WHERE Cust_ID = 14 AND CAST(VisitYear AS CHAR(4))+CASE WHEN LEN(VisitMonth) = 1 THEN '0'+CAST(VisitMonth AS CHAR(1)) ELSE CAST(VisitMonth AS CHAR(2)) END > @MaxMonth14

	WHILE EXISTS (SELECT * FROM #LAB WHERE IsProcessed = 0)
	BEGIN

		TRUNCATE TABLE #IP
		INSERT INTO #IP (MVDID)
		SELECT DISTINCT TOP (50000) MVDID -- Take 50000 at a time
		FROM #LAB
		WHERE IsProcessed = 0

		TRUNCATE TABLE #DM		
		INSERT INTO #DM (Cust_ID, MVDID, MemberID, MonthID)
		SELECT DISTINCT I.Cust_ID, I.MVDId, I.InsMemberId AS MemberID, M.MonthID
		FROM #M M
		CROSS JOIN #LAB E
		JOIN dbo.Link_MemberId_MVD_Ins I ON E.MVDID = I.MVDID AND E.MemberID = I.InsMemberId
		WHERE EXISTS (SELECT * FROM #IP WHERE MVDID = E.MVDID)

		IF (OBJECT_ID('tempdb..#Final3') IS NOT NULL) DROP TABLE #Final3
		SELECT D.Cust_ID, D.MVDId, D.MemberID, D.MonthID, ISNULL(E.LABVisits,0) LABVisits, ROW_NUMBER() OVER (PARTITION BY D.Cust_ID, D.MVDId, D.MemberID ORDER BY D.MonthID) RowNum
		INTO #Final3
		FROM #DM D
		LEFT JOIN #LAB E ON D.Cust_ID = E.Cust_ID AND D.MVDId = E.MVDId AND D.MemberID = E.MemberID
		AND D.MonthID = CAST(E.VisitYear AS CHAR(4))+CASE WHEN LEN(VisitMonth) = 1 THEN '0'+CAST(VisitMonth AS CHAR(1)) ELSE CAST(VisitMonth AS CHAR(2)) END

		IF (OBJECT_ID('tempdb..#Totals3') IS NOT NULL) DROP TABLE #Totals3
		SELECT Cust_ID, MVDId, MemberID, MonthID
		,Rolling12MonthLABVisits = CASE WHEN RowNum BETWEEN RowNum-11 AND RowNum THEN SUM(LABVisits) OVER (PARTITION BY Cust_ID, MVDId, MemberID ORDER BY MonthID ROWS BETWEEN 11 PRECEDING AND CURRENT ROW) END
		INTO #Totals3
		FROM #Final3 F

		CREATE NONCLUSTERED INDEX [IX_Rolling12MonthLABVisits] ON #Totals3 ([Rolling12MonthLABVisits])
		CREATE NONCLUSTERED INDEX IX_Cust_ID_ICENUMBER_MonthID_Rolling12MonthLABVisits ON #Totals3 (Cust_ID, MVDId, MemberID, MonthID) INCLUDE (Rolling12MonthLABVisits) 
		
		DELETE FROM #Totals3 WHERE Rolling12MonthLABVisits = 0
		DELETE FROM #Totals3 WHERE MonthID NOT IN (SELECT DISTINCT TOP (2) MonthID FROM #Totals3 ORDER BY MonthID DESC)

		MERGE Rules.MainPersonalStats AS target  
		USING 
		(
			SELECT Cust_ID, MVDId, MemberID, MonthID, Rolling12MonthLABVisits
			FROM #Totals3
			 ) AS source (Cust_ID, MVDId, MemberID, MonthID, Rolling12MonthLABVisits)
			ON (target.Cust_ID = source.Cust_ID AND target.MVDId = source.MVDId and target.MemberID = source.MemberID and target.MonthID = source.MonthID)  
			WHEN MATCHED THEN   
				UPDATE 
				SET Target.Rolling12MonthLABVisits = Source.Rolling12MonthLABVisits
				,Target.ModifyDate = GETDATE()
		WHEN NOT MATCHED THEN  
			INSERT (Cust_ID, MVDId, MemberID, MonthID, Rolling12MonthLABVisits)  
			VALUES (source.Cust_ID, source.MVDId, source.MemberID, source.MonthID, source.Rolling12MonthLABVisits);

		UPDATE LAB
		SET IsProcessed = 1
		FROM #LAB LAB
		WHERE EXISTS (SELECT * FROM #IP WHERE MVDId = LAB.MVDId)
		AND IsProcessed = 0

	END

END