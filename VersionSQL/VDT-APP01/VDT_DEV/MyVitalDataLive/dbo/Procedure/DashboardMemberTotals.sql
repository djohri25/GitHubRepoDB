/****** Object:  Procedure [dbo].[DashboardMemberTotals]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[DashboardMemberTotals]
	 @Cust_ID INT
	,@LOB VARCHAR(25) = NULL --'STAR' --, 'CHIP'
	,@StartDate VARCHAR(20) = NULL
	,@TIN VARCHAR(15) = NULL
AS

-- =============================================
-- Author: Marc De Luca
-- Create date: 01/30/2017
-- Description: Provides member totals for a dashboard graph
-- Example: EXEC dbo.DashboardMemberTotals @Cust_ID = '10', @TIN = '10562155'
-- =============================================

BEGIN

	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET NOCOUNT ON;

	IF @TIN IS NOT NULL
	BEGIN
		SELECT TOP (12) MonthID, MemberTotals, NewMembers, LostMembers
		FROM
		(
			SELECT TOP (12) MonthID, MemberTotals, NewMembers, LostMembers
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
		SELECT TOP (12) MonthID, MemberTotals, NewMembers, LostMembers
		FROM
		(
			SELECT TOP (12) MonthID, MemberTotals, NewMembers, LostMembers
			FROM 
			(
				SELECT MonthID, SUM(MemberTotals) AS MemberTotals, SUM(NewMembers) AS NewMembers, SUM(LostMembers) AS LostMembers
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