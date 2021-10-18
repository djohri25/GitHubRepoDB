/****** Object:  Procedure [dbo].[Get_HEDIS_Stats]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[Get_HEDIS_Stats]
	@CustID int
AS
BEGIN
	SET NOCOUNT ON;

	SELECT TOP (1) [LastClaimsFileName]
		,[LastClaimsServiceFromDate]
		,[LastHEDISRunDate]
		,[LastMonthIDProcessed]
		,[UpdateDate]
	FROM [dbo].[Final_HEDIS_Stats]
	WHERE CustID = @CustID
END