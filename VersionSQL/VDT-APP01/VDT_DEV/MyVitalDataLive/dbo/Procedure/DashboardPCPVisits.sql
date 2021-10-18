/****** Object:  Procedure [dbo].[DashboardPCPVisits]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[DashboardPCPVisits]
	 @Cust_ID INT
	,@LOB VARCHAR(25) = NULL --'STAR' --, 'CHIP'
	,@StartDate DATE = NULL
	,@TIN VARCHAR(15) = NULL
AS

-- =============================================
-- Author: Marc De Luca
-- Create date: 01/31/2017
-- Description: Provides PCP visit totals for a dashboard graph
-- Example: EXEC dbo.DashboardPCPVisits @Cust_ID = 10
-- =============================================

BEGIN

	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET NOCOUNT ON;

	IF @TIN IS NOT NULL
	BEGIN
		SELECT TOP (12) MonthID, MemberTotals, PCPVisits, PCPVisitsPer1000
		FROM
		(
			SELECT TOP (12) 
			 MonthID
			,MemberTotals
			,ISNULL(PCPVisits,0) AS PCPVisits
			,ISNULL(CASE MemberTotals WHEN 0 THEN 0 ELSE (PCPVisits / NULLIF((ISNULL(MemberTotals,1000) /1000),0)) END,0) AS PCPVisitsPer1000
			FROM dbo.DashboardTotalsByTin
			WHERE CustID = @Cust_ID
			AND (@LOB IS NULL OR LOB = @LOB)
			AND TIN = @TIN
			AND MemberTotals > 0
			ORDER BY MonthID DESC
		) X
		ORDER BY MonthID 
	END
	ELSE
		SELECT TOP (12) MonthID, MemberTotals, PCPVisits, PCPVisitsPer1000
		FROM
		(
			SELECT TOP (12) MonthID, MemberTotals, PCPVisits, PCPVisitsPer1000
			FROM 
			(
				SELECT 
				 MonthID
				,SUM(MemberTotals) AS MemberTotals
				,SUM(PCPVisits) AS PCPVisits
				,SUM(CASE MemberTotals WHEN 0 THEN 0 ELSE (PCPVisits / NULLIF((ISNULL(MemberTotals,1000) /1000),0)) END) AS PCPVisitsPer1000
				FROM dbo.DashboardTotalsByTin
				WHERE CustID = @Cust_ID
				AND (@LOB IS NULL OR LOB = @LOB)
				GROUP BY MonthID
				HAVING SUM(MemberTotals) > 0
			) X
			ORDER BY MonthID DESC
		) X
		ORDER BY MonthID

END