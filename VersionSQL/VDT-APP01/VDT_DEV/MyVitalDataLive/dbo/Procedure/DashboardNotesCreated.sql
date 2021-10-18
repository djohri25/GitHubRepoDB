/****** Object:  Procedure [dbo].[DashboardNotesCreated]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author: Marc De Luca
-- Create date: 12/1/2017
-- Description:	Returns Monthly and YTD count of notes created
-- Example:	EXEC dbo.DashboardNotesCreated @CustID = 11
-- =============================================
CREATE PROCEDURE [dbo].[DashboardNotesCreated]
	@CustID INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT TOP (12) [CustID] ,[MonthID], MonthlyTotal, YTDTotal
	FROM
	(
	SELECT TOP (12) [CustID] ,[MonthID], [NotesCreatedMonthlyTotal] AS MonthlyTotal, [NotesCreatedYearlyTotal] AS YTDTotal
  FROM dbo.DashboardTotals
	WHERE CustID = @CustID
	AND NotesCreatedMonthlyTotal IS NOT NULL
	ORDER BY MonthID DESC
	) X
	ORDER BY MonthID 
END