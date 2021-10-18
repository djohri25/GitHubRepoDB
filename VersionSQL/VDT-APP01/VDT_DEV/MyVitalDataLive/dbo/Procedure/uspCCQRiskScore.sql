/****** Object:  Procedure [dbo].[uspCCQRiskScore]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[uspCCQRiskScore] 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @v_today datetime = getDate();
	DECLARE @v_max float
	DECLARE @v_min float
	DECLARE @v_period varchar(6) = '201811' -- a year ago YYYYMM

	SELECT
	@v_period = CONCAT( YEAR( DATEADD( YEAR, -1, @v_today ) ), RIGHT( CONCAT( '0', MONTH( @v_today ) ), 2 ) );

	DROP TABLE IF EXISTS #TempElix;

	SELECT
	MVDID,
	SUM(VW) VW
	INTO #TempElix 
	FROM
	(
		select
		A.MVDID,
		A.GroupID,
		CASE
		WHEN Elixhauser_score > 0 THEN
		EG.VW_Weight
		ELSE 0
		END VW
		FROM
		(
			SELECT DISTINCT
			E.MVDID,
			E.GroupID,
			SUM( E.Elixhauser_Score ) Elixhauser_score
			FROM
			ElixMemberRisk E
			INNER JOIN FinalEligibilityETL CCQ
			ON CCQ.MVDID = E.MVDID
			WHERE
			E.monthid > @v_period
			AND ISNULL( CCQ.MemberTerminationDate, '9999-12-31' ) >= @v_today
			GROUP BY
			E.MVDID, E.GroupID
		) A
		INNER JOIN LookupElixGroup EG
		ON EG.GroupID = A.GroupID
	) B
	GROUP BY MVDID

	SELECT
	@v_min = MIN(VW),
	@v_max = MAX(VW)
	FROM
	#TempElix;

-- We want to update ComputedCareQueue with the final Risk Score, matching on MVDID.
	MERGE INTO
	ComputedCareQueue d
	USING
	(
		SELECT
		MVDID,
		CASE
		WHEN FLOOR( ( ( ( VW - @v_min ) / @v_max ) * 10) ) > 10 THEN 10
		ELSE FLOOR( ( ( ( VW - @v_min ) / @v_max ) * 10) )
		END RiskScore
		FROM
		#TempElix
	) s
	ON
	(
		s.MVDID = d.MVDID
	)
	WHEN MATCHED THEN UPDATE SET
	d.RiskGroupID = s.RiskScore;

END;