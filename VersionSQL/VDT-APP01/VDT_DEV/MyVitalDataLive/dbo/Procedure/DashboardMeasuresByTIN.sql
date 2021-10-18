/****** Object:  Procedure [dbo].[DashboardMeasuresByTIN]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- Example:	EXEC dbo.DashboardMeasuresByTIN @CustID = 11
-- Example:	EXEC dbo.DashboardMeasuresByTIN @CustID = 11, @TIN = '020572644'
-- Example:	EXEC dbo.DashboardMeasuresByTIN @CustID = 11, @TIN = '020572644', @NPI = '1053311829'
-- =============================================
CREATE PROCEDURE [dbo].[DashboardMeasuresByTIN]
	 @CustID INT
	,@TIN VARCHAR(15) = NULL
	,@NPI VARCHAR(15) = NULL
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @MaxMonthID CHAR(6)

	SELECT @MaxMonthID = '201712' --MAX(MonthID) FROM dbo.Final_HEDIS_Member_FULL WHERE CustID = @CustID

	DROP TABLE IF EXISTS #F
	SELECT 
	 F.TestID
	,COUNT(*) AS Denom
	,SUM(CASE WHEN F.IsTestDue = 1 THEN 1 ELSE 0 END) AS Numer
--	,CurYearToDatePerc = 	SUM(CASE WHEN F.IsTestDue = 1 THEN 1 ELSE 0 END) / CAST(COUNT(*) AS DECIMAL(18,5))
	INTO #F
	FROM dbo.Final_HEDIS_Member_FULL F
	WHERE F.CustID = @CustID
	AND F.MonthID = @MaxMonthID
	AND (@TIN IS NULL OR PCP_TIN = @TIN)
	AND (@NPI IS NULL OR PCP_NPI = @NPI)
	GROUP BY F.TestID
	HAVING SUM(CASE WHEN F.IsTestDue = 1 THEN 1 ELSE 0 END) > 0


	SELECT TOP (20)
	 F.TestID
	,S.Abbreviation AS Measure
	,S.Name AS MeasureName
	,F.Denom
	,F.Numer
	,G.Goal AS PlanGoal
--	,CAST(F.CurYearToDatePerc * 100 AS DECIMAL(8,2)) AS CurYearToDatePerc
	,dbo.GetHEDISCurYearOverallPercentage (F.TestID, @TIN, @CustID, @NPI) AS CurYearOverall
	FROM #F F
	JOIN dbo.HedisSubmeasures S ON F.TestID = S.ID
	LEFT JOIN dbo.HPTestDueGoal G ON F.TestID = G.TestDueID AND G.CustID = @CustID
	WHERE S.Abbreviation NOT LIKE 'CIS%'
	AND S.Abbreviation NOT LIKE 'ADV%'
	AND S.Abbreviation NOT LIKE 'MMA%'
	AND S.Abbreviation NOT LIKE 'MMA%'
	AND S.Abbreviation NOT LIKE 'WCC%'
	AND S.Abbreviation NOT LIKE 'CAP%'
	AND S.Abbreviation NOT LIKE 'CCS%'
	AND S.Abbreviation NOT LIKE 'DSF%'
	AND S.Abbreviation NOT LIKE 'IM%'
	AND S.Abbreviation NOT LIKE 'PPC%'
	ORDER BY S.Abbreviation

	--		-- Record SP Log
	--DECLARE @params NVARCHAR(1000) = NULL
	--SET @params = LEFT(
	-- '@CustID=' + ISNULL(CAST(@CustID AS VARCHAR(100)), 'null') + ';' 
	--+'@TIN=' + ISNULL(CAST(@TIN AS VARCHAR(100)), 'null') + ';' 
	--+'@NPI=' + ISNULL(CAST(@NPI AS VARCHAR(100)), 'null') + ';'
	--, 1000);
	
	--EXEC dbo.Set_StoredProcedures_Log '[dbo].[DashboardMeasuresByTIN]', NULL, NULL, @params

END