/****** Object:  Procedure [dbo].[Get_QualitySCMeasureYearForCustomer]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<dpatel>
-- Create date: <06/22/2016>
-- Description:	<This SP will return completed Hedis Measure year for particular measurements for a particular customer. 
--				This SP may return "current year" as a measure year because of existence of data. However as per current requirement "current year" would not be part of selection in the application.>
-- Changes: 09/04/2018 MDeLuca	Added IN ('Predictive', 'Real', '3Percent', '5Percent')
-- =============================================
CREATE PROCEDURE [dbo].[Get_QualitySCMeasureYearForCustomer]
	@customerId int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

 --   select distinct substring(MonthID,1,4) as MeasureYear, SUBSTRING(MonthID,5,2) as MeasureMonth
	--from Final_HEDIS_Member_FULL fhmf
	--inner join LookupHedis lh on fhmf.TestID = lh.ID
	--where fhmf.CustID = @customerId and
	--	  lh.TestType in ('Predictive','Real')
	--Order By MeasureYear desc, MeasureMonth asc

  SELECT DISTINCT SUBSTRING(MonthID,1,4) AS MeasureYear, SUBSTRING(MonthID,5,2) AS MeasureMonth
	FROM 
		(
			SELECT DISTINCT CustID, MonthID, TestID
			FROM [dbo].[Final_HEDIS_Member_FULL]
			WHERE CustID = @customerId
		) fhmf
	JOIN dbo.LookupHedis lh ON fhmf.TestID = lh.ID
	WHERE fhmf.CustID = @customerId 
	AND lh.TestType IN ('Predictive', 'Real', '3Percent', '5Percent')
	ORDER BY MeasureYear DESC, MeasureMonth ASC

END