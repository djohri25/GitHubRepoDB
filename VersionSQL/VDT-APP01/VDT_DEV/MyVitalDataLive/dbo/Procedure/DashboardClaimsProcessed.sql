/****** Object:  Procedure [dbo].[DashboardClaimsProcessed]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author: Marc De Luca
-- Create date: 12/1/2017
-- Description:	Returns Monthly and YTD count of claims processed
-- Example:	EXEC dbo.DashboardClaimsProcessed @CustID = 10
-- =============================================
CREATE PROCEDURE [dbo].[DashboardClaimsProcessed]
	@CustID INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT TOP (12) [CustID] ,[MonthID], MonthlyTotal, YTDTotal
	FROM
	(
	SELECT TOP (12) [CustID] ,[MonthID], [ClaimsProcessedMonthlyTotal] AS MonthlyTotal, [ClaimsProcessedYearlyTotal] AS YTDTotal
  FROM dbo.DashboardTotals
	WHERE CustID = @CustID
	AND ClaimsProcessedMonthlyTotal IS NOT NULL
	ORDER BY MonthID DESC
	) X
	ORDER BY MonthID 
END