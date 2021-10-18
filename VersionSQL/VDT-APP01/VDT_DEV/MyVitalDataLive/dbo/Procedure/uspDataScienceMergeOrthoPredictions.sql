/****** Object:  Procedure [dbo].[uspDataScienceMergeOrthoPredictions]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE
uspDataScienceMergeOrthoPRedictions
AS
BEGIN
	SET NOCOUNT ON;

	MERGE INTO
	DataScienceOrthoPrediction d
	USING
	(
		SELECT DISTINCT
		fm.MVDID,
		FIRST_VALUE( o.Actual_PredictionDate ) OVER ( PARTITION BY fm.MVDID ORDER BY o.Actual_PredictionDate DESC ) PredictionDate,
		FIRST_VALUE( o.PropensityValue ) OVER ( PARTITION BY fm.MVDID ORDER BY o.Actual_PredictionDate DESC ) PropensityValue,
		FIRST_VALUE( o.ModelID ) OVER ( PARTITION BY fm.MVDID ORDER BY o.Actual_PredictionDate DESC ) ModelID
		FROM
		[vd-rpt02].Datalogy.dbo.OrthoPredictions o
		INNER JOIN FinalMember fm
		ON fm.PartyKey = o.PartyKey
		EXCEPT
		SELECT
		MVDID,
		PredictionDate,
		PropensityValue,
		ModelID
		FROM
		DataScienceOrthoPrediction
	) s
	ON
	(
		s.MVDID = d.MVDID
	)
	WHEN MATCHED THEN UPDATE SET
	d.PredictionDate = s.PredictionDate,
	d.PropensityValue = s.PropensityValue,
	d.ModelID = s.ModelID	
	WHEN NOT MATCHED THEN INSERT
	(
		MVDID,
		PredictionDate,
		PropensityValue,
		ModelID
	)
	VALUES
	(
		s.MVDID,
		s.PredictionDate,
		s.PropensityValue,
		s.ModelID
	);
END;