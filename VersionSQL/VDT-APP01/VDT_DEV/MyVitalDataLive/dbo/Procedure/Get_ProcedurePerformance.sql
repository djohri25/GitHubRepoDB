/****** Object:  Procedure [dbo].[Get_ProcedurePerformance]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE
[dbo].[Get_ProcedurePerformance]
(
	@p_ProcedureName nvarchar(255)
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @v_interval_minutes int = 10;
	DECLARE @v_hour int = 0;
	DECLARE @v_minute_idx int = 0;
	DECLARE @v_minute int = 0;
	DECLARE @v_effective_date date = CAST( getDate() AS date );
	
	DROP TABLE IF EXISTS #TimeSlice;
	CREATE TABLE
	#TimeSlice
	(
		start_time datetime,
		end_time datetime
	);
	
	DROP TABLE IF EXISTS
	#PowerUsers;

	CREATE TABLE
	#PowerUsers
	(
		username nvarchar(255)
	);
	INSERT INTO #PowerUsers( username ) VALUES ( 'ARMILLER' );
	INSERT INTO #PowerUsers( username ) VALUES ( 'DBSEYMOUR' );
	INSERT INTO #PowerUsers( username ) VALUES ( 'FMPAGAN' );
	INSERT INTO #PowerUsers( username ) VALUES ( 'JRCOOK' );
	INSERT INTO #PowerUsers( username ) VALUES ( 'kareed' );
	INSERT INTO #PowerUsers( username ) VALUES ( 'TEGRAVETT' );
	INSERT INTO #PowerUsers( username ) VALUES ( 'TNTEAGUE' );
	
	-- Create table with @v_interval_minutes increments
	WHILE ( @v_hour < 24 )
	BEGIN
		SET @v_minute_idx = 0;
	
		WHILE ( @v_minute_idx < 6 )
		BEGIN
	
			SET @v_minute = @v_minute_idx * @v_interval_minutes;
			INSERT INTO
			#TimeSlice
			(
				start_time
			)
			SELECT
			DATETIMEFROMPARTS
			(
				YEAR( @v_effective_date ),
				MONTH( @v_effective_date ),
				DAY( @v_effective_date ),
				@v_hour,
				@v_minute,
				0,
				0
			);
			UPDATE
			#TimeSlice
			SET
			end_time = DATEADD( MINUTE, 10, start_time );
	
			SET @v_minute_idx = @v_minute_idx + 1;
		END;
	
		SET @v_hour = @v_hour + 1;
	END;
	
	-- SELECT * FROM #TimeSlice ORDER BY start_time;
	
	SELECT
	cq.start_time,
	cq.end_time,
	cq.longest_running_user,
	COUNT( DISTINCT cq.username ) num_total_users,
	COUNT( DISTINCT CASE WHEN cq.power_user_yn = 1 THEN cq.username ELSE NULL END ) num_power_users,
	COUNT( DISTINCT CASE WHEN cq.power_user_yn = 0 THEN cq.username ELSE NULL END ) num_non_power_users,
	MAX( cq.duration_ms ) max_duration_ms,
	AVG( cq.duration_ms ) avg_duration_ms,
	MAX( CASE WHEN cq.power_user_yn = 1 THEN 0 ELSE cq.duration_ms END ) max_non_power_user_duration_ms
	FROM
	(
		SELECT DISTINCT
		ts.start_time,
		ts.end_time,
		spei.username,
		spei.power_user_yn,
		spei.duration_ms,
		FIRST_VALUE( spei.username ) OVER ( PARTITION BY ts.start_time ORDER BY spei.duration_ms DESC ) longest_running_user
		FROM
		(
			SELECT
			spei.username,
			CASE
			WHEN pu.username IS NOT NULL THEN 1
			ELSE 0
			END power_user_yn,
			spei.start_time,
			DATEDIFF( MILLISECOND, spei.start_time, spei.end_time ) duration_ms
			FROM
			mvdSProcExecutionInfo spei
			LEFT OUTER JOIN #PowerUsers pu
			ON pu.username = spei.username
			WHERE
			spei.start_time >= @v_effective_date
			AND spei.start_time < DATEADD( DAY, 1, @v_effective_date )
			AND spei.name = @p_ProcedureName
		) spei
		INNER JOIN #TimeSlice ts
		ON ts.start_time <= spei.start_time
		AND ts.end_time > spei.start_time
	) cq
	GROUP BY
	cq.start_time,
	cq.end_time,
	cq.longest_running_user
	ORDER BY
	1 DESC;
END;