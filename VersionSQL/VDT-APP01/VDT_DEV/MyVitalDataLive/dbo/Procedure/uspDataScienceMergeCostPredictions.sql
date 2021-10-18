/****** Object:  Procedure [dbo].[uspDataScienceMergeCostPredictions]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE
[dbo].[uspDataScienceMergeCostPredictions]
AS
BEGIN
	SET NOCOUNT ON;

	MERGE INTO
	DataScienceCostPrediction c
	USING
	(
		SELECT DISTINCT
		fm.MVDID,
		FIRST_VALUE( c.Actual_PredictionDate ) OVER ( PARTITION BY fm.MVDID ORDER BY c.Actual_PredictionDate DESC ) PredictionDate,
		FIRST_VALUE( c.label_top10pct ) OVER ( PARTITION BY fm.MVDID ORDER BY c.Actual_PredictionDate DESC ) Top10PercentValue,
		FIRST_VALUE( c.label_decile ) OVER ( PARTITION BY fm.MVDID ORDER BY c.Actual_PredictionDate DESC ) DecileValue,
		FIRST_VALUE( c.label_bracket10k ) OVER ( PARTITION BY fm.MVDID ORDER BY c.Actual_PredictionDate DESC ) BracketValue,
		FIRST_VALUE( c.Model_ID ) OVER ( PARTITION BY fm.MVDID ORDER BY c.Actual_PredictionDate DESC ) ModelID,
		FIRST_VALUE( c.PredCost ) OVER ( PARTITION BY fm.MVDID ORDER BY c.Actual_PredictionDate DESC ) PredCost
		FROM
		[vd-rpt02].Datalogy.dbo.CostPredictions c
		INNER JOIN FinalMember fm
		ON fm.PartyKey = c.PartyKey
		EXCEPT
		SELECT
		MVDID,
		PredictionDate,
		TopTenPercentValue,
		DecileValue,
		BracketValue,
		ModelID,
		PredCost
		FROM
		DataScienceCostPrediction
	) s
	ON
	(
		s.MVDID = c.MVDID
	)
	WHEN MATCHED THEN UPDATE SET
	c.PredictionDate = s.PredictionDate,
    c.TopTenPercentValue = s.Top10PercentValue,
	c.DecileValue = s.DecileValue,
	c.BracketValue = s.BracketValue,
	c.ModelID = s.ModelID,	
	c.PredCost = s.PredCost
	WHEN NOT MATCHED THEN INSERT
	(
		MVDID,
		PredictionDate,
		TopTenPercentValue,
		DecileValue,
		BracketValue,
		ModelID,
		PredCost
	)
	VALUES
	(
		s.MVDID,
		s.PredictionDate,
		s.Top10PercentValue,
		s.DecileValue,
		s.BracketValue,
		s.ModelID,
		s.PredCost
	);
END;