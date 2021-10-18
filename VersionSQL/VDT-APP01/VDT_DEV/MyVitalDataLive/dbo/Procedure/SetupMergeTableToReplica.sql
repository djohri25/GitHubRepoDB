/****** Object:  Procedure [dbo].[SetupMergeTableToReplica]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE
[dbo].[SetupMergeTableToReplica]
(
	@p_DestinationServer nvarchar(255),
	@p_DestinationDatabase nvarchar(255),
	@p_DestinationSchema nvarchar(255),
	@p_CustomerID bigint = NULL,
	@p_DatabaseName nvarchar(255),
	@p_SchemaName nvarchar(255),
	@p_TableName nvarchar(255),
	@p_CustomerIDColumnName nvarchar(255) = NULL,
	@p_IDColumnName nvarchar(255) = NULL, -- the identity column name
	@p_LastModifiedColumnName nvarchar(255) = NULL, -- For MergeType=Merge, this column will indicate whether the record has changed
	@p_FKColumnName nvarchar(255) = NULL, -- the identity column name
	@p_ParentDatabaseName nvarchar(255) = NULL,
	@p_ParentSchemaName nvarchar(255) = NULL,
	@p_ParentTableName nvarchar(255) = NULL, -- For MergeType=Merge, tables without a last modified column will be merged based on the parent table
	@p_ParentTableCustomerIDColumnName nvarchar(255) = NULL,
	@p_ParentTableIDColumnName nvarchar(255) = NULL, -- the identity column name for parent table
	@p_ParentTableLastModifiedColumnName nvarchar(255) = NULL, -- the last modified column for parent table
	@p_PrintOnlyYN bit = 0,
	@p_ForceYN bit = 0
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @v_destination_server nvarchar(255) = CONCAT( '[', REPLACE( REPLACE( @p_DestinationServer, '[', '' ), ']', '' ), ']' );
	DECLARE @v_destination_database nvarchar(255) = CONCAT( '[', REPLACE( REPLACE( @p_DestinationDatabase, '[', '' ), ']', '' ), ']' );
	DECLARE @v_destination_schema nvarchar(255) = CONCAT( '[', REPLACE( REPLACE( @p_DestinationSchema, '[', '' ), ']', '' ), ']' );

 	DECLARE @v_sql nvarchar(max);
	DECLARE @v_column_name nvarchar(255);
	DECLARE @v_table_exists_yn bit = 0;
	DECLARE @v_idx int = 0;
	DECLARE @v_running_yn bit = 0;
	DECLARE @v_select_roster nvarchar(max) = '';
	DECLARE @v_max_updated_date datetime;
	DECLARE @v_date date = getDate();
	DECLARE @v_datestr nvarchar(8) = CONCAT( YEAR( @v_date ), RIGHT( CONCAT( '0', MONTH( @v_date ) ), 2 ), RIGHT( CONCAT( '0', DAY( @v_date ) ), 2 ) );

	DECLARE @v_current_db nvarchar(255) = DB_NAME();

	DECLARE @v_destination_batch_process_db nvarchar(255) =
		CASE
		WHEN @p_DestinationDatabase LIKE '%LIVE%' THEN 'BatchProcessAdhocLive'
		WHEN @p_DestinationDatabase LIKE '%UAT%' THEN 'BatchProcessAdhocUAT'
		END;

	DECLARE @v_staging_batch_process_db nvarchar(255) =
		CASE
		WHEN @p_DestinationDatabase LIKE '%LIVE%' THEN 'BatchProcessStagingLive'
		WHEN @p_DestinationDatabase LIKE '%UAT%' THEN 'BatchProcessStagingUAT'
		END;

-- Make sure that the table exists on the source
	SELECT
	@v_table_exists_yn = 1
	FROM
	information_schema.tables
	WHERE
	table_catalog = REPLACE( REPLACE( @p_DatabaseName, '[', '' ), ']', '' )
	AND table_schema = REPLACE( REPLACE( @p_SchemaName, '[', '' ), ']', '' )
	AND table_name = @p_TableName;

	IF ( @v_table_exists_yn IS NULL )
	BEGIN
		SET @v_table_exists_yn = 0;
	END;

	IF ( @v_table_exists_yn = 0 )
	BEGIN
		RETURN -1;
	END;

-- Compare source table roster with destination table roster
-- For now we will presume that they are the same

-- Get the roster from destination table
	SET @v_sql =
		CONCAT
		(
			'DECLARE roster_cursor', CHAR(10),
			'CURSOR FOR', CHAR(10),
			'SELECT', CHAR(10),
			'cs.column_name', CHAR(10),
			'FROM', CHAR(10),
-- source table
			@p_DatabaseName, '.information_schema.columns cs', CHAR(10),
-- source staging table
			'INNER JOIN ', @v_staging_batch_process_db, '.information_schema.columns css', CHAR(10),
			'ON css.table_catalog = REPLACE( REPLACE( ''', @v_staging_batch_process_db, ''', ''['', '''' ), '']'', '''' )', CHAR(10),
			'AND css.table_schema = REPLACE( REPLACE( ''', @p_SchemaName, ''', ''['', '''' ), '']'', '''' )', CHAR(10),
			'AND css.table_name = cs.table_name', CHAR(10),
			'AND css.column_name = cs.column_name', CHAR(10),
-- destination staging table
			'INNER JOIN ', @v_destination_server, '.', @v_destination_batch_process_db, '.information_schema.columns cds', CHAR(10),
			'ON cds.table_catalog = REPLACE( REPLACE( ''', @v_destination_batch_process_db, ''', ''['', '''' ), '']'', '''' )', CHAR(10),
			'AND cds.table_schema = REPLACE( REPLACE( ''', @v_destination_schema, ''', ''['', '''' ), '']'', '''' )', CHAR(10),
			'AND cds.table_name = cs.table_name', CHAR(10),
			'AND cds.column_name = cs.column_name', CHAR(10),
-- destination table
			'INNER JOIN ', @v_destination_server, '.', @v_destination_database, '.information_schema.columns cd', CHAR(10),
			'ON cd.table_catalog = REPLACE( REPLACE( ''', @v_destination_database, ''', ''['', '''' ), '']'', '''' )', CHAR(10),
			'AND cd.table_schema = REPLACE( REPLACE( ''', @v_destination_schema, ''', ''['', '''' ), '']'', '''' )', CHAR(10),
			'AND cd.table_name = cs.table_name', CHAR(10),
			'AND cd.column_name = cs.column_name', CHAR(10),
			'WHERE', CHAR(10),
			'cs.table_catalog = REPLACE( REPLACE( ''', @p_DatabaseName, ''', ''['', '''' ), '']'', '''' )', CHAR(10),
			'AND cs.table_schema = REPLACE( REPLACE( ''', @p_SchemaName, ''', ''['', '''' ), '']'', '''' )', CHAR(10),
			'AND cs.table_name = ''', @p_TableName, '''', CHAR(10),
			'ORDER BY', CHAR(10),
			'cs.ordinal_position;'
		);

	IF ( @p_PrintOnlyYN = 1 )
	BEGIN
		PRINT @v_sql;
	END;
	EXEC sp_executesql @v_sql;

	OPEN roster_cursor;
	FETCH NEXT FROM roster_cursor INTO
		@v_column_name;

	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF ( @v_idx != 0 )
		BEGIN
			SET @v_select_roster = CONCAT( @v_select_roster, CHAR(10), ', ' );
		END;

		SET @v_idx = @v_idx + 1;

		SET @v_select_roster = CONCAT( @v_select_roster, 'c.', @v_column_name );

		FETCH NEXT FROM roster_cursor INTO
			@v_column_name;
	END;

	CLOSE roster_cursor;
	DEALLOCATE roster_cursor;

	IF ( @p_LastModifiedColumnName IS NOT NULL )
	BEGIN
		SET @v_sql =
			CONCAT
			(
				'SELECT', CHAR(10),
				'@v_max_updated_date = MAX( ', @p_LastModifiedColumnName, ' )', CHAR(10),
				'FROM ', CHAR(10),
				@v_destination_server, '.', @v_destination_database, '.', @v_destination_schema, '.', @p_TableName, CHAR(10),
				';'
			);
	END
	ELSE
	BEGIN
		IF ( @p_ParentTableLastModifiedColumnName IS NOT NULL )
		BEGIN
			SET @v_sql =
				CONCAT
				(
					'SELECT', CHAR(10),
					'@v_max_updated_date = MAX( ', @p_ParentTableLastModifiedColumnName, ' )', CHAR(10),
					'FROM ', CHAR(10),
					@v_destination_server, '.', @v_destination_database, '.', @v_destination_schema, '.', @p_ParentTableName, CHAR(10),
					';'
				);
		END;
	END;

	IF ( @p_LastModifiedColumnName IS NOT NULL OR @p_ParentTableLastModifiedColumnName IS NOT NULL )
	BEGIN
		IF ( @p_PrintOnlyYN = 1 )
		BEGIN
			PRINT @v_sql;
		END
		ELSE
		BEGIN
			EXEC sp_executesql
				@stmt = @v_sql,
				@params = N'@v_max_updated_date datetime OUTPUT',
				@v_max_updated_date = @v_max_updated_date OUTPUT;
		END;
	END;

-- Delete from table on staging
	SET @v_sql =
		CONCAT
		(
			'TRUNCATE TABLE ', CHAR(10),
			@v_staging_batch_process_db, '.', @p_SchemaName, '.', @p_TableName, ';'
		);

	IF ( @p_PrintOnlyYN = 1 )
	BEGIN
		PRINT @v_sql;
	END
	ELSE
	BEGIN
		EXEC sp_executesql @v_sql;
	END;

-- Delete from table on destination
	SET @v_sql =
		CONCAT
		(
			'EXEC ', @v_destination_server, '.', @v_destination_batch_process_db, '.', @v_destination_schema, '.TruncateTable ', @p_TableName, ';'
		);

	IF ( @p_PrintOnlyYN = 1 )
	BEGIN
		PRINT @v_sql;
	END
	ELSE
	BEGIN
		EXEC sp_executesql @v_sql;
	END;

/*
	SET @v_sql =
		CONCAT
		(
			'SELECT', CHAR(10),
			'@v_running_yn = MAX(1)', CHAR(10),
			'FROM', CHAR(10),
			@v_destination_server, '.', @v_destination_batch_process_db, '.', @v_destination_schema, '.', @p_TableName, ';'
		);
	EXEC sp_executesql
		@stmt = @v_sql,
		@params = N'@v_running_yn bit OUTPUT',
		@v_running_yn = @v_running_yn OUTPUT;
*/

	IF ( @v_running_yn IS NULL )
	BEGIN
		SET @v_running_yn = 0;
	END;

	IF ( @v_running_yn = 0 )
	BEGIN
