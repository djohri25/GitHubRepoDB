/****** Object:  Procedure [dbo].[GetHedisGoals]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- EXEC dbo.GetHedisGoals @MeasurementYear = 2018
-- =============================================
CREATE PROCEDURE [dbo].[GetHedisGoals]
	@MeasurementYear INT = NULL
AS
BEGIN
	SET NOCOUNT ON;

	IF @MeasurementYear IS NULL
		SET @MeasurementYear = YEAR(GETDATE())

	DECLARE @PreviousMonthID CHAR(6)

	SET @PreviousMonthID = CAST(@MeasurementYear-1 AS CHAR(4))+'12'

	DROP TABLE IF EXISTS #G
	SELECT MeasurementYear, SubMeasureName, p25, p50, p75, p90, p95
	INTO #G
	FROM dbo.HEDISAuditMeansPercentiles
	WHERE SubMeasureName IS NOT NULL
	AND MeasurementYear = @MeasurementYear

	CREATE INDEX IX_MeasurementYear_SubMeasureName ON #G (MeasurementYear, SubMeasureName)

	DROP TABLE IF EXISTS #H
	SELECT 
	 F.TestID
	,S.Abbreviation AS SubMeasureName
	,COUNT(*) AS Denom
	,SUM(CASE WHEN F.IsTestDue = 1 THEN 1 ELSE 0 END) AS Numer
	,CAST(SUM(CASE WHEN F.IsTestDue = 1 THEN 1 ELSE 0 END) / NULLIF(CAST(COUNT(*) AS DECIMAL(12,5)),0) * 100 AS DECIMAL(5,2)) AS PreviousPctComplete
	INTO #H
	FROM dbo.Final_Hedis_Member_FULL F
	JOIN dbo.HedisSubmeasures S ON F.TestID = S.ID
	WHERE MonthID = @PreviousMonthID
	GROUP BY F.TestID, S.Abbreviation

	CREATE INDEX IX_MeasurementYear_SubMeasureName ON #H (SubMeasureName)

	SELECT 
	 H.TestID
	,H.SubMeasureName AS Measure
	,H.PreviousPctComplete
	--, G.p25, G.p50, G.p75, G.p90, G.p95
	,Goal = CASE 
					WHEN PreviousPctComplete < p25 THEN 'p25'
					WHEN PreviousPctComplete > p25 AND PreviousPctComplete < p50 THEN 'p25'
					WHEN PreviousPctComplete > p50 AND PreviousPctComplete < p75 THEN 'p50'
					WHEN PreviousPctComplete > p75 AND PreviousPctComplete < p90 THEN 'p75'
					WHEN PreviousPctComplete > p90 AND PreviousPctComplete < p95 THEN 'p90'
					WHEN PreviousPctComplete > p95 THEN 'p95'
					END
	FROM #H H
	JOIN #G G ON H.SubMeasureName = G.SubMeasureName

END