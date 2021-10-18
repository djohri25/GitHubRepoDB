/****** Object:  Procedure [dbo].[DashboardMemberTotalsProcess]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[DashboardMemberTotalsProcess]
	 @Cust_ID INT
	,@LOB VARCHAR(25) = NULL --'STAR' --, 'CHIP'
	,@StartDate VARCHAR(20) = NULL
AS

-- =============================================
-- Author: Marc De Luca
-- Create date: 01/30/2017
-- Description: Provides member totals for a dashboard graph
-- Example: EXEC dbo.DashboardMemberTotalsProcess @Cust_ID = 10
--	Date			Name			Comments
-- 05/26/2017		PPetluri		Commented Seton Code since the DB's are made offline on 227 server.
-- 05/21/2018		MDeLuca			Added totals by TIN
-- 05/24/2021		Sunil Nokku		Remove Parkland references
-- =============================================

BEGIN

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET NOCOUNT ON;

	DECLARE 
	 @CurrentID AS INT = 1
	,@MaxID INT
	,@SQLString NVARCHAR(MAX)
	,@RollingMonths TINYINT = 14
	,@CurrentDate DATE
	,@CurrentMonth DATE
	,@EndDate DATE

	IF @StartDate IS NULL
		SELECT @StartDate = DATEFROMPARTS(YEAR(DATEADD(MM, -@RollingMonths, GETDATE())), MONTH(DATEADD(MM, -@RollingMonths, GETDATE())), '01')
	ELSE
		SET @StartDate = DATEFROMPARTS(YEAR(@StartDate), MONTH(@StartDate), '01')

	SELECT @EndDate = DATEADD(MM, @RollingMonths, @StartDate)

	SET @CurrentDate = @StartDate -- DATEADD(MM, -1, @StartDate)

	IF OBJECT_ID('tempdb..#Dates') IS NOT NULL DROP TABLE #Dates;
	CREATE TABLE #Dates (ID INT IDENTITY(1,1), MeasureDate DATE, MonthID INT, TimePeriod VARCHAR(25), MonthIndicator TINYINT)

	WHILE @CurrentDate <= @EndDate
	BEGIN

		INSERT INTO #Dates (MeasureDate, MonthID)
		VALUES(@CurrentDate, CAST(YEAR(@CurrentDate) AS CHAR(4))+CASE WHEN LEN(MONTH(@CurrentDate)) = 1 THEN '0'+CAST(MONTH(@CurrentDate) AS CHAR(2)) ELSE CAST(MONTH(@CurrentDate) AS CHAR(2)) END)

		SET @CurrentDate = DATEADD(MM, 1, @CurrentDate)

	END

	UPDATE #Dates
	SET	 TimePeriod = CASE WHEN ID BETWEEN 1 AND 12 THEN 'PriorYear' ELSE 'CurrentYear' END
		,MonthIndicator = CASE ID	WHEN 1 THEN 1 WHEN 13 THEN 1 WHEN 2 THEN 2 WHEN 14 THEN 2
						WHEN 3 THEN 3 WHEN 15 THEN 3 WHEN 4 THEN 4 WHEN 16 THEN 4
						WHEN 5 THEN 5 WHEN 17 THEN 5 WHEN 6 THEN 6 WHEN 18 THEN 6
						WHEN 7 THEN 7 WHEN 19 THEN 7 WHEN 8 THEN 8 WHEN 20 THEN 8
						WHEN 9 THEN 9 WHEN 21 THEN 9 WHEN 10 THEN 10 WHEN 22 THEN 10
						WHEN 11 THEN 11 WHEN 23 THEN 11 WHEN 12 THEN 12 WHEN 24 THEN 12
						END

	CREATE INDEX IX_Dates_MonthID ON #Dates (MonthID)
	
	IF OBJECT_ID('tempdb..#M') IS NOT NULL DROP TABLE #M;
	CREATE TABLE #M (MonthID CHAR(6), MemberID VARCHAR(50))

	--IF @Cust_ID = 10
	--BEGIN
	--	INSERT INTO #M (MonthID, MemberID)
	--	SELECT DISTINCT MonthID, LTRIM(RTRIM(MemberID)) AS MemberID
	--	FROM [VD-RPT01].[HedisParkland].dbo.Eligibility
	--	WHERE MonthID IN (SELECT MonthID FROM #Dates)
	--END

	IF @Cust_ID = 11
	BEGIN
		INSERT INTO #M ( MonthID, MemberID)
		SELECT DISTINCT MonthID, LTRIM(RTRIM(MemberID)) AS MemberID
		FROM [VD-RPT01].[HEDISDriscoll].dbo.Eligibility
		WHERE MonthID IN (SELECT MonthID FROM #Dates)
	END

	IF @Cust_ID = 17
	BEGIN
		INSERT INTO #M ( MonthID, MemberID)
		SELECT DISTINCT MonthID, LTRIM(RTRIM(MemberID)) AS MemberID
		FROM [VD-RPT01].[ARSuperiorSelectData].dbo.Eligibility
		WHERE MonthID IN (SELECT MonthID FROM #Dates)
	END

	CREATE INDEX IX_MonthID_MemberID ON #M (MonthID, MemberID)

	DROP TABLE IF EXISTS #X;
	SELECT MonthID, MemberID
	INTO #X
	FROM #Dates D
	CROSS JOIN (SELECT DISTINCT MemberID FROM #M) E
	ORDER BY MemberID, MonthID	

	DROP TABLE IF EXISTS #F;
	SELECT X.MonthID, X.MemberID, M.MemberID AS MemberExistsID
	,ISNULL(LEAD (M.MemberID, 0, 0) OVER (PARTITION BY X.MemberID ORDER BY X.MemberID, X.MonthID),0) AS PrevExistance
	,ISNULL(LAG (M.MemberID, 1, 0) OVER (PARTITION BY X.MemberID ORDER BY X.MemberID, X.MonthID),0) AS NextExistance
	INTO #F
	FROM #X X
	LEFT JOIN #M M ON X.MonthID = M.MonthID AND X.MemberID = M.MemberID
	ORDER BY X.MemberID, X.MonthID

	IF OBJECT_ID('tempdb..#Totals') IS NOT NULL DROP TABLE #Totals;
	SELECT
	 MonthID
	,TIN
	,COUNT(DISTINCT MemberExistsID ) MemberTotals
	,SUM(CASE WHEN MemberExistsID IS NOT NULL AND PrevExistance <> '0' AND NextExistance = '0' THEN 1 ELSE 0 END) AS NewMembers
	,SUM(CASE WHEN MemberExistsID IS NULL AND PrevExistance = '0' AND NextExistance <> '0' THEN 1 ELSE 0 END) AS LostMembers
	INTO #Totals
	FROM 
	(
		SELECT DISTINCT MonthID, MemberID, MemberExistsID, PrevExistance, NextExistance
		FROM #F 
	)	F
	LEFT JOIN 
			(
				SELECT DISTINCT g.GroupName AS TIN, i.InsMemberId AS MemberID
				FROM dbo.MDUser u
				JOIN dbo.Link_MDAccountGroup ag ON u.ID = ag.MDAccountID
				JOIN dbo.MDGroup g ON ag.MDGroupID = g.ID
				JOIN dbo.Link_MDGroupNPI n ON g.ID = n.MDGroupID
				LEFT JOIN 
				(
					SELECT MS.*
					FROM dbo.MainSpecialist MS
					JOIN
						(
							SELECT NPI, MAX(RecordNumber) AS RecordNumber
							FROM dbo.MainSpecialist MS
							GROUP BY NPI
						) MSM ON MS.NPI = MSM.NPI AND MS.RecordNumber = MSM.RecordNumber
					) s ON n.NPI = s.NPI
				JOIN dbo.Link_MemberId_MVD_Ins i ON s.ICENUMBER = i.MVDId
				WHERE i.Cust_ID = @Cust_ID
			) T ON F.MemberID = T.MemberID
	WHERE DATEFROMPARTS(LEFT(MonthID,4), RIGHT(MonthID,2), '01') >= @StartDate
	GROUP BY MonthID, TIN

	DELETE FROM #Totals
	WHERE MonthID = (SELECT MAX(MonthID) FROM #Totals)
	AND (SELECT SUM(MemberTotals) FROM #Totals WHERE MonthID = (SELECT MAX(MonthID) FROM #Totals)) = 0

	MERGE dbo.DashboardTotalsByTin AS target  
	USING (SELECT @Cust_ID, TIN, @LOB, MonthID, MemberTotals, NewMembers, LostMembers FROM #Totals) AS source (CustID, TIN, LOB, MonthID, MemberTotals, NewMembers, LostMembers)  
	ON (target.CustID = source.CustID AND target.MonthID = source.MonthID AND ISNULL(target.TIN,'') = ISNULL(source.TIN,'') AND ISNULL(target.LOB,'') = ISNULL(source.LOB,'')) 
	WHEN MATCHED THEN   
			UPDATE 
			SET	 target.MemberTotals = source.MemberTotals
					,target.NewMembers = source.NewMembers
					,target.LostMembers = source.LostMembers
					,target.DateModified = GETDATE()
	WHEN NOT MATCHED THEN  
		INSERT (CustID, TIN, LOB, MonthID, MemberTotals, NewMembers, LostMembers)  
		VALUES (source.CustID, source.TIN, source.LOB, source.MonthID, source.MemberTotals, source.NewMembers, source.LostMembers);

END