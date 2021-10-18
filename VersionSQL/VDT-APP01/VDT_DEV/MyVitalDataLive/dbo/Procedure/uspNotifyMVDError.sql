/****** Object:  Procedure [dbo].[uspNotifyMVDError]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE
uspNotifyMVDError
(
	@p_DestinationDatabase nvarchar(255)
)
AS
BEGIN 

	SET NOCOUNT ON;

	DECLARE @v_id bigint;
	DECLARE @v_error_date_time datetime;
	DECLARE @v_type nvarchar(255);
	DECLARE @v_description nvarchar(max);

	DECLARE @v_destination_batch_process_db nvarchar(255) =
		CASE
		WHEN @p_DestinationDatabase LIKE '%LIVE%' THEN 'BatchProcessAdhocLive'
		WHEN @p_DestinationDatabase LIKE '%UAT%' THEN 'BatchProcessAdhocUAT'
		END;

	DECLARE @v_sql nvarchar(max);

	SET @v_sql =
		CONCAT
		(
			'DECLARE error_cursor', CHAR(10),
			'CURSOR FOR', CHAR(10),
			'SELECT', CHAR(10),
			'ID,', CHAR(10),
			'ErrorDateTime,', CHAR(10),
			'Type,', CHAR(10),
			'Description', CHAR(10),
			'FROM', CHAR(10),
			'[VD-ADHOC].', @v_destination_batch_process_db, '.dbo.MVDError', CHAR(10),
			'WHERE', CHAR(10),
			'Notified_YN = 0;'
		);

	EXEC sp_executesql @v_sql;

	OPEN error_cursor;
	FETCH NEXT FROM error_cursor INTO
		@v_id,
		@v_error_date_time,
		@v_type,
		@v_description;

	WHILE @@FETCH_STATUS = 0
	BEGIN
		EXEC [VD-RPT02].[BatchProcessCodes].[dbo].[uspSendEmail] 'databaseteam@vitaldatatech.com', @v_type, @v_description;

		SET @v_sql =
			CONCAT
			(
				'UPDATE', CHAR(10),
				'[VD-ADHOC].', @v_destination_batch_process_db, '.dbo.MVDError', CHAR(10),
				'SET Notified_YN = 1', CHAR(10),
				'WHERE', CHAR(10),
				'ID = ', @v_id, ';'
			);

		EXEC sp_executesql @v_sql;

		FETCH NEXT FROM error_cursor INTO
			@v_id,
			@v_error_date_time,
			@v_type,
			@v_description;
	END;
END;