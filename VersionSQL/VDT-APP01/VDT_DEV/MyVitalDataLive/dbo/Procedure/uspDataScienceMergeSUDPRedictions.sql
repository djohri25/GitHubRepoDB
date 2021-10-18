/****** Object:  Procedure [dbo].[uspDataScienceMergeSUDPRedictions]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE
uspDataScienceMergeSUDPRedictions
AS
BEGIN
	SET NOCOUNT ON;

	MERGE INTO
	DataScienceSUDPrediction d
	USING
	(
		SELECT DISTINCT
		fm.MVDID,
		FIRST_VALUE( sud.Actual_PredictionDate ) OVER ( PARTITION BY fm.MVDID ORDER BY sud.Actual_PredictionDate DESC ) PredictionDate,
		FIRST_VALUE( sud.PropensityValue ) OVER ( PARTITION BY fm.MVDID ORDER BY sud.Actual_PredictionDate DESC ) PropensityValue,
		FIRST_VALUE( sud.ModelID ) OVER ( PARTITION BY fm.MVDID ORDER BY sud.Actual_PredictionDate DESC ) ModelID
		FROM
		[vd-rpt02].Datalogy.dbo.SUDPredictions sud
		INNER JOIN FinalMember fm
		ON fm.PartyKey = sud.PartyKey
		EXCEPT
		SELECT
		MVDID,
		PredictionDate,
		PropensityValue,
		ModelID
		FROM
		DataScienceSUDPrediction
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