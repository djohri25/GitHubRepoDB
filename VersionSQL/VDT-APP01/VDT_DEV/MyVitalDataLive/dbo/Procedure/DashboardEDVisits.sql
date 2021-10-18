/****** Object:  Procedure [dbo].[DashboardEDVisits]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author: Marc De Luca
-- Create date: 12/1/2017
-- Description:	Returns Monthly and YTD count of user logins
-- Example:	EXEC dbo.DashboardEDVisits @CustID = 11
-- =============================================
CREATE PROCEDURE [dbo].[DashboardEDVisits]
	@CustID INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT TOP (12) [CustID] ,[MonthID], MonthlyTotal, YTDTotal
	FROM
	(
	SELECT TOP (12) [CustID] ,[MonthID], [EDVisitsMonthlyTotal] AS MonthlyTotal, [EDVisitsYearlyTotal] AS YTDTotal
  FROM dbo.DashboardTotals
	WHERE CustID = @CustID
	AND EDVisitsMonthlyTotal IS NOT NULL
	ORDER BY MonthID DESC
	) X
	ORDER BY MonthID 
END