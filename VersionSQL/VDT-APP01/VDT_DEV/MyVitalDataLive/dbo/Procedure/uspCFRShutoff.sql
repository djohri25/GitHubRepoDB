/****** Object:  Procedure [dbo].[uspCFRShutoff]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE
uspCFRShutoff
AS
BEGIN
--	DECLARE @v_job_name varchar(255) = 'Daily CFRs';
	DECLARE @v_job_name varchar(255) = 'Wait1Hour';
	DECLARE @v_cutoff_time varchar(255) = '00:00:00';
	DECLARE @v_cutoff_datetime datetime = CAST( CONCAT( CAST( getDate() AS date ), ' ', @v_cutoff_time ) AS datetime );
	DECLARE @v_is_running bit = 0;

	IF ( getDate() > @v_cutoff_datetime )
	BEGIN
		SELECT
		@v_is_running = 1
		FROM
		msdb.dbo.sysjobs sj
		CROSS APPLY
		(
			SELECT DISTINCT
			a.job_id,
			FIRST_VALUE( a.job_history_id )
				OVER ( PARTITION BY a.job_id ORDER BY session_id DESC ) job_history_id,
			FIRST_VALUE( a.start_execution_date )
				OVER ( PARTITION BY a.job_id ORDER BY session_id DESC ) start_execution_date,				
			FIRST_VALUE( a.stop_execution_date )
				OVER ( PARTITION BY a.job_id ORDER BY session_id DESC ) stop_execution_date
			FROM				
			msdb.dbo.sysjobactivity a
			WHERE
			a.job_id = sj.job_id
		) sja
		INNER JOIN msdb.dbo.sysjobhistory sjh
		ON sjh.job_id = sja.job_id
		AND sjh.step_id = 0
		WHERE
		sj.name = @v_job_name
		AND
		CASE
		WHEN sjh.run_status = 4 THEN 1
		WHEN sja.start_execution_date IS NOT NULL AND sja.stop_execution_date IS NULL THEN 1
		ELSE 0
		END = 1;
	END;

	IF ( @v_is_running = 1 )
	BEGIN
		PRINT CONCAT( @v_job_name, ' is running. Stopping job...' );

		EXEC msdb.dbo.sp_stop_job @v_job_name;

		PRINT 'Stopped.'
	END;
	ELSE
	BEGIN
		PRINT CONCAT( @v_job_name, ' is not running.' );
	END;
END;

--select @@servername;