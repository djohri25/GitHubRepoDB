/****** Object:  Procedure [Rules].[LastVistRollup]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		Marc De Luca	
-- Create date: 02/27/2017
-- Description:	Populated Rules.MainPersonalStats
-- Example:	EXEC Rules.LastVistRollup
-- =============================================
CREATE PROCEDURE [Rules].[LastVistRollup]
	@Cust_ID INT = NULL
AS
BEGIN

	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET NOCOUNT ON;

	DECLARE @MaxMonth10 INT, @MaxMonth11 INT, @MaxMonth13 INT, @MaxMonth14 INT

	SELECT @MaxMonth10 = MAX(MonthID) FROM dbo.Final_ALLMember WHERE CustID = 10
	SELECT @MaxMonth11 = MAX(MonthID) FROM dbo.Final_ALLMember WHERE CustID = 11
	SELECT @MaxMonth13 = MAX(MonthID) FROM dbo.Final_ALLMember WHERE CustID = 13
	SELECT @MaxMonth14 = MAX(MonthID) FROM dbo.Final_ALLMember WHERE CustID = 14

	-- Last drug dispensed date
	IF (OBJECT_ID('tempdb..#D1') IS NOT NULL) DROP TABLE #D1
	SELECT DISTINCT I.Cust_ID, I.MVDId, I.InsMemberId AS MemberID
	,MonthID = CAST(M.Yr AS CHAR(4))+CASE WHEN LEN(M.Mo) = 1 THEN '0'+CAST(M.Mo AS CHAR(1)) ELSE CAST(M.Mo AS CHAR(2)) END
	,CAST(MAX(M.LastDrugDispensedDate) AS DATE) AS LastDrugDispensedDate
	INTO #D1
	FROM
	(
		SELECT ICENUMBER, YEAR(StartDate) AS Yr, MONTH(StartDate) AS Mo, MAX(StartDate) AS LastDrugDispensedDate
		FROM dbo.MainMedication
		WHERE StartDate >= DATEADD(MM, -2, GETDATE())
		AND StartDate < DATEADD(DD, 1, GETDATE())
		GROUP BY ICENUMBER, YEAR(StartDate), MONTH(StartDate)
	) M
	JOIN dbo.Link_MemberId_MVD_Ins I ON M.ICENUMBER = I.MVDID
	WHERE I.Cust_ID IN (10,11,13,14)
	AND (@Cust_ID IS NULL OR I.Cust_ID = @Cust_ID)
	GROUP BY I.Cust_ID, I.MVDID, I.InsMemberId, CAST(M.Yr AS CHAR(4))+CASE WHEN LEN(M.Mo) = 1 THEN '0'+CAST(M.Mo AS CHAR(1)) ELSE CAST(M.Mo AS CHAR(2)) END
	ORDER BY I.Cust_ID, I.MVDID, I.InsMemberId, CAST(M.Yr AS CHAR(4))+CASE WHEN LEN(M.Mo) = 1 THEN '0'+CAST(M.Mo AS CHAR(1)) ELSE CAST(M.Mo AS CHAR(2)) END

	DELETE FROM #D1 WHERE Cust_ID = 10 AND MonthID > @MaxMonth10
	DELETE FROM #D1 WHERE Cust_ID = 11 AND MonthID > @MaxMonth11
	DELETE FROM #D1 WHERE Cust_ID = 13 AND MonthID > @MaxMonth13
	DELETE FROM #D1 WHERE Cust_ID = 14 AND MonthID > @MaxMonth14

	CREATE INDEX IX_Cust_ID_MVDId_MonthID ON #D1 (Cust_ID, MVDId, MemberID, MonthID)

	MERGE Rules.MainPersonalStats AS target  
	USING 
	(
		SELECT Cust_ID, MVDId, MemberID, MonthID, LastDrugDispensedDate
		FROM #D1
		 ) AS source (Cust_ID, MVDId, MemberID, MonthID, LastDrugDispensedDate)
		ON (target.Cust_ID = source.Cust_ID AND target.MVDId = source.MVDId and target.MemberID = source.MemberID and target.MonthID = source.MonthID)  
		WHEN MATCHED THEN   
			UPDATE 
			SET Target.LastDrugDispensedDate = Source.LastDrugDispensedDate
			,Target.ModifyDate = GETDATE()
	WHEN NOT MATCHED THEN  
		INSERT (Cust_ID, MVDId, MemberID, MonthID, LastDrugDispensedDate)  
		VALUES (source.Cust_ID, source.MVDId, source.MemberID, source.MonthID, source.LastDrugDispensedDate);

	-- Update all the NULL months with the most recent LastDrugDispensedDate
	IF (OBJECT_ID('tempdb..#LD1') IS NOT NULL) DROP TABLE #LD1
	SELECT DISTINCT Cust_ID, MVDID, MemberID, 0 IsProcessed
	INTO #LD1
	FROM Rules.MainPersonalStats
	WHERE LastDrugDispensedDate IS NOT NULL
	AND MVDID IN (SELECT MVDId FROM #D1)

	WHILE EXISTS (SELECT * FROM #LD1 WHERE IsProcessed = 0)
	BEGIN

		IF (OBJECT_ID('tempdb..#IP1') IS NOT NULL) DROP TABLE #IP1
		SELECT DISTINCT TOP (50000) Cust_ID, MVDID, MemberID -- Take 50000 at a time
		INTO #IP1
		FROM #LD1
		WHERE IsProcessed = 0

		CREATE CLUSTERED INDEX IX_Cust_ID_MVDID_MemberID ON #IP1 (Cust_ID, MVDID, MemberID)

		IF (OBJECT_ID('tempdb..#FinalD') IS NOT NULL) DROP TABLE #FinalD
		SELECT M.Cust_ID, M.MVDID, M.MemberID, M.MonthID, MAX(LD.LastDrugDispensedDate) LastDrugDispensedDate
		INTO #FinalD
		FROM Rules.MainPersonalStats AS M WITH(NOLOCK)
		LEFT JOIN
		(
			SELECT S.Cust_ID, S.MVDID, S.MemberID, S.MonthID, S.LastDrugDispensedDate
			FROM Rules.MainPersonalStats S WITH(NOLOCK)
			WHERE S.LastDrugDispensedDate IS NOT NULL
			AND EXISTS (SELECT * FROM #IP1 WHERE Cust_ID = S.Cust_ID AND MVDID = S.MVDID AND MemberID = S.MemberID)
		) LD ON M.Cust_ID = LD.Cust_ID AND M.MVDID = LD.MVDID AND M.MemberID = LD.MemberID AND M.MonthID >= LD.MonthID
		WHERE EXISTS (SELECT * FROM #IP1 WHERE Cust_ID = M.Cust_ID AND MVDID = M.MVDID AND MemberID = M.MemberID)
		GROUP BY M.Cust_ID, M.MVDID, M.MemberID, M.MonthID
		ORDER BY M.Cust_ID, M.MVDID, M.MemberID, M.MonthID

		UPDATE M
		SET M.LastDrugDispensedDate = F.LastDrugDispensedDate
		FROM #FinalD F
		JOIN Rules.MainPersonalStats M ON F.Cust_ID = M.Cust_ID AND F.MVDID = M.MVDID AND F.MemberID = M.MemberID AND F.MonthID = M.MonthID
		WHERE M.LastDrugDispensedDate IS NULL

		UPDATE LD
		SET IsProcessed = 1
		FROM #LD1 LD
		WHERE EXISTS (SELECT * FROM #IP1 WHERE Cust_ID = LD.Cust_ID AND MVDID = LD.MVDID AND MemberID = LD.MemberID)
		AND IsProcessed = 0

	END

	-- Last ER visit
	IF (OBJECT_ID('tempdb..#XER') IS NOT NULL) DROP TABLE #XER
	SELECT DISTINCT 
	 I.Cust_ID
	,I.MVDID
	,I.InsMemberId AS MemberID
	,MonthID = CAST(YEAR(E.VisitDate) AS CHAR(4))+CASE WHEN LEN(MONTH(E.VisitDate)) = 1 THEN '0'+CAST(MONTH(E.VisitDate) AS CHAR(1)) ELSE CAST(MONTH(E.VisitDate) AS CHAR(2)) END
	,CAST(MAX(E.VisitDate) AS DATE) AS LastERVisit
	INTO #XER
	FROM dbo.EDVisitHistory E
	JOIN dbo.Link_MemberId_MVD_Ins I ON E.ICENUMBER = I.MVDID
	WHERE E.VisitDate >= DATEADD(MM, -2, GETDATE())
	AND E.VisitDate < DATEADD(DD, 1, GETDATE())
	AND E.VisitType = 'ER'
	AND I.Cust_ID IN (10,11,13,14)
	AND (@Cust_ID IS NULL OR I.Cust_ID = @Cust_ID)
	GROUP BY I.Cust_ID, I.MVDID, I.InsMemberId, CAST(YEAR(E.VisitDate) AS CHAR(4))+CASE WHEN LEN(MONTH(E.VisitDate)) = 1 THEN '0'+CAST(MONTH(E.VisitDate) AS CHAR(1)) ELSE CAST(MONTH(E.VisitDate) AS CHAR(2)) END
	ORDER BY I.Cust_ID, I.MVDID, I.InsMemberId, CAST(YEAR(E.VisitDate) AS CHAR(4))+CASE WHEN LEN(MONTH(E.VisitDate)) = 1 THEN '0'+CAST(MONTH(E.VisitDate) AS CHAR(1)) ELSE CAST(MONTH(E.VisitDate) AS CHAR(2)) END

	DELETE FROM #XER WHERE Cust_ID = 10 AND MonthID > @MaxMonth10
	DELETE FROM #XER WHERE Cust_ID = 11 AND MonthID > @MaxMonth11
	DELETE FROM #XER WHERE Cust_ID = 13 AND MonthID > @MaxMonth13
	DELETE FROM #XER WHERE Cust_ID = 14 AND MonthID > @MaxMonth14

	CREATE INDEX IX_Cust_ID_MVDId_MonthID ON #XER (Cust_ID, MVDId, MemberID, MonthID)

	MERGE Rules.MainPersonalStats AS target  
	USING 
	(
		SELECT Cust_ID, MVDId, MemberID, MonthID, LastERVisit
		FROM #XER
		 ) AS source (Cust_ID, MVDId, MemberID, MonthID, LastERVisit)
		ON (target.Cust_ID = source.Cust_ID AND target.MVDId = source.MVDId and target.MemberID = source.MemberID and target.MonthID = source.MonthID)  
		WHEN MATCHED THEN   
			UPDATE 
			SET  Target.LastERVisit = Source.LastERVisit
			,Target.ModifyDate = GETDATE()
	WHEN NOT MATCHED THEN  
		INSERT (Cust_ID, MVDId, MemberID, MonthID, LastDrugDispensedDate)  
		VALUES (source.Cust_ID, source.MVDId, source.MemberID, source.MonthID, source.LastERVisit);

	-- Update all the NULL months with the most recent LastERVisit
	IF (OBJECT_ID('tempdb..#LD2') IS NOT NULL) DROP TABLE #LD2
	SELECT DISTINCT Cust_ID, MVDID, MemberID, 0 IsProcessed
	INTO #LD2
	FROM Rules.MainPersonalStats
	WHERE LastERVisit IS NOT NULL
	AND MVDID IN (SELECT MVDId FROM #XER)

	WHILE EXISTS (SELECT * FROM #LD2 WHERE IsProcessed = 0)
	BEGIN

		IF (OBJECT_ID('tempdb..#IP2') IS NOT NULL) DROP TABLE #IP2
		SELECT DISTINCT TOP (50000) Cust_ID, MVDID, MemberID -- Take 50000 at a time
		INTO #IP2
		FROM #LD2
		WHERE IsProcessed = 0
		
		CREATE CLUSTERED INDEX IX_Cust_ID_MVDID_MemberID ON #IP2 (Cust_ID, MVDID, MemberID)

		IF (OBJECT_ID('tempdb..#FinalE') IS NOT NULL) DROP TABLE #FinalE
		SELECT M.Cust_ID, M.MVDID, M.MemberID, M.MonthID, MAX(LD.LastERVisit) LastERVisit
		INTO #FinalE
		FROM Rules.MainPersonalStats AS M WITH(NOLOCK)
		LEFT JOIN
		(
			SELECT S.Cust_ID, S.MVDID, S.MemberID, S.MonthID, S.LastERVisit
			FROM Rules.MainPersonalStats S WITH(NOLOCK)
			WHERE S.LastERVisit IS NOT NULL
			AND EXISTS (SELECT * FROM #IP2 WHERE Cust_ID = S.Cust_ID AND MVDID = S.MVDID AND MemberID = S.MemberID)
		) LD ON M.Cust_ID = LD.Cust_ID AND M.MVDID = LD.MVDID AND M.MemberID = LD.MemberID AND M.MonthID >= LD.MonthID
		WHERE EXISTS (SELECT * FROM #IP2 WHERE Cust_ID = M.Cust_ID AND MVDID = M.MVDID AND MemberID = M.MemberID)
		GROUP BY M.Cust_ID, M.MVDID, M.MemberID, M.MonthID
		ORDER BY M.Cust_ID, M.MVDID, M.MemberID, M.MonthID

		UPDATE M
		SET M.LastERVisit = F.LastERVisit
		FROM #FinalE F
		JOIN Rules.MainPersonalStats M ON F.Cust_ID = M.Cust_ID AND F.MVDID = M.MVDID AND F.MemberID = M.MemberID AND F.MonthID = M.MonthID
		WHERE M.LastERVisit IS NULL

		UPDATE LD
		SET IsProcessed = 1
		FROM #LD2 LD
		WHERE EXISTS (SELECT * FROM #IP2 WHERE Cust_ID = LD.Cust_ID AND MVDID = LD.MVDID AND MemberID = LD.MemberID)
		AND IsProcessed = 0

	END

	-- Last Lab visit
	IF (OBJECT_ID('tempdb..#XL') IS NOT NULL) DROP TABLE #XL
	SELECT DISTINCT 
	 I.Cust_ID
	,I.MVDID
	,I.InsMemberId AS MemberID
	,MonthID = CAST(YEAR(E.VisitDate) AS CHAR(4))+CASE WHEN LEN(MONTH(E.VisitDate)) = 1 THEN '0'+CAST(MONTH(E.VisitDate) AS CHAR(1)) ELSE CAST(MONTH(E.VisitDate) AS CHAR(2)) END
	,CAST(MAX(E.VisitDate) AS DATE) AS LastLABVisit
	INTO #XL
	FROM dbo.EDVisitHistory E
	JOIN dbo.Link_MemberId_MVD_Ins I ON E.ICENUMBER = I.MVDID
	WHERE E.VisitDate >= DATEADD(MM, -2, GETDATE())
	AND E.VisitDate < DATEADD(DD, 1, GETDATE())
	AND E.VisitType = 'LAB'
	AND I.Cust_ID IN (10,11,13,14)
	AND (@Cust_ID IS NULL OR I.Cust_ID = @Cust_ID)
	GROUP BY I.Cust_ID, I.MVDID, I.InsMemberId, CAST(YEAR(E.VisitDate) AS CHAR(4))+CASE WHEN LEN(MONTH(E.VisitDate)) = 1 THEN '0'+CAST(MONTH(E.VisitDate) AS CHAR(1)) ELSE CAST(MONTH(E.VisitDate) AS CHAR(2)) END
	ORDER BY I.Cust_ID, I.MVDID, I.InsMemberId, CAST(YEAR(E.VisitDate) AS CHAR(4))+CASE WHEN LEN(MONTH(E.VisitDate)) = 1 THEN '0'+CAST(MONTH(E.VisitDate) AS CHAR(1)) ELSE CAST(MONTH(E.VisitDate) AS CHAR(2)) END

	DELETE FROM #XL WHERE Cust_ID = 10 AND MonthID > @MaxMonth10
	DELETE FROM #XL WHERE Cust_ID = 11 AND MonthID > @MaxMonth11
	DELETE FROM #XL WHERE Cust_ID = 13 AND MonthID > @MaxMonth13
	DELETE FROM #XL WHERE Cust_ID = 14 AND MonthID > @MaxMonth14

	CREATE INDEX IX_Cust_ID_MVDId_MonthID ON #XL (Cust_ID, MVDId, MemberID, MonthID)

	MERGE Rules.MainPersonalStats AS target  
	USING 
	(
		SELECT Cust_ID, MVDId, MemberID, MonthID, LastLABVisit
		FROM #XL
		 ) AS source (Cust_ID, MVDId, MemberID, MonthID, LastLABVisit)
		ON (target.Cust_ID = source.Cust_ID AND target.MVDId = source.MVDId and target.MemberID = source.MemberID and target.MonthID = source.MonthID)  
		WHEN MATCHED THEN   
			UPDATE 
			SET  Target.LastLABVisit = Source.LastLABVisit
			,Target.ModifyDate = GETDATE()
	WHEN NOT MATCHED THEN  
		INSERT (Cust_ID, MVDId, MemberID, MonthID, LastDrugDispensedDate)  
		VALUES (source.Cust_ID, source.MVDId, source.MemberID, source.MonthID, source.LastLABVisit);

	-- Update all the NULL months with the most recent LastLABVisit
	IF (OBJECT_ID('tempdb..#LD3') IS NOT NULL) DROP TABLE #LD3
	SELECT DISTINCT Cust_ID, MVDID, MemberID, 0 IsProcessed
	INTO #LD3
	FROM Rules.MainPersonalStats
	WHERE LastLABVisit IS NOT NULL
	AND MVDID IN (SELECT MVDId FROM #XL)

	WHILE EXISTS (SELECT * FROM #LD3 WHERE IsProcessed = 0)
	BEGIN

		IF (OBJECT_ID('tempdb..#IP3') IS NOT NULL) DROP TABLE #IP3
		SELECT DISTINCT TOP (50000) Cust_ID, MVDID, MemberID -- Take 50000 at a time
		INTO #IP3
		FROM #LD3
		WHERE IsProcessed = 0

		CREATE CLUSTERED INDEX IX_Cust_ID_MVDID_MemberID ON #IP3 (Cust_ID, MVDID, MemberID)

		IF (OBJECT_ID('tempdb..#FinalL') IS NOT NULL) DROP TABLE #FinalL
		SELECT M.Cust_ID, M.MVDID, M.MemberID, M.MonthID, MAX(LD.LastLABVisit) LastLABVisit
		INTO #FinalL
		FROM Rules.MainPersonalStats AS M WITH(NOLOCK)
		LEFT JOIN
		(
			SELECT S.Cust_ID, S.MVDID, S.MemberID, S.MonthID, S.LastLABVisit
			FROM Rules.MainPersonalStats S WITH(NOLOCK)
			WHERE S.LastLABVisit IS NOT NULL
			AND EXISTS (SELECT * FROM #IP3 WHERE Cust_ID = S.Cust_ID AND MVDID = S.MVDID AND MemberID = S.MemberID)
		) LD ON M.Cust_ID = LD.Cust_ID AND M.MVDID = LD.MVDID AND M.MemberID = LD.MemberID AND M.MonthID >= LD.MonthID
		WHERE EXISTS (SELECT * FROM #IP3 WHERE Cust_ID = M.Cust_ID AND MVDID = M.MVDID AND MemberID = M.MemberID)
		GROUP BY M.Cust_ID, M.MVDID, M.MemberID, M.MonthID
		ORDER BY M.Cust_ID, M.MVDID, M.MemberID, M.MonthID

		UPDATE M
		SET M.LastLABVisit = F.LastLABVisit
		FROM #FinalL F
		JOIN Rules.MainPersonalStats M ON F.Cust_ID = M.Cust_ID AND F.MVDID = M.MVDID AND F.MemberID = M.MemberID AND F.MonthID = M.MonthID
		WHERE M.LastERVisit IS NULL

		UPDATE LD
		SET IsProcessed = 1
		FROM #LD3 LD
		WHERE EXISTS (SELECT * FROM #IP3 WHERE Cust_ID = LD.Cust_ID AND MVDID = LD.MVDID AND MemberID = LD.MemberID)
		AND IsProcessed = 0

	END

	-- Last PCP visit
	IF (OBJECT_ID('tempdb..#XP') IS NOT NULL) DROP TABLE #XP
	SELECT DISTINCT 
	 I.Cust_ID
	,I.InsMemberId AS MemberID
	,I.MVDID
	,MonthID = CAST(YEAR(E.VisitDate) AS CHAR(4))+CASE WHEN LEN(MONTH(E.VisitDate)) = 1 THEN '0'+CAST(MONTH(E.VisitDate) AS CHAR(1)) ELSE CAST(MONTH(E.VisitDate) AS CHAR(2)) END
	,CAST(MAX(E.VisitDate) AS DATE) AS LastPhysicianVisit
	INTO #XP
	FROM dbo.EDVisitHistory E
	JOIN dbo.Link_MemberId_MVD_Ins I ON E.ICENUMBER = I.MVDID
	WHERE E.VisitDate >= DATEADD(MM, -2, GETDATE())
	AND E.VisitDate < DATEADD(DD, 1, GETDATE())
	AND E.VisitType = 'Physician'
	AND I.Cust_ID IN (10,11,13,14)
	AND (@Cust_ID IS NULL OR I.Cust_ID = @Cust_ID)
	GROUP BY I.Cust_ID, I.MVDID, I.InsMemberId, CAST(YEAR(E.VisitDate) AS CHAR(4))+CASE WHEN LEN(MONTH(E.VisitDate)) = 1 THEN '0'+CAST(MONTH(E.VisitDate) AS CHAR(1)) ELSE CAST(MONTH(E.VisitDate) AS CHAR(2)) END
	ORDER BY I.Cust_ID, I.MVDID, I.InsMemberId, CAST(YEAR(E.VisitDate) AS CHAR(4))+CASE WHEN LEN(MONTH(E.VisitDate)) = 1 THEN '0'+CAST(MONTH(E.VisitDate) AS CHAR(1)) ELSE CAST(MONTH(E.VisitDate) AS CHAR(2)) END

	DELETE FROM #XP WHERE Cust_ID = 10 AND MonthID > @MaxMonth10
	DELETE FROM #XP WHERE Cust_ID = 11 AND MonthID > @MaxMonth11
	DELETE FROM #XP WHERE Cust_ID = 13 AND MonthID > @MaxMonth13
	DELETE FROM #XP WHERE Cust_ID = 14 AND MonthID > @MaxMonth14

	CREATE INDEX IX_Cust_ID_MVDId_MonthID ON #XP (Cust_ID, MVDId, MemberID, MonthID)

	MERGE Rules.MainPersonalStats AS target  
	USING 
	(
		SELECT Cust_ID, MVDId, MemberID, MonthID, LastPhysicianVisit
		FROM #XP
		 ) AS source (Cust_ID, MVDId, MemberID, MonthID, LastPhysicianVisit)
		ON (target.Cust_ID = source.Cust_ID AND target.MVDId = source.MVDId and target.MemberID = source.MemberID and target.MonthID = source.MonthID)  
		WHEN MATCHED THEN   
			UPDATE 
			SET  Target.LastPhysicianVisit = Source.LastPhysicianVisit
			,Target.ModifyDate = GETDATE()
	WHEN NOT MATCHED THEN  
		INSERT (Cust_ID, MVDId, MemberID, MonthID, LastPhysicianVisit)  
		VALUES (source.Cust_ID, source.MVDId, source.MemberID, source.MonthID, source.LastPhysicianVisit);

	-- Update all the NULL months with the most recent LastPhysicianVisit
	IF (OBJECT_ID('tempdb..#LD4') IS NOT NULL) DROP TABLE #LD4
	SELECT DISTINCT Cust_ID, MVDID, MemberID, 0 IsProcessed
	INTO #LD4
	FROM Rules.MainPersonalStats
	WHERE LastPhysicianVisit IS NOT NULL
	AND MVDID IN (SELECT MVDId FROM #XP)

	WHILE EXISTS (SELECT * FROM #LD4 WHERE IsProcessed = 0)
	BEGIN

		IF (OBJECT_ID('tempdb..#IP4') IS NOT NULL) DROP TABLE #IP4
		SELECT DISTINCT TOP (50000) Cust_ID, MVDID, MemberID -- Take 50000 at a time
		INTO #IP4
		FROM #LD4
		WHERE IsProcessed = 0

		CREATE CLUSTERED INDEX IX_Cust_ID_MVDID_MemberID ON #IP4 (Cust_ID, MVDID, MemberID)

		IF (OBJECT_ID('tempdb..#S4') IS NOT NULL) DROP TABLE #S4
		SELECT S.Cust_ID, S.MVDID, S.MemberID, S.MonthID, S.LastPhysicianVisit
		INTO #S4
		FROM Rules.MainPersonalStats S WITH(NOLOCK)
		WHERE S.LastPhysicianVisit IS NOT NULL
		AND EXISTS (SELECT * FROM #IP4 WHERE Cust_ID = S.Cust_ID AND MVDID = S.MVDID AND MemberID = S.MemberID)

		CREATE CLUSTERED INDEX IX_Cust_ID_MVDID_MemberID ON #S4 (Cust_ID, MVDID, MemberID)

		IF (OBJECT_ID('tempdb..#FinalPCP') IS NOT NULL) DROP TABLE #FinalPCP
		SELECT M.Cust_ID, M.MVDID, M.MemberID, M.MonthID, MAX(LD.LastPhysicianVisit) LastPhysicianVisit
		INTO #FinalPCP
		FROM Rules.MainPersonalStats AS M WITH(NOLOCK)
		LEFT JOIN #S4 LD ON M.Cust_ID = LD.Cust_ID AND M.MVDID = LD.MVDID AND M.MemberID = LD.MemberID AND M.MonthID >= LD.MonthID
		WHERE EXISTS (SELECT * FROM #IP4 WHERE Cust_ID = M.Cust_ID AND MVDID = M.MVDID AND MemberID = M.MemberID)
		GROUP BY M.Cust_ID, M.MVDID, M.MemberID, M.MonthID
		ORDER BY M.Cust_ID, M.MVDID, M.MemberID, M.MonthID

/*
		IF (OBJECT_ID('tempdb..#FinalPCP') IS NOT NULL) DROP TABLE #FinalPCP
		SELECT M.Cust_ID, M.MVDID, M.MemberID, M.MonthID, MAX(LD.LastPhysicianVisit) LastPhysicianVisit
		INTO #FinalPCP
		FROM Rules.MainPersonalStats AS M WITH(NOLOCK)
		LEFT JOIN
		(
			SELECT S.Cust_ID, S.MVDID, S.MemberID, S.MonthID, S.LastPhysicianVisit
			FROM Rules.MainPersonalStats S WITH(NOLOCK)
			WHERE S.LastPhysicianVisit IS NOT NULL
			AND EXISTS (SELECT * FROM #IP4 WHERE Cust_ID = S.Cust_ID AND MVDID = S.MVDID AND MemberID = S.MemberID)
		) LD ON M.Cust_ID = LD.Cust_ID AND M.MVDID = LD.MVDID AND M.MemberID = LD.MemberID AND M.MonthID >= LD.MonthID
		WHERE EXISTS (SELECT * FROM #IP4 WHERE Cust_ID = M.Cust_ID AND MVDID = M.MVDID AND MemberID = M.MemberID)
		GROUP BY M.Cust_ID, M.MVDID, M.MemberID, M.MonthID
		ORDER BY M.Cust_ID, M.MVDID, M.MemberID, M.MonthID
*/
		UPDATE M
		SET M.LastPhysicianVisit = F.LastPhysicianVisit
		FROM #FinalPCP F
		JOIN Rules.MainPersonalStats M ON F.Cust_ID = M.Cust_ID AND F.MVDID = M.MVDID AND F.MemberID = M.MemberID AND F.MonthID = M.MonthID
		WHERE M.LastPhysicianVisit IS NULL

		UPDATE LD
		SET IsProcessed = 1
		FROM #LD4 LD
		WHERE EXISTS (SELECT * FROM #IP4 WHERE Cust_ID = LD.Cust_ID AND MVDID = LD.MVDID AND MemberID = LD.MemberID)
		AND IsProcessed = 0

	END

END