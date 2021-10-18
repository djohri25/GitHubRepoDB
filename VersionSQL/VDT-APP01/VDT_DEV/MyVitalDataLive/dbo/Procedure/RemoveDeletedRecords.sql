/****** Object:  Procedure [dbo].[RemoveDeletedRecords]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE
RemoveDeletedRecords
(
	@p_DestinationServer nvarchar(255),
	@p_DestinationDatabase nvarchar(255),
	@p_DestinationSchema nvarchar(255),
	@p_CustomerID bigint = NULL,
	@p_PrintOnlyYN bit = 0
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @v_destination_server nvarchar(255) = CONCAT( '[', REPLACE( REPLACE( @p_DestinationServer, '[', '' ), ']', '' ), ']' );
	DECLARE @v_destination_database nvarchar(255) = CONCAT( '[', REPLACE( REPLACE( @p_DestinationDatabase, '[', '' ), ']', '' ), ']' );
	DECLARE @v_destination_schema nvarchar(255) = CONCAT( '[', REPLACE( REPLACE( @p_DestinationSchema, '[', '' ), ']', '' ), ']' );

	DECLARE @v_current_db nvarchar(255) = DB_NAME();

	DECLARE @v_batch_process_db nvarchar(255) =
		CASE
		WHEN @p_DestinationDatabase LIKE '%LIVE%' THEN 'BatchProcessStagingLive'
		WHEN @p_DestinationDatabase LIKE '%UAT%' THEN 'BatchProcessStagingUAT'
		END;

 	DECLARE @v_sql nvarchar(max);

	DECLARE @v_database_name nvarchar(255);
	DECLARE @v_schema_name nvarchar(255);
	DECLARE @v_table_name nvarchar(255);
	DECLARE @v_merge_type nvarchar(50); -- { 'Full Replace', 'Merge' }
	DECLARE @v_customer_id_column_name nvarchar(255);
	DECLARE @v_id_column_name nvarchar(255); -- the identity column name

	DECLARE @v_CustomerID bigint = 16;

-- Get the list of tables to delete from
	SET @v_sql =
		CONCAT
		(
			'DECLARE delete_cursor', CHAR(10),
			'CURSOR FOR', CHAR(10),
			'SELECT', CHAR(10),
			'DatabaseName,', CHAR(10),
			'SchemaName,', CHAR(10),
			'TableName,', CHAR(10),
			'MergeType,', CHAR(10),
			'CustomerIDColumnName,', CHAR(10),
			'IDColumnName', CHAR(10),
			'FROM', CHAR(10),
			@v_batch_process_db, '.', @p_DestinationSchema, '.', 'MVDMergeTableList', CHAR(10),
			'WHERE', CHAR(10),
			'MergeType = ''Merge''', CHAR(10),
			'AND IDColumnName IS NOT NULL', CHAR(10),
			'ORDER BY', CHAR(10),
			'1;'
		);
	EXEC sp_executesql @v_sql;

	OPEN delete_cursor;
	FETCH NEXT FROM delete_cursor INTO
		@v_database_name,
		@v_schema_name,
		@v_table_name,
		@v_merge_type,
		@v_customer_id_column_name,
		@v_id_column_name;

	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @v_sql =
			CONCAT
			(
				'DELETE FROM', CHAR(10),
				@v_destination_server, '.', @v_destination_database, '.', @v_destination_schema, '.', @v_table_name, CHAR(10),
				'WHERE', CHAR(10),
				@v_id_column_name, ' IN', CHAR(10),
				'(', CHAR(10),
				' SELECT', CHAR(10),
				' ', @v_id_column_name, CHAR(10),
				' FROM', CHAR(10),
				' ', @v_destination_server, '.', @v_destination_database, '.', @v_destination_schema, '.', @v_table_name, CHAR(10),
				' EXCEPT', CHAR(10),
				' SELECT', CHAR(10),
				' ', @v_id_column_name, CHAR(10),
				' FROM', CHAR(10),
				' ', @v_database_name, '.', @v_schema_name, '.', @v_table_name, CHAR(10),
				');'
			);

		IF ( @p_PrintOnlyYN = 1 )
		BEGIN
			PRINT @v_sql;
		END
		ELSE
		BEGIN
			EXEC sp_executesql @v_sql;
		END;

		FETCH NEXT FROM delete_cursor INTO
			@v_database_name,
			@v_schema_name,
			@v_table_name,
			@v_merge_type,
			@v_customer_id_column_name,
			@v_id_column_name;
	END;

	CLOSE delete_cursor;
	DEALLOCATE delete_cursor;

END;