-- Insert from source into staging
		SET @v_sql =
			CONCAT
			(
				'INSERT INTO', CHAR(10),
				@v_staging_batch_process_db, '.', @p_SchemaName, '.', @p_TableName, CHAR(10),
				'(', CHAR(10),
				@v_select_roster, CHAR(10),
				')', CHAR(10),
				'SELECT', CHAR(10),
				@v_select_roster, CHAR(10),
				'FROM', CHAR(10),
				@p_DatabaseName, '.', @p_SchemaName, '.', @p_TableName, ' c', CHAR(10),
				CASE
				WHEN @p_ParentTableName IS NOT NULL THEN
					CONCAT
					(
						'INNER JOIN ', @p_ParentDatabaseName, '.', @p_ParentSchemaName, '.', @p_ParentTableName, ' p', CHAR(10),
						'ON p.', @p_ParentTableIDColumnName, ' = c.', @p_FKColumnName, CHAR(10),
/*
						CASE
						WHEN @p_ParentTableLastModifiedColumnName IS NOT NULL AND @v_max_updated_date IS NOT NULL THEN
							CONCAT
							(
								'AND p.', @p_ParentTableLastModifiedColumnName,
									' >= DATEADD( HOUR, -12, ''', @v_max_updated_date, ''' )', CHAR(10)
							)
						ELSE ''
						END,
*/
						CASE
						WHEN @p_ParentTableCustomerIDColumnName IS NOT NULL AND @p_CustomerID IS NOT NULL THEN
							CONCAT
							(
								'AND p.', @p_ParentTableCustomerIDColumnName, ' = ', @p_CustomerID, CHAR(10)
							)
						ELSE ''
						END
					)
				ELSE ''
				END,
				'WHERE', CHAR(10),
				'1 = 1', CHAR(10),
				CASE
				WHEN @p_CustomerIDColumnName IS NOT NULL AND @p_CustomerID IS NOT NULL THEN
					CONCAT
					(
						'AND ', CHAR(10),
						@p_CustomerIDColumnName, ' = ', @p_CustomerID, CHAR(10)
					)
				ELSE ''
				END,
				CASE
				WHEN @p_LastModifiedColumnName IS NOT NULL AND @v_max_updated_date IS NOT NULL THEN
					CONCAT
					(
						'AND ', @p_LastModifiedColumnName, ' >= DATEADD( HOUR, -12, ''', @v_max_updated_date, ''' )', CHAR(10)
					)
				ELSE ''
				END,
/*
				'EXCEPT', CHAR(10),
				'SELECT', CHAR(10),
				@v_select_roster, CHAR(10),
				'FROM', CHAR(10),
				@v_destination_server, '.', @v_destination_database, '.', @v_destination_schema, '.', @p_TableName, ' c', CHAR(10),
				CASE
				WHEN @p_ParentTableName IS NOT NULL THEN
					CONCAT
					(
						'INNER JOIN ', @p_ParentTableName, ' p', CHAR(10),
						'ON p.', @p_ParentTableIDColumnName, ' = c.', @p_IDColumnName, CHAR(10)
						,
						CASE
						WHEN @p_ParentTableLastModifiedColumnName IS NOT NULL AND @v_max_updated_date IS NOT NULL THEN
							CONCAT
							(
								'AND p.', @p_ParentTableLastModifiedColumnName,
									' >= DATEADD( HOUR, -12, ''', @v_max_updated_date, ''' )', CHAR(10)
							)
						ELSE ''
						END

					)
				ELSE ''
				END,
				'WHERE', CHAR(10),
				'1 = 1', CHAR(10),
				CASE
				WHEN @p_CustomerIDColumnName IS NOT NULL AND @p_CustomerID IS NOT NULL THEN
					CONCAT
					(
						'AND ', CHAR(10),
						@p_CustomerIDColumnName, ' = ', @p_CustomerID, CHAR(10)
					)
				ELSE ''
				END,
				CASE
				WHEN @p_LastModifiedColumnName IS NOT NULL AND @v_max_updated_date IS NOT NULL THEN
					CONCAT
					(
						'AND ', @p_LastModifiedColumnName, ' >= DATEADD( HOUR, -12, ''', @v_max_updated_date, ''' )', CHAR(10)
					)
				ELSE ''
				END,
*/
				';'
			);
		
		IF ( @p_PrintOnlyYN = 1 )
		BEGIN
			PRINT @v_sql;
		END
		ELSE
		BEGIN
			SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
			BEGIN TRANSACTION;
				EXEC sp_executesql @v_sql;
			COMMIT TRANSACTION;
		END;
	END;

	IF ( @v_running_yn = 0 )
	BEGIN
-- Insert from staging into destination
		SET @v_sql =
			CONCAT
			(
				'INSERT INTO', CHAR(10),
				@v_destination_server, '.', @v_destination_batch_process_db, '.', @v_destination_schema, '.', @p_TableName, CHAR(10),
				'(', CHAR(10),
				@v_select_roster, CHAR(10),
				')', CHAR(10),
				'SELECT', CHAR(10),
				@v_select_roster, CHAR(10),
				'FROM', CHAR(10),
				@v_staging_batch_process_db, '.', @p_SchemaName, '.', @p_TableName, ' c', CHAR(10),
				CASE
				WHEN @p_ParentTableName IS NOT NULL THEN
					CONCAT
					(
						'INNER JOIN ', @p_ParentDatabaseName, '.', @p_ParentSchemaName, '.', @p_ParentTableName, ' p', CHAR(10),
						'ON p.', @p_ParentTableIDColumnName, ' = c.', @p_FKColumnName, CHAR(10),
/*
						CASE
						WHEN @p_ParentTableLastModifiedColumnName IS NOT NULL AND @v_max_updated_date IS NOT NULL THEN
							CONCAT
							(
								'AND p.', @p_ParentTableLastModifiedColumnName,
									' >= DATEADD( HOUR, -12, ''', @v_max_updated_date, ''' )', CHAR(10)
							)
						ELSE ''
						END,
*/
						CASE
						WHEN @p_ParentTableCustomerIDColumnName IS NOT NULL AND @p_CustomerID IS NOT NULL THEN
							CONCAT
							(
								'AND p.', @p_ParentTableCustomerIDColumnName, ' = ', @p_CustomerID, CHAR(10)
							)
						ELSE ''
						END
					)
				ELSE ''
				END,
				'WHERE', CHAR(10),
				'1 = 1', CHAR(10),
				CASE
				WHEN @p_CustomerIDColumnName IS NOT NULL AND @p_CustomerID IS NOT NULL THEN
					CONCAT
					(
						'AND ', CHAR(10),
						@p_CustomerIDColumnName, ' = ', @p_CustomerID, CHAR(10)
					)
				ELSE ''
				END,
				CASE
				WHEN @p_LastModifiedColumnName IS NOT NULL AND @v_max_updated_date IS NOT NULL THEN
					CONCAT
					(
						'AND ', @p_LastModifiedColumnName, ' >= DATEADD( HOUR, -12, ''', @v_max_updated_date, ''' )', CHAR(10)
					)
				ELSE ''
				END,
/*
				'EXCEPT', CHAR(10),
				'SELECT', CHAR(10),
				@v_select_roster, CHAR(10),
				'FROM', CHAR(10),
				@v_destination_server, '.', @v_destination_database, '.', @v_destination_schema, '.', @p_TableName, ' c', CHAR(10),
				CASE
				WHEN @p_ParentTableName IS NOT NULL THEN
					CONCAT
					(
						'INNER JOIN ', @p_ParentTableName, ' p', CHAR(10),
						'ON p.', @p_ParentTableIDColumnName, ' = c.', @p_IDColumnName, CHAR(10)
						,
						CASE
						WHEN @p_ParentTableLastModifiedColumnName IS NOT NULL AND @v_max_updated_date IS NOT NULL THEN
							CONCAT
							(
								'AND p.', @p_ParentTableLastModifiedColumnName,
									' >= DATEADD( HOUR, -12, ''', @v_max_updated_date, ''' )', CHAR(10)
							)
						ELSE ''
						END

					)
				ELSE ''
				END,
				'WHERE', CHAR(10),
				'1 = 1', CHAR(10),
				CASE
				WHEN @p_CustomerIDColumnName IS NOT NULL AND @p_CustomerID IS NOT NULL THEN
					CONCAT
					(
						'AND ', CHAR(10),
						@p_CustomerIDColumnName, ' = ', @p_CustomerID, CHAR(10)
					)
				ELSE ''
				END,
				CASE
				WHEN @p_LastModifiedColumnName IS NOT NULL AND @v_max_updated_date IS NOT NULL THEN
					CONCAT
					(
						'AND ', @p_LastModifiedColumnName, ' >= DATEADD( HOUR, -12, ''', @v_max_updated_date, ''' )', CHAR(10)
					)
				ELSE ''
				END,
*/
				';'
			);
		
		IF ( @p_PrintOnlyYN = 1 )
		BEGIN
			PRINT @v_sql;
		END
		ELSE
		BEGIN
			EXEC sp_executesql @v_sql;
		END;
	END;

END;