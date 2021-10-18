/****** Object:  Procedure [dbo].[DashboardNotesCreatedProcess]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author: Marc De Luca
-- Create date: 12/1/2017
-- Description:	Returns Monthly and YTD count of notes created
-- Example:	EXEC dbo.DashboardNotesCreatedProcess @CustID = 11
-- =============================================
CREATE PROCEDURE [dbo].[DashboardNotesCreatedProcess]
	@CustID INT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @Dates TABLE (ID INT IDENTITY(1,1), MonthID CHAR(6), StartDate DATE, EndDate DATE)

	DECLARE @LastMonth DATE, @FirstMonth DATE, @CurrentMonth DATE, @MaxCreateDate DATE, @MaxMonthID AS CHAR(6)
	
	SELECT @MaxCreateDate = MAX(C.[DateCreated]) 
		FROM dbo.HPAlertNote C
		JOIN dbo.Link_MemberId_MVD_Ins I ON C.MVDID = I.MVDId
		WHERE I.Cust_ID = @CustID
		AND C.NoteTypeID IS NOT NULL

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
	,CAST(YEAR(S.[DateCreated]) AS CHAR(4)) + CASE WHEN LEN(MONTH(S.[DateCreated])) = 1 THEN '0'+ CAST(MONTH(S.[DateCreated]) AS CHAR(1)) ELSE CAST(MONTH(S.[DateCreated]) AS CHAR(2)) END AS MonthID
	,COUNT(*) AS MonthlyTotal
	FROM dbo.HPAlertNote S
	JOIN dbo.Link_MemberId_MVD_Ins I ON S.MVDID = I.MVDId
	WHERE I.Cust_ID = @CustID
	AND S.DateCreated >= @FirstMonth
	AND S.NoteTypeID IS NOT NULL
	GROUP BY CAST(YEAR(S.[DateCreated]) AS CHAR(4)) + CASE WHEN LEN(MONTH(S.[DateCreated])) = 1 THEN '0'+ CAST(MONTH(S.[DateCreated]) AS CHAR(1)) ELSE CAST(MONTH(S.[DateCreated]) AS CHAR(2)) END

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
				SET  target.NotesCreatedMonthlyTotal = Source.MonthlyTotal
						,target.NotesCreatedYearlyTotal = Source.YTDTotal
						,target.DateModified = GETDATE()
	WHEN NOT MATCHED THEN  
			INSERT (CustID, MonthID, NotesCreatedMonthlyTotal, NotesCreatedYearlyTotal)  
			VALUES (source.CustID, source.MonthID, source.MonthlyTotal, source.YTDTotal);  
END