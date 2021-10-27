/****** Object:  Procedure [dbo].[SetupMergeToReplica]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE
SetupMergeToReplica
(
	@p_DestinationServer nvarchar(255),
	@p_DestinationDatabase nvarchar(255),
	@p_DestinationSchema nvarchar(255),
	@p_CustomerID bigint = NULL,
	@p_PrintOnlyYN bit = 0,
	@p_ForceYN bit = 0
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @v_DestinationServer nvarchar(255) = CONCAT( '[', REPLACE( REPLACE( @p_DestinationServer, '[', '' ), ']', '' ), ']' );
	DECLARE @v_DestinationDatabase nvarchar(255) = CONCAT( '[', REPLACE( REPLACE( @p_DestinationDatabase, '[', '' ), ']', '' ), ']' );
	DECLARE @v_DestinationSchema nvarchar(255) = CONCAT( '[', REPLACE( REPLACE( @p_DestinationSchema, '[', '' ), ']', '' ), ']' );

	DECLARE @v_current_db nvarchar(255) = DB_NAME();

	DECLARE @v_batch_process_db nvarchar(255) =
		CASE
		WHEN @p_DestinationDatabase LIKE '%LIVE%' THEN 'BatchProcessAdhocLive'
		WHEN @p_DestinationDatabase LIKE '%UAT%' THEN 'BatchProcessAdhocUAT'
		END;

 	DECLARE @v_sql nvarchar(max);

	DECLARE @v_database_name nvarchar(255);
	DECLARE @v_schema_name nvarchar(255);
	DECLARE @v_table_name nvarchar(255);
	DECLARE @v_merge_type nvarchar(50); -- { 'Full Replace', 'Merge' }
	DECLARE @v_customer_id_column_name nvarchar(255);
	DECLARE @v_id_column_name nvarchar(255); -- the identity column name
	DECLARE @v_last_modified_column_name nvarchar(255); -- For MergeType=Merge, this column will indicate whether the record has changed
	DECLARE @v_fk_column_name nvarchar(255); -- foreign key to parent table
	DECLARE @v_parent_database_name nvarchar(255);
	DECLARE @v_parent_schema_name nvarchar(255);
	DECLARE @v_parent_table_name nvarchar(255); -- For MergeType=Merge, tables without a last modified column will be merged based on the parent table
	DECLARE @v_parent_table_customer_id_column_name nvarchar(255);
	DECLARE @v_parent_table_id_column_name nvarchar(255); -- the identity column name for parent table
	DECLARE @v_parent_table_last_modified_column_name nvarchar(255); -- the last modified column for parent table

	DECLARE @v_CustomerID bigint = 16;

	DROP TABLE IF EXISTS #TableList;

	CREATE TABLE #TableList
	(
		DatabaseName nvarchar(255),
		SchemaName nvarchar(255),
		TableName nvarchar(255),
		MergeType nvarchar(50), -- { 'Full Replace', 'Merge' }
		CustomerIDColumnName nvarchar(255),
		IDColumnName nvarchar(255), -- the identity column name
		LastModifiedColumnName nvarchar(255), -- For MergeType=Merge, this column will indicate whether the record has changed
		FKColumnName nvarchar(255), -- foreign key to parent table
		ParentDatabaseName nvarchar(255),
		ParentSchemaName nvarchar(255),
		ParentTableName nvarchar(255), -- For MergeType=Merge, tables without a last modified column will be merged based on the parent table
		ParentTableCustomerIDColumnName nvarchar(255),
		ParentTableIDColumnName nvarchar(255), -- the identity column name for parent table
		ParentTableLastModifiedColumnName nvarchar(255) -- the last modified column for parent table
	);

	SET @v_sql =
		CONCAT
		(
			'INSERT INTO', CHAR(10),
			'#TableList', CHAR(10),
			'(', CHAR(10),
			'DatabaseName,', CHAR(10),
			'SchemaName,', CHAR(10),
			'TableName,', CHAR(10),
			'MergeType,', CHAR(10),
			'CustomerIDColumnName,', CHAR(10),
			'IDColumnName,', CHAR(10),
			'LastModifiedColumnName,', CHAR(10),
			'FKColumnName,', CHAR(10),
			'ParentDatabaseName,', CHAR(10),
			'ParentSchemaName,', CHAR(10),
			'ParentTableName,', CHAR(10),
			'ParentTableCustomerIDColumnName,', CHAR(10),
			'ParentTableIDColumnName,', CHAR(10),
			'ParentTableLastModifiedColumnName', CHAR(10),
			')', CHAR(10),
			'SELECT', CHAR(10),
			'DatabaseName,', CHAR(10),
			'SchemaName,', CHAR(10),
			'TableName,', CHAR(10),
			'MergeType,', CHAR(10),
			'CustomerIDColumnName,', CHAR(10),
			'IDColumnName,', CHAR(10),
			'LastModifiedColumnName,', CHAR(10),
			'FKColumnName,', CHAR(10),
			'ParentDatabaseName,', CHAR(10),
			'ParentSchemaName,', CHAR(10),
			'ParentTableName,', CHAR(10),
			'ParentTableCustomerIDColumnName,', CHAR(10),
			'ParentTableIDColumnName,', CHAR(10),
			'ParentTableLastModifiedColumnName', CHAR(10),
			'FROM', CHAR(10),
			@v_DestinationServer, '.', @v_batch_process_db, '.', @v_DestinationSchema, '.MVDMergeTableList', CHAR(10),
			'WHERE', CHAR(10),
			'DatabaseName = ''', REPLACE( REPLACE( @v_current_db, '[', '' ), ']', '' ), ''';'
		);

	EXEC sp_executesql @v_sql;

-- Get the list of tables to merge
	DECLARE merge_cursor
	CURSOR FOR
	SELECT
	DatabaseName,
	SchemaName,
	TableName,
	MergeType,
	CustomerIDColumnName,
	IDColumnName,
	LastModifiedColumnName,
	FKColumnName,
	ParentDatabaseName,
	ParentSchemaName,
	ParentTableName,
	ParentTableCustomerIDColumnName,
	ParentTableIDColumnName,
	ParentTableLastModifiedColumnName
	FROM
	#TableList
	ORDER BY
	1;

	OPEN merge_cursor;
	FETCH NEXT FROM merge_cursor INTO
		@v_database_name,
		@v_schema_name,
		@v_table_name,
		@v_merge_type,
		@v_customer_id_column_name,
		@v_id_column_name,
		@v_last_modified_column_name,
		@v_fk_column_name,
		@v_parent_database_name,
		@v_parent_schema_name,
		@v_parent_table_name,
		@v_parent_table_customer_id_column_name,
		@v_parent_table_id_column_name,
		@v_parent_table_last_modified_column_name;

	WHILE @@FETCH_STATUS = 0
	BEGIN
		EXEC SetupMergeTableToReplica
			@p_DestinationServer = @v_DestinationServer,
			@p_DestinationDatabase = @v_DestinationDatabase,
			@p_DestinationSchema = @v_DestinationSchema,
			@p_CustomerID = @p_CustomerID,
			@p_DatabaseName = @v_database_name,
			@p_SchemaName = @v_schema_name,
			@p_TableName = @v_table_name,
			@p_CustomerIDColumnName = @v_customer_id_column_name,
			@p_IDColumnName = @v_id_column_name,
			@p_LastModifiedColumnName = @v_last_modified_column_name,
			@p_FKColumnName = @v_fk_column_name,
			@p_ParentDatabaseName = @v_parent_database_name,
			@p_ParentSchemaName = @v_parent_schema_name,
			@p_ParentTableName = @v_parent_table_name,
			@p_ParentTableCustomerIDColumnName = @v_parent_table_customer_id_column_name,
			@p_ParentTableIDColumnName = @v_parent_table_id_column_name,
			@p_ParentTableLastModifiedColumnName = @v_parent_table_last_modified_column_name,
			@p_PrintOnlyYN = @p_PrintOnlyYN,
			@p_ForceYN = @p_ForceYN;

		FETCH NEXT FROM merge_cursor INTO
			@v_database_name,
			@v_schema_name,
			@v_table_name,
			@v_merge_type,
			@v_customer_id_column_name,
			@v_id_column_name,
			@v_last_modified_column_name,
			@v_fk_column_name,
			@v_parent_database_name,
			@v_parent_schema_name,
			@v_parent_table_name,
			@v_parent_table_customer_id_column_name,
			@v_parent_table_id_column_name,
			@v_parent_table_last_modified_column_name;
	END;

	CLOSE merge_cursor;
	DEALLOCATE merge_cursor;

END;