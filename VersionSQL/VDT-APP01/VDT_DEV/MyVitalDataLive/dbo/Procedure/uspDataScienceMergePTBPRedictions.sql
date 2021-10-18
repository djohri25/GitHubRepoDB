/****** Object:  Procedure [dbo].[uspDataScienceMergePTBPRedictions]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE
uspDataScienceMergePTBPRedictions
AS
BEGIN
	SET NOCOUNT ON;

	MERGE INTO
	DataSciencePreTermBirthPrediction d
	USING
	(
		SELECT DISTINCT
		fm.MVDID,
		FIRST_VALUE( ptb.ConceptionDate ) OVER ( PARTITION BY fm.MVDID ORDER BY ptb.Actual_PredictionDate DESC ) ConceptionDate,
		FIRST_VALUE( ptb.Actual_PredictionDate ) OVER ( PARTITION BY fm.MVDID ORDER BY ptb.Actual_PredictionDate DESC ) PredictionDate,
		FIRST_VALUE( ptb.PropensityValue ) OVER ( PARTITION BY fm.MVDID ORDER BY ptb.Actual_PredictionDate DESC ) PropensityValue,
		FIRST_VALUE( ptb.ModelID ) OVER ( PARTITION BY fm.MVDID ORDER BY ptb.Actual_PredictionDate DESC ) ModelID
		FROM
		[vd-rpt02].Datalogy.dbo.PTBPredictions ptb
		INNER JOIN FinalMember fm
		ON fm.PartyKey = ptb.PartyKey
		EXCEPT
		SELECT
		MVDID,
		ConceptionDate,
		PredictionDate,
		PropensityValue,
		ModelID
		FROM
		DataSciencePreTermBirthPrediction
	) s
	ON
	(
		s.MVDID = d.MVDID
	)
	WHEN MATCHED THEN UPDATE SET
	d.ConceptionDate = s.ConceptionDate,
	d.PredictionDate = s.PredictionDate,
	d.PropensityValue = s.PropensityValue,
	d.ModelID = s.ModelID	
	WHEN NOT MATCHED THEN INSERT
	(
		MVDID,
		ConceptionDate,
		PredictionDate,
		PropensityValue,
		ModelID
	)
	VALUES
	(
		s.MVDID,
		s.ConceptionDate,
		s.PredictionDate,
		s.PropensityValue,
		s.ModelID
	);
END;