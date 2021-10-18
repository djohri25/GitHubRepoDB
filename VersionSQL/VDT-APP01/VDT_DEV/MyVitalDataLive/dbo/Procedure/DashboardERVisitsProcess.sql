/****** Object:  Procedure [dbo].[DashboardERVisitsProcess]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[DashboardERVisitsProcess]
	 @Cust_ID INT
	,@LOB VARCHAR(25) = NULL --'STAR' --, 'CHIP'
	,@StartDate DATE = NULL
AS

-- =============================================
-- Author: Marc De Luca
-- Create date: 01/31/2017
-- Description: Provides ER visit totals for a dashboard graph
-- Example: EXEC dbo.DashboardERVisitsProcess @Cust_ID = 10
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

	IF (OBJECT_ID('tempdb..#ER') IS NOT NULL) DROP TABLE #ER
	SELECT 
	 YEAR(VisitDate) AS [Year]
	,MONTH(VisitDate) AS [Month]
	,TIN
	,COUNT(*) AS ERVisits
	,SUM(CASE WHEN IsHospitalAdmit = 1 THEN 1 ELSE 0 END) HospitalAdmits
	INTO #ER
	FROM dbo.EDVisitHistory ER
	JOIN dbo.Link_MemberId_MVD_Ins I ON ER.ICENUMBER = I.MVDId
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
		(@Cust_ID = 14 AND EXISTS (SELECT 1 FROM #M WHERE MemberId = I.InsMemberId AND LEFT(MonthID,4) = YEAR(ER.VisitDate) AND RIGHT(MonthID,2) = MONTH(ER.VisitDate) )
		OR @Cust_ID <> 14) ) 
	AND VisitType = 'ER'
	AND VisitDate >= @StartDate
	AND VisitDate < @EndDate
	GROUP BY YEAR(VisitDate), MONTH(VisitDate),TIN

	IF OBJECT_ID('tempdb..#Totals') IS NOT NULL DROP TABLE #Totals;
	SELECT 
	 MT.MonthID
	,ER.TIN
	,MT.MemberTotals
	,ISNULL(ER.ERVisits, 0) AS ERVisits
	,ISNULL(ER.ERVisits/CAST(MT.MemberTotals AS DECIMAL(18,5))*1000*12, 0) AS ERVisitsPer1000
	,ISNULL(ER.HospitalAdmits, 0) AS HospitalAdmits
	,ISNULL(ER.HospitalAdmits/CAST(MT.MemberTotals AS DECIMAL(18,5))*1000*12,0) AS AdmissionsFromERPer1000
	INTO #Totals
	FROM #MT MT
	LEFT JOIN #ER ER ON LEFT(MT.MonthID,4) = ER.[Year] AND RIGHT(MT.MonthID,2) = ER.[Month]

	MERGE dbo.DashboardTotalsByTin AS target  
	USING (SELECT @Cust_ID, TIN, @LOB, MonthID, ERVisits, ERVisitsPer1000, HospitalAdmits, AdmissionsFromERPer1000 FROM #Totals) 
		AS source (CustID, TIN, LOB, MonthID, ERVisits, ERVisitsPer1000, HospitalAdmits, AdmissionsFromERPer1000)  
	ON (target.CustID = source.CustID AND target.MonthID = source.MonthID AND ISNULL(target.TIN,'') = ISNULL(source.TIN,'') AND ISNULL(target.LOB,'') = ISNULL(source.LOB,''))  
	WHEN MATCHED THEN   
			UPDATE 
			SET	 target.ERVisits = source.ERVisits
					,target.ERVisitsPer1000 = source.ERVisitsPer1000
					,target.HospitalAdmits = source.HospitalAdmits
					,target.AdmissionsFromERPer1000 = source.AdmissionsFromERPer1000
					,target.DateModified = GETDATE()
	WHEN NOT MATCHED THEN  
		INSERT (CustID, TIN, LOB, MonthID, ERVisits, ERVisitsPer1000, HospitalAdmits, AdmissionsFromERPer1000)  
		VALUES (source.CustID, source.TIN, source.LOB, source.MonthID, source.ERVisits, source.ERVisitsPer1000, source.HospitalAdmits, source.AdmissionsFromERPer1000);
		
END