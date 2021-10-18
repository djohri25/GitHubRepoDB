/****** Object:  Procedure [dbo].[DashboardAvgUserLogin]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author: Marc De Luca
-- Create date: 12/1/2017
-- Description:	Returns Monthly and YTD count of user logins
-- Example:	EXEC dbo.DashboardAvgUserLogin @CustID = 10
-- =============================================
CREATE PROCEDURE [dbo].[DashboardAvgUserLogin]
	@CustID INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT TOP (12) [CustID] ,[MonthID], MonthlyTotal, YTDTotal
	FROM
	(
	SELECT TOP (12) [CustID] ,[MonthID], [AvgUserLoginMonthlyTotal] AS MonthlyTotal, [AvgUserLoginYearlyTotal] AS YTDTotal
  FROM dbo.DashboardTotals
	WHERE CustID = @CustID
	AND AvgUserLoginMonthlyTotal IS NOT NULL
	ORDER BY MonthID DESC
	) X
	ORDER BY MonthID 
END