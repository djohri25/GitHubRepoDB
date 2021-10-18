/****** Object:  Procedure [dbo].[DashboardPageAccessProcess]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author: Marc De Luca
-- Create date: 12/1/2017
-- Description:	Returns Monthly and YTD count of pages accessed
-- Example:	EXEC dbo.DashboardPageAccessProcess @CustID = 11
-- =============================================
CREATE PROCEDURE [dbo].[DashboardPageAccessProcess]
	@CustID INT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @Dates TABLE (ID INT IDENTITY(1,1), MonthID CHAR(6), StartDate DATE, EndDate DATE)

	DECLARE @LastMonth DATE, @FirstMonth DATE, @CurrentMonth DATE, @MaxCreateDate DATE, @MaxMonthID AS CHAR(6)
	
	SELECT @MaxCreateDate = MAX(CallDate) FROM dbo.StoredProcedures_Log

	SELECT @LastMonth = @MaxCreateDate
	
	SELECT @MaxMonthID = CAST(YEAR(@MaxCreateDate) AS CHAR(4)) + CASE WHEN LEN(MONTH(@MaxCreateDate)) = 1 THEN '0'+ CAST(MONTH(@MaxCreateDate) AS CHAR(1)) ELSE CAST(MONTH(@MaxCreateDate) AS CHAR(2)) END

	SELECT @FirstMonth = DATEADD(MM, -24, @LastMonth), @CurrentMonth = DATEADD(MM, -24, @LastMonth)

	WHILE @LastMonth >= @CurrentMonth
	BEGIN

		INSERT INTO @Dates (MonthID, StartDate, EndDate)
		SELECT 
		 CAST(YEAR(@CurrentMonth) AS CHAR(4))+CASE WHEN LEN(MONTH(@CurrentMonth)) = 1 THEN '0'+CAST(MONTH(@CurrentMonth) AS CHAR(1)) ELSE CAST(MONTH(@CurrentMonth) AS CHAR(2)) END
		,DATEFROMPARTS(YEAR(@CurrentMonth), MONTH(@CurrentMonth), '01')
		,DATEADD(DD, -1, DATEADD(MM, 1, DATEFROMPARTS(YEAR(@CurrentMonth), MONTH(@CurrentMonth), '01')))

		SET @CurrentMonth = DATEADD(MM, 1, @CurrentMonth)

	END

	DROP TABLE IF EXISTS #C;
	CREATE TABLE #C (CustID INT, MonthID CHAR(6), MonthlyTotal INT);

	DROP TABLE IF EXISTS #F;
	CREATE TABLE #F (CustID INT, MonthID CHAR(6), MonthlyTotal INT, YTDTotal INT);

	INSERT INTO #C (CustID, MonthID, MonthlyTotal)
	SELECT
	 @CustID AS CustID
	,CAST(YEAR(AccessDate) AS CHAR(4)) + CASE WHEN LEN(MONTH(AccessDate)) = 1 THEN '0'+ CAST(MONTH(AccessDate) AS CHAR(1)) ELSE CAST(MONTH(AccessDate) AS CHAR(2)) END AS MonthID
	,COUNT(*) AS MonthlyTotal
	FROM 
	(
	SELECT L.CallDate AS AccessDate
	FROM dbo.StoredProcedures_Log L
	JOIN dbo.MDUser u ON l.UserID = u.Username
	LEFT JOIN dbo.Link_MDAccountGroup ag on u.ID = ag.MDAccountID
	LEFT JOIN dbo.MDGroup g on ag.MDGroupID = g.ID
	WHERE L.CallDate >= @FirstMonth
	AND g.CustID_Import = @CustID
	UNION ALL
	SELECT L.CallDate AS AccessDate
	FROM dbo.StoredProcedures_Log L
	JOIN [MVDSupportLive].[dbo].[aspnet_Users] u ON LTRIM(RTRIM(SUBSTRING([Parameters],CHARINDEX('@UserName=',[Parameters],1)+10, CHARINDEX(';@AccessReason',[Parameters],1) - (CHARINDEX('@UserName=',[Parameters],1)+10)))) = u.Username
	LEFT JOIN [MVDSupportLive].[dbo].[aspnet_Membership] m ON u.UserId = m.UserId
	WHERE [Parameters] LIKE '%@UserName=%'
	AND L.CallDate >= @FirstMonth
	AND m.CustomerId = @CustID
	) PA
	GROUP BY CAST(YEAR(AccessDate) AS CHAR(4)) + CASE WHEN LEN(MONTH(AccessDate)) = 1 THEN '0'+ CAST(MONTH(AccessDate) AS CHAR(1)) ELSE CAST(MONTH(AccessDate) AS CHAR(2)) END

	INSERT INTO #F (CustID, MonthID, MonthlyTotal, YTDTotal)
	SELECT CustID, MonthID, MonthlyTotal, YTDTotal
	FROM (
		SELECT
			@CustID AS CustID
		,D.MonthID
		,ISNULL(C.MonthlyTotal, 0) AS MonthlyTotal
		,ISNULL(SUM(C.MonthlyTotal) OVER(PARTITION BY LEFT(D.MonthID,4) ORDER BY D.MonthID ROWS UNBOUNDED PRECEDING),0) AS YTDTotal
		FROM @Dates D
		LEFT JOIN #C C ON D.MonthID = C.MonthID
		GROUP BY D.MonthID, C.MonthlyTotal
	) X
	ORDER BY MonthID

	MERGE dbo.DashboardTotals AS target  
		USING (SELECT CustID, MonthID, MonthlyTotal, YTDTotal FROM #F) AS source (CustID, MonthID, MonthlyTotal, YTDTotal)  
		ON (target.CustID = source.CustID AND target.MonthID = source.MonthID)  
		WHEN MATCHED THEN   
				UPDATE 
				SET  target.PageAccessMonthlyTotal = Source.MonthlyTotal
						,target.PageAccessYearlyTotal = Source.YTDTotal
						,target.DateModified = GETDATE()
	WHEN NOT MATCHED THEN  
			INSERT (CustID, MonthID, PageAccessMonthlyTotal, PageAccessYearlyTotal)  
			VALUES (source.CustID, source.MonthID, source.MonthlyTotal, source.YTDTotal);  
END