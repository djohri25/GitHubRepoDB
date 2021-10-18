/****** Object:  Procedure [dbo].[DashboardPCPVisitsProcess]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[DashboardPCPVisitsProcess]
	 @Cust_ID INT
	,@LOB VARCHAR(25) = NULL --'STAR' --, 'CHIP'
	,@StartDate DATE = NULL
AS

-- =============================================
-- Author: Marc De Luca
-- Create date: 01/31/2017
-- Description: Provides PCP visit totals for a dashboard graph
-- Example: EXEC dbo.DashboardPCPVisitsProcess @Cust_ID = 10
--	Date			Name			Comments
-- 05/26/2017		PPetluri		Commented Seton Code since the DB's are made offline on 227 server.
-- 05/24/2021		Sunil Nokku		Remove Parkland references
-- =============================================

BEGIN

	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET NOCOUNT ON;

	IF @StartDate IS NULL
		SET @StartDate = DATEFROMPARTS(YEAR(DATEADD(MM, -13, GETDATE())), MONTH(DATEADD(MM, -13, GETDATE())), '01')

	DECLARE 
	 @CurrentMonth DATE = @StartDate
	,@MonthID VARCHAR(6)
	,@EndDate DATE

	SET @EndDate = DATEADD(MM, 13, @StartDate)

	IF (OBJECT_ID('tempdb..#Months') IS NOT NULL) DROP TABLE #Months
	CREATE TABLE #Months (ID INT IDENTITY(1,1), MonthID INT)

	WHILE @CurrentMonth < @EndDate
	BEGIN

		SELECT @MonthID = CAST(YEAR(@CurrentMonth) AS CHAR(4))+CASE WHEN MONTH(@CurrentMonth) IN ('12','11','10') THEN CAST(MONTH(@CurrentMonth) AS CHAR(2)) ELSE '0'+CAST(MONTH(@CurrentMonth) AS CHAR(2)) END

		INSERT INTO #Months (MonthID)
		SELECT @MonthID

		SET @CurrentMonth = DATEADD(MM, 1, @CurrentMonth)

	END

	IF (OBJECT_ID('tempdb..#M') IS NOT NULL) DROP TABLE #M
	CREATE TABLE #M (MonthID CHAR(6), MemberID VARCHAR(15))

	IF (OBJECT_ID('tempdb..#MT') IS NOT NULL) DROP TABLE #MT
	CREATE TABLE #MT (ID INT IDENTITY(1,1), MonthID CHAR(6), MemberTotals INT)

	--IF @Cust_ID = 10
	--BEGIN
	--	INSERT INTO #MT (MonthID, MemberTotals)
	--	SELECT MonthID, MemberTotals
	--	FROM OPENQUERY([VD-RPT01], 'SELECT MonthID, COUNT(DISTINCT memberid) AS MemberTotals
	--	FROM [HedisParkland].dbo.Eligibility WITH(NOLOCK)
	--	GROUP BY MonthID
	--	ORDER BY MonthID')
	--	WHERE MonthID IN (SELECT MonthID FROM #Months)
	--END

	IF @Cust_ID = 11
	BEGIN
		INSERT INTO #MT (MonthID, MemberTotals)
		SELECT MonthID, MemberTotals
		FROM OPENQUERY([VD-RPT01], 'SELECT MonthID, COUNT(DISTINCT memberid) AS MemberTotals
		FROM [HEDISDriscoll].dbo.Eligibility WITH(NOLOCK)
		GROUP BY MonthID
		ORDER BY MonthID')
		WHERE MonthID IN (SELECT MonthID FROM #Months)
	END

	IF @Cust_ID = 17
	BEGIN
		INSERT INTO #MT (MonthID, MemberTotals)
		SELECT MonthID, MemberTotals
		FROM OPENQUERY([VD-RPT01], 'SELECT MonthID, COUNT(DISTINCT memberid) AS MemberTotals
		FROM [ARSuperiorSelectData].dbo.Eligibility WITH(NOLOCK)
		GROUP BY MonthID
		ORDER BY MonthID')
		WHERE MonthID IN (SELECT MonthID FROM #Months)
	END

	IF (OBJECT_ID('tempdb..#PCP') IS NOT NULL) DROP TABLE #PCP
	SELECT 
	 YEAR(VisitDate) AS [Year]
	,MONTH(VisitDate) AS [Month]
	,TIN
	,COUNT(*) AS PCPVisits
	INTO #PCP
	FROM dbo.EDVisitHistory PCP
	JOIN dbo.Link_MemberId_MVD_Ins I ON PCP.ICENUMBER = I.MVDId
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
			) T ON I.InsMemberId = T.MemberID
	WHERE I.Cust_ID = @Cust_ID 
	AND (
		(@Cust_ID = 14 AND EXISTS (SELECT 1 FROM #M WHERE MemberId = I.InsMemberId AND LEFT(MonthID,4) = YEAR(PCP.VisitDate) AND RIGHT(MonthID,2) = MONTH(PCP.VisitDate) )
		OR @Cust_ID <> 14) ) 
	AND VisitType = 'Physician'
	AND VisitDate >= @StartDate
	AND VisitDate < @EndDate
	GROUP BY YEAR(VisitDate), MONTH(VisitDate),TIN

	IF OBJECT_ID('tempdb..#Totals') IS NOT NULL DROP TABLE #Totals;
	SELECT 
	 MT.MonthID
	,PCP.TIN
	,MT.MemberTotals
	,ISNULL(PCP.PCPVisits, 0) AS PCPVisits
	,ISNULL(PCP.PCPVisits/CAST(MT.MemberTotals AS DECIMAL(18,5))*1000*12, 0) AS PCPVisitsPer1000
	INTO #Totals
	FROM #MT MT
	LEFT JOIN #PCP PCP ON LEFT(MT.MonthID,4) = PCP.[Year] AND RIGHT(MT.MonthID,2) = PCP.[Month]

	MERGE dbo.DashboardTotalsByTin AS target  
	USING (SELECT @Cust_ID, TIN, @LOB, MonthID, PCPVisits, PCPVisitsPer1000 FROM #Totals) 
		AS source (CustID, TIN, LOB, MonthID, PCPVisits, PCPVisitsPer1000)  
	ON (target.CustID = source.CustID AND target.MonthID = source.MonthID AND ISNULL(target.TIN,'') = ISNULL(source.TIN,'') AND ISNULL(target.LOB,'') = ISNULL(source.LOB,''))  
	WHEN MATCHED THEN   
			UPDATE 
			SET	 target.PCPVisits = source.PCPVisits
					,target.PCPVisitsPer1000 = source.PCPVisitsPer1000
					,target.DateModified = GETDATE()
	WHEN NOT MATCHED THEN  
		INSERT (CustID, TIN, LOB, MonthID, PCPVisits, PCPVisitsPer1000)  
		VALUES (source.CustID, source.TIN, source.LOB, source.MonthID, source.PCPVisits, source.PCPVisitsPer1000);
		
END