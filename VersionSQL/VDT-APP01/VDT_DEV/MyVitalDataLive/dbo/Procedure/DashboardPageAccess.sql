/****** Object:  Procedure [dbo].[DashboardPageAccess]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author: Marc De Luca
-- Create date: 12/1/2017
-- Description:	Returns Monthly and YTD count of pages accessed
-- Example:	EXEC dbo.DashboardPageAccess @CustID = 11
-- =============================================
CREATE PROCEDURE [dbo].[DashboardPageAccess]
	@CustID INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT TOP (12) [CustID] ,[MonthID], MonthlyTotal, YTDTotal
	FROM
	(
	SELECT TOP (12) [CustID] ,[MonthID], [PageAccessMonthlyTotal] AS MonthlyTotal, [PageAccessYearlyTotal] AS YTDTotal
  FROM dbo.DashboardTotals
	WHERE CustID = @CustID
	AND PageAccessMonthlyTotal IS NOT NULL
	ORDER BY MonthID DESC
	) X
	ORDER BY MonthID 
END