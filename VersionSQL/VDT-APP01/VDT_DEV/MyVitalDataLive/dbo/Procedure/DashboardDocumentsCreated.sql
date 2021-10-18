/****** Object:  Procedure [dbo].[DashboardDocumentsCreated]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author: Marc De Luca
-- Create date: 12/1/2017
-- Description:	Returns Monthly and YTD count of documents created
-- Example:	EXEC dbo.DashboardDocumentsCreated @CustID = 11
-- =============================================
CREATE PROCEDURE [dbo].[DashboardDocumentsCreated]
	@CustID INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT TOP (12) [CustID] ,[MonthID], MonthlyTotal, YTDTotal
	FROM
	(
	SELECT TOP (12) [CustID] ,[MonthID], [DocumentsCreatedMonthlyTotal] AS MonthlyTotal, [DocumentsCreatedYearlyTotal] AS YTDTotal
  FROM dbo.DashboardTotals
	WHERE CustID = @CustID
	AND DocumentsCreatedMonthlyTotal IS NOT NULL
	ORDER BY MonthID DESC
	) X
	ORDER BY MonthID 
END