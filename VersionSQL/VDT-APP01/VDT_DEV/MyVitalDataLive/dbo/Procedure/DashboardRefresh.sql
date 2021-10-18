/****** Object:  Procedure [dbo].[DashboardRefresh]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author: Marc De Luca
-- Create date: 12/1/2017
-- Description:	Returns Monthly and YTD count of user logins
-- Example:	EXEC dbo.DashboardRefresh @CustID = 11, @Type = 'Claims'
-- =============================================
CREATE PROCEDURE [dbo].[DashboardRefresh]
	 @CustID INT
	,@Type VARCHAR(25) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	EXEC dbo.DashboardMemberTotalsProcess @Cust_ID = @CustID

	--- Claims Processed: 
	IF @Type IS NULL OR @Type = 'Claims'
		EXEC [dbo].[DashboardClaimsProcessedProcess] @CustID = @CustID

	-- Average Logins: 
	IF @Type IS NULL OR @Type = 'AvgLogins'
		EXEC [dbo].[DashboardAvgUserLoginProcess] @CustID = @CustID

	-- Average Age: 
	IF @Type IS NULL OR @Type = 'AvgAge'
		EXEC [dbo].[DashboardAverageAgeProcess] @Cust_ID = @CustID

	-- Documents: 
	IF @Type IS NULL OR @Type = 'Documents'
		EXEC [dbo].[DashboardDocumentsCreatedProcess] @CustID = @CustID

	-- EDVisits: 
	IF @Type IS NULL OR @Type = 'EDVisits'
		EXEC [dbo].[DashboardEDVisitsProcess] @CustID = @CustID

	-- ERVisits: 
	IF @Type IS NULL OR @Type = 'ERVisits'
		EXEC [dbo].[DashboardERVisitsProcess] @Cust_ID = @CustID

	-- Notes: 
	IF @Type IS NULL OR @Type = 'Notes'
		EXEC [dbo].[DashboardNotesCreatedProcess] @CustID = @CustID

	-- PageAccess: 
	IF @Type IS NULL OR @Type = 'PageAccess'
		EXEC [dbo].[DashboardPageAccessProcess] @CustID = @CustID

	-- PCPVisits: 
	IF @Type IS NULL OR @Type = 'PCPVisits'
		EXEC [dbo].[DashboardPCPVisitsProcess] @Cust_ID = @CustID

	-- UserLogins: 
	IF @Type IS NULL OR @Type = 'UserLogins'
		EXEC [dbo].[DashboardUserLoginsProcess] @CustID = @CustID

END