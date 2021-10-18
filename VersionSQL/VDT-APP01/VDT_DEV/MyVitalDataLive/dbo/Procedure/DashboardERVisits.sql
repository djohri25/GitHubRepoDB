/****** Object:  Procedure [dbo].[DashboardERVisits]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[DashboardERVisits]
	 @Cust_ID INT
	,@LOB VARCHAR(25) = NULL --'STAR' --, 'CHIP'
	,@StartDate DATE = NULL
	,@TIN VARCHAR(15) = NULL
AS

-- =============================================
-- Author: Marc De Luca
-- Create date: 01/31/2017
-- Description: Provides ER visit totals for a dashboard graph
-- Example: EXEC dbo.DashboardERVisits @Cust_ID = 10
-- =============================================

BEGIN

	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET NOCOUNT ON;

	IF @TIN IS NOT NULL
	BEGIN
		SELECT TOP (12) MonthID, MemberTotals, ERVisits, ERVisitsPer1000, HospitalAdmits, AdmissionsFromERPer1000
		FROM
		(
			SELECT TOP (12) 
			 MonthID
			,MemberTotals
			,ERVisits
			,CASE MemberTotals WHEN 0 THEN 0 ELSE (ERVisits / NULLIF((ISNULL(MemberTotals,1000) /1000),0)) END AS ERVisitsPer1000
			,HospitalAdmits
			,CASE HospitalAdmits WHEN 0 THEN 0 ELSE (HospitalAdmits / NULLIF((ISNULL(MemberTotals,1000) /1000),0)) END AS AdmissionsFromERPer1000
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
		SELECT TOP (12) MonthID, MemberTotals, ERVisits, ERVisitsPer1000, HospitalAdmits, AdmissionsFromERPer1000
		FROM
		(
			SELECT TOP (12) MonthID, MemberTotals, ERVisits, ERVisitsPer1000, HospitalAdmits, AdmissionsFromERPer1000
			FROM 
			(
				SELECT 
				 MonthID
				,SUM(MemberTotals) AS MemberTotals
				,SUM(ERVisits) AS ERVisits
				,SUM(CASE MemberTotals WHEN 0 THEN 0 ELSE (ERVisits / NULLIF((ISNULL(MemberTotals,1000) /1000),0)) END) AS ERVisitsPer1000
				,SUM(HospitalAdmits) AS HospitalAdmits
				,SUM(CASE HospitalAdmits WHEN 0 THEN 0 ELSE (HospitalAdmits / NULLIF((ISNULL(MemberTotals,1000) /1000),0)) END) AS AdmissionsFromERPer1000
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