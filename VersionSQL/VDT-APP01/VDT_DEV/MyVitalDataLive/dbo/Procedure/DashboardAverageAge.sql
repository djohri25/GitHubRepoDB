/****** Object:  Procedure [dbo].[DashboardAverageAge]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[DashboardAverageAge]
	 @Cust_ID INT
	,@LOB VARCHAR(25) = NULL --'STAR' --, 'CHIP'
	,@StartDate VARCHAR(20) = NULL
	,@TIN VARCHAR(15) = NULL
AS

-- =============================================
-- Author: Marc De Luca
-- Create date: 01/30/2017
-- Description: Provides member totals for a dashboard graph
-- Example: EXEC dbo.DashboardAverageAge @Cust_ID = 10
-- =============================================

BEGIN

	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET NOCOUNT ON;
	
IF @TIN IS NOT NULL
	BEGIN
		SELECT TOP (12) MonthID, [AverageAge], [Pct Under3], [Pct Age3-10], [Pct Age11-17], [Pct Age18-26], [Pct Age27-50], [Pct Over50]
		FROM
		(
			SELECT TOP (12) MonthID
			,CAST([Age] / CAST(MemberTotals AS DECIMAL(18,2)) AS DECIMAL(5,4)) AS AverageAge
			,CAST([Under3] / CAST(MemberTotals AS DECIMAL(18,2)) AS DECIMAL(5,4)) AS [Pct Under3]
			,CAST([Age3to10] / CAST(MemberTotals AS DECIMAL(18,2)) AS DECIMAL(5,4)) AS [Pct Age3-10]
			,CAST([Age11to17] / CAST(MemberTotals AS DECIMAL(18,2)) AS DECIMAL(5,4)) AS [Pct Age11-17]
			,CAST([Age18to26] / CAST(MemberTotals AS DECIMAL(18,2)) AS DECIMAL(5,4)) AS [Pct Age18-26]
			,CAST([Age27to50] / CAST(MemberTotals AS DECIMAL(18,2)) AS DECIMAL(5,4)) AS [Pct Age27-50]
			,CAST([Over50] / CAST(MemberTotals AS DECIMAL(18,2)) AS DECIMAL(5,4)) AS [Pct Over50]
			FROM dbo.DashboardTotalsByTin
			WHERE CustID = @Cust_ID
			AND (@LOB IS NULL OR LOB = @LOB)
			AND TIN = @TIN
			ORDER BY MonthID DESC
		) X
		ORDER BY MonthID 
	END
	ELSE
		SELECT TOP (12) MonthID, [AverageAge], [Pct Under3], [Pct Age3-10], [Pct Age11-17], [Pct Age18-26], [Pct Age27-50], [Pct Over50]
		FROM
		(
			SELECT TOP (12) MonthID, [AverageAge], [Pct Under3], [Pct Age3-10], [Pct Age11-17], [Pct Age18-26], [Pct Age27-50], [Pct Over50]
			FROM 
			(
				SELECT TOP (12) MonthID
				,CAST(SUM([Age]) / CAST(SUM(MemberTotals) AS DECIMAL(18,2)) AS DECIMAL(5,4)) AS AverageAge
				,CAST(SUM([Under3]) / CAST(SUM(MemberTotals) AS DECIMAL(18,2)) AS DECIMAL(5,4)) AS [Pct Under3]
				,CAST(SUM([Age3to10]) / CAST(SUM(MemberTotals) AS DECIMAL(18,2)) AS DECIMAL(5,4)) AS [Pct Age3-10]
				,CAST(SUM([Age11to17]) / CAST(SUM(MemberTotals) AS DECIMAL(18,2)) AS DECIMAL(5,4)) AS [Pct Age11-17]
				,CAST(SUM([Age18to26]) / CAST(SUM(MemberTotals) AS DECIMAL(18,2)) AS DECIMAL(5,4)) AS [Pct Age18-26]
				,CAST(SUM([Age27to50]) / CAST(SUM(MemberTotals) AS DECIMAL(18,2)) AS DECIMAL(5,4)) AS [Pct Age27-50]
				,CAST(SUM([Over50]) / CAST(SUM(MemberTotals) AS DECIMAL(18,2)) AS DECIMAL(5,4)) AS [Pct Over50]
				FROM dbo.DashboardTotalsByTin
				WHERE CustID = @Cust_ID
				AND (@LOB IS NULL OR LOB = @LOB)
				GROUP BY MonthID
				HAVING SUM([Age]) > 0
			) X
			ORDER BY MonthID DESC
		) X
		ORDER BY MonthID


END