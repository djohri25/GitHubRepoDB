/****** Object:  Procedure [dbo].[Get_HEDIS_Summary_MonthIDs]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- Example:	EXEC [dbo].[Get_HEDIS_Summary_MonthIDs] @Product = 0, @CustID = 10, @TIN = 'ALL', @NPI = 'ALL', @LOB = 'ALL'
-- Changes: 05/08/2018	MDeLuca	Added: AND b.LOB IS NULL
-- =============================================

CREATE PROCEDURE [dbo].[Get_HEDIS_Summary_MonthIDs]
	@Product int = 0,
	@CustID int,
	@TIN varchar(50) = 'ALL',
	@NPI varchar(50) = 'ALL',
	@LOB varchar(50) = 'ALL'
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @SiteActive varchar(50) = 'PlanLink_Active'
	DECLARE @SQL nvarchar(4000)
	DECLARE @MonthIDs TABLE (ID int Identity (1,1), MonthID varchar(50))
	
	SELECT @SiteActive  = CASE @Product WHEN 1 THEN 'DRLink_Active' WHEN 2 THEN 'PlanLink_Active' WHEN 3 THEN 'AffinityQuality_Active' ELSE @SiteActive END

	SET @SQL ='
	SELECT DISTINCT a.MonthID
	FROM [dbo].[Final_HEDIS_Member_FULL] a
	JOIN [dbo].[HedisScorecard] b ON a.IsTestDue = b.SubmeasureID AND b.LOB IS NULL
	WHERE a.CustID = ' + CONVERT(varchar(10), @CustID) + '
		AND (ISNULL(b.' + @SiteActive + ', 0) = 1 OR ISNULL(b.' + @SiteActive + ', 0) = 1)
		AND (a.PCP_NPI = ''' + @NPI + ''' OR ''' + @NPI + ''' = ''ALL'')
		AND (a.PCP_TIN = ''' + @TIN + ''' OR ''' + @TIN + ''' = ''ALL'')
		AND (a.LOB = ''' + @LOB + ''' OR ''' + @LOB + ''' = ''ALL'')
	'

	INSERT INTO @MonthIDs
	EXEC SP_EXECUTESQL @SQL

	SELECT ID, MonthID
	FROM @MonthIDs
	ORDER BY MonthID DESC
END