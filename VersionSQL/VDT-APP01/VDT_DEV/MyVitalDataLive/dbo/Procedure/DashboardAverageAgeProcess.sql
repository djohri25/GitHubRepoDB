/****** Object:  Procedure [dbo].[DashboardAverageAgeProcess]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[DashboardAverageAgeProcess]
	 @Cust_ID INT
	,@LOB VARCHAR(25) = NULL --'STAR' --, 'CHIP'
	,@StartDate VARCHAR(20) = NULL
AS

-- =============================================
-- Author: Marc De Luca
-- Create date: 01/30/2017
-- Description: Provides member totals for a dashboard graph
-- Example: EXEC dbo.DashboardAverageAgeProcess @Cust_ID = 10
--	Date			Name			Comments
-- 05/26/2017		PPetluri		Commented Seton Code since the DB's are made offline on 227 server.
-- 11/13/2017		MDeLuca		Fixed the ORDER BY in the final select
-- 05/24/2021		Sunil Nokku		Remove Parkland references
-- =============================================

BEGIN

	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET NOCOUNT ON;

	DECLARE 
	 @CurrentID AS INT = 1
	,@MaxID INT
	,@SQLString NVARCHAR(MAX)
	,@RollingMonths TINYINT = 13
	,@CurrentDate DATE
	,@CurrentMonth DATE
	,@EndDate DATE

	IF @StartDate IS NULL
		SELECT @StartDate = DATEFROMPARTS(YEAR(DATEADD(MM, -@RollingMonths, GETDATE())), MONTH(DATEADD(MM, -@RollingMonths, GETDATE())), '01')
	ELSE
		SET @StartDate = DATEFROMPARTS(YEAR(@StartDate), MONTH(@StartDate), '01')

	SELECT @EndDate = DATEADD(MM, @RollingMonths - 1, @StartDate)

	SET @CurrentDate = DATEADD(MM, -1, @StartDate)

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
	CREATE TABLE #M (MonthID CHAR(6), MemberID VARCHAR(50), DOB DATE)

	--IF @Cust_ID = 10
	--BEGIN
	--	INSERT INTO #M (MonthID, MemberID, DOB)
	--	SELECT DISTINCT e.MonthID, LTRIM(RTRIM(e.MemberID)) AS MemberID, m.DOB
	--	FROM [VD-RPT01].[HedisParkland].dbo.Eligibility e
	--	JOIN (SELECT DISTINCT MemberID, DOB	FROM [VD-RPT01].[HedisParkland].dbo.Member) m ON e.memberid = m.memberid
	--	WHERE e.MonthID IN (SELECT MonthID FROM #Dates)
	--END

	IF @Cust_ID = 11
	BEGIN
		INSERT INTO #M ( MonthID, MemberID, DOB)
		SELECT DISTINCT e.MonthID, LTRIM(RTRIM(e.MemberID)) AS MemberID, m.DOB
		FROM [VD-RPT01].[HEDISDriscoll].dbo.Eligibility e
		JOIN (SELECT DISTINCT MemberID, DOB	FROM [VD-RPT01].[HEDISDriscoll].dbo.Member) m ON e.memberid = m.memberid
		WHERE e.MonthID IN (SELECT MonthID FROM #Dates)
	END
	
	IF @Cust_ID = 17
	BEGIN
		INSERT INTO #M ( MonthID, MemberID, DOB)
		SELECT DISTINCT e.MonthID, LTRIM(RTRIM(e.MemberID)) AS MemberID, m.DOB
		FROM [VD-RPT01].[ARSuperiorSelectData].dbo.Eligibility e
		JOIN (SELECT DISTINCT MemberID, DOB	FROM [VD-RPT01].[ARSuperiorSelectData].dbo.Member) m ON e.memberid = m.memberid
		WHERE e.MonthID IN (SELECT MonthID FROM #Dates)
	END

	CREATE INDEX IX_MonthID_MemberID ON #M (MonthID, MemberID)

	IF OBJECT_ID('tempdb..#Totals') IS NOT NULL DROP TABLE #Totals;

	;WITH CTE_Results AS
	(
		SELECT 
		 MonthID
		,TIN
		,COUNT(*) Members
		,CAST(SUM(CAST(DATEDIFF(DD, CAST(DOB AS DATE), DATEFROMPARTS(LEFT(MonthID,4), RIGHT(MonthID,2), '01')) /365.25 AS DECIMAL(38, 15))) AS DECIMAL(38, 15)) AS Age
		,SUM(CASE WHEN CAST(DATEDIFF(DD, CAST(DOB AS DATE), DATEFROMPARTS(LEFT(MonthID,4), RIGHT(MonthID,2), '01')) /365.25 AS INT) BETWEEN 0 AND 2 THEN 1 ELSE 0 END) AS [Under3]
		,SUM(CASE WHEN CAST(DATEDIFF(DD, CAST(DOB AS DATE), DATEFROMPARTS(LEFT(MonthID,4), RIGHT(MonthID,2), '01')) /365.25 AS INT) BETWEEN 3 AND 10 THEN 1 ELSE 0 END) AS [Age3to10]
		,SUM(CASE WHEN CAST(DATEDIFF(DD, CAST(DOB AS DATE), DATEFROMPARTS(LEFT(MonthID,4), RIGHT(MonthID,2), '01')) /365.25 AS INT) BETWEEN 11 AND 17 THEN 1 ELSE 0 END) AS [Age11to17]
		,SUM(CASE WHEN CAST(DATEDIFF(DD, CAST(DOB AS DATE), DATEFROMPARTS(LEFT(MonthID,4), RIGHT(MonthID,2), '01')) /365.25 AS INT) BETWEEN 18 AND 26 THEN 1 ELSE 0 END) AS [Age18to26]
		,SUM(CASE WHEN CAST(DATEDIFF(DD, CAST(DOB AS DATE), DATEFROMPARTS(LEFT(MonthID,4), RIGHT(MonthID,2), '01')) /365.25 AS INT) BETWEEN 27 AND 50 THEN 1 ELSE 0 END) AS [Age27to50]
		,SUM(CASE WHEN CAST(DATEDIFF(DD, CAST(DOB AS DATE), DATEFROMPARTS(LEFT(MonthID,4), RIGHT(MonthID,2), '01')) /365.25 AS INT) BETWEEN 51 AND 200 THEN 1 ELSE 0 END) AS [Over50]
		FROM #M M
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
			) T ON M.MemberID = T.MemberID
		WHERE DATEFROMPARTS(LEFT(MonthID,4), RIGHT(MonthID,2), '01') >= @StartDate
		GROUP BY MonthID,TIN
	)

	SELECT MonthID, TIN, Age, [Under3], [Age3to10], [Age11to17], [Age18to26], [Age27to50], [Over50]
	INTO #Totals
	FROM CTE_Results
	ORDER BY MonthID

	MERGE dbo.DashboardTotalsByTin AS target  
	USING (SELECT @Cust_ID, TIN, @LOB, MonthID, [Age], [Under3], [Age3to10], [Age11to17], [Age18to26], [Age27to50], [Over50] FROM #Totals) 
		AS source (CustID, TIN, LOB, MonthID, [Age], [Under3], [Age3to10], [Age11to17], [Age18to26], [Age27to50], [Over50])  
	ON (target.CustID = source.CustID AND target.MonthID = source.MonthID AND ISNULL(target.TIN,'') = ISNULL(source.TIN,'') AND ISNULL(target.LOB,'') = ISNULL(source.LOB,''))  
	WHEN MATCHED THEN   
			UPDATE 
			SET	 target.[Age] = source.[Age]
					,target.[Under3] = source.[Under3]
					,target.[Age3to10] = source.[Age3to10]
					,target.[Age11to17] = source.[Age11to17]
					,target.[Age18to26] = source.[Age18to26]
					,target.[Age27to50] = source.[Age27to50]
					,target.[Over50] = source.[Over50]
					,target.DateModified = GETDATE()
	WHEN NOT MATCHED THEN  
		INSERT (CustID, TIN, LOB, MonthID, [Age], [Under3], [Age3to10], [Age11to17], [Age18to26], [Age27to50], [Over50])  
		VALUES (source.CustID, source.TIN, source.LOB, source.MonthID, source.[Age], source.[Under3], source.[Age3to10], source.[Age11to17]
						, source.[Age18to26], source.[Age27to50], source.[Over50]);

END