/****** Object:  Procedure [dbo].[uspDataScienceMergeDepressionPredictions]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE
[dbo].[uspDataScienceMergeDepressionPredictions]
AS
BEGIN
	SET NOCOUNT ON;

	MERGE INTO
	DataScienceDepressionPrediction d
	USING
	(
		SELECT DISTINCT
		fm.MVDID,
		FIRST_VALUE( d.PredictionDate ) OVER ( PARTITION BY fm.MVDID ORDER BY d.PredictionDate DESC ) PredictionDate,
		FIRST_VALUE( d.PropensityValue ) OVER ( PARTITION BY fm.MVDID ORDER BY d.PredictionDate DESC ) PropensityValue,
		FIRST_VALUE( d.ModelID ) OVER ( PARTITION BY fm.MVDID ORDER BY d.PredictionDate DESC ) ModelID
		FROM
		[vd-rpt02].Datalogy.dbo.DepressionPredictions d
		INNER JOIN FinalMember fm
		ON fm.PartyKey = d.PartyKey
		EXCEPT
		SELECT
		MVDID,
		PredictionDate,
		PropensityValue,
		ModelID
		FROM
		DataScienceDepressionPrediction
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