/****** Object:  Procedure [dbo].[uspDataScienceMergeRenalPredictions]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE
[dbo].[uspDataScienceMergeRenalPredictions]
AS
BEGIN
	SET NOCOUNT ON;

	MERGE INTO
	DataScienceRenalPrediction r
	USING
	(
		SELECT DISTINCT
		fm.MVDID,
		FIRST_VALUE( r.Actual_PredictionDate ) OVER ( PARTITION BY fm.MVDID ORDER BY r.Actual_PredictionDate DESC ) PredictionDate,
		FIRST_VALUE( r.PropensityValue ) OVER ( PARTITION BY fm.MVDID ORDER BY r.Actual_PredictionDate DESC ) PropensityValue,
		FIRST_VALUE( r.ModelID ) OVER ( PARTITION BY fm.MVDID ORDER BY r.Actual_PredictionDate DESC ) ModelID
		FROM
		[vd-rpt02].Datalogy.dbo.RenalPredictions r
		INNER JOIN FinalMember fm
		ON fm.PartyKey = r.PartyKey
		EXCEPT
		SELECT
		MVDID,
		PredictionDate,
		PropensityValue,
		ModelID
		FROM
		DataScienceRenalPrediction
	) s
	ON
	(
		s.MVDID = r.MVDID
	)
	WHEN MATCHED THEN UPDATE SET
	r.PredictionDate = s.PredictionDate,
	r.PropensityValue = s.PropensityValue,
	r.ModelID = s.ModelID	
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