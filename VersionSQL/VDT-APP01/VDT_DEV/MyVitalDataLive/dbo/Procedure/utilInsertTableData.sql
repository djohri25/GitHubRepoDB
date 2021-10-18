/****** Object:  Procedure [dbo].[utilInsertTableData]    Committed by VersionSQL https://www.versionsql.com ******/

/*
================================================================================  
Author: ezanelli
Create date: 10/24/2019
Description:
This programs ALL records from source table into destination table
IMPORTANT: care MUST BE TAKEN to insure that all records in source table
are desired for insert

Occasionally we may have the need to insert data from one system to another.
Care must be taken to insure that we don't collide with existing IDs; and,
we must create a mapping of the old IDs with the new IDs.

We should export the source data and import it into the destination schema.
For example, if we export some records from ABCBS_MemberManagement_Form from
old UAT (133), we may want to import it into new UAT (134) as a table called:
ABCBS_MemberManagement_Form2.

The utility should have parameters for: source table; and, destination table.

The utility should temporarily add a column on the destination table called:
util_insert_data_old_ID, e.g.:

ALTER TABLE ABCBS_MemberManagement_Form ADD util_insert_data_old_ID bigint;

The utility should use IDENTITY insert (with column roster for source and
destination) to transfer all records from the source table into the destination
table.

The utility should insert all old/new data mappings into utilInsertedDataIDMapping.

The utility should then drop the util_insert_data_old_ID column from the destination
table, e.g.:

ALTER TABLE ABCBS_MemberManagement_Form DROP COLUMN util_insert_data_old_ID;
=====================================================================  
*/

/*
DROP TABLE
utilInsertedDataIDMapping;
*/

/*IF ( NOT EXISTS( SELECT table_name FROM information_schema.tables WHERE table_name = 'utilInsertedDataIDMapping' ) )
	CREATE TABLE
	utilInsertedDataIDMapping
	(
		sourceTable nvarchar(255),
		sourceID bigint,
		destinationTable nvarchar(255),
		destinationID bigint
	);
	*/
/*
DROP PROCEDURE
utilInsertTableData;
*/

CREATE PROCEDURE
-- ALTER PROCEDURE
utilInsertTableData
(
	@p_sourceTable nvarchar(255),
	@p_destinationTable nvarchar(255)
)
AS
BEGIN
	DECLARE @v_sql_stmt nvarchar(max);
	DECLARE @v_source_id_name nvarchar(255) = 'util_insert_data_old_ID';
	DECLARE @v_destination_id_name nvarchar(255) = 'ID';
	DECLARE @v_column_name nvarchar(255);
	DECLARE @v_roster nvarchar(max);
	DECLARE @v_source_roster nvarchar(max);
	DECLARE @v_destination_roster nvarchar(max);

-- generate the roster from the destination table
	DECLARE roster_cursor CURSOR FOR
	SELECT
	column_name
	FROM
	information_schema.columns
	WHERE
	table_name = @p_destinationTable
	AND column_name != @v_destination_id_name
	ORDER BY
	ordinal_position;

	OPEN roster_cursor;
	FETCH roster_cursor INTO @v_column_name;

	WHILE @@FETCH_STATUS = 0
	BEGIN
		-- Create the task
		SET @v_roster = CONCAT( @v_roster, @v_column_name, ',' )
		-- Get the next record
		FETCH NEXT FROM roster_cursor INTO @v_column_name;
	
	END;

	SET @v_source_roster = CONCAT( @v_roster, @v_destination_id_name );
	SET @v_destination_roster = CONCAT( '(', @v_roster, @v_source_id_name, ')' );

	CLOSE roster_cursor;
	DEALLOCATE roster_cursor;


-- temporarily add the util_insert_data_old_ID column
	SET @v_sql_stmt = CONCAT( 'ALTER TABLE ', @p_destinationTable, ' ADD ', @v_source_id_name, ' bigint;' );
	PRINT @v_sql_stmt;

	EXECUTE sp_executesql @v_sql_stmt;

	SET @v_sql_stmt =
		CONCAT(
			'INSERT INTO ', @p_destinationTable, ' ',
			@v_destination_roster, ' ',
			'SELECT ',
			@v_source_roster, ' ',
			'FROM ',
			@p_sourceTable,
			';'
		);
	PRINT @v_sql_stmt;

	EXECUTE sp_executesql @v_sql_stmt;

	SET @v_sql_stmt =
		CONCAT(
			'INSERT INTO utilInsertedDataIDMapping( sourceTable, sourceID, destinationTable, destinationID ) ',
			'SELECT ',
			'''', @p_sourceTable, ''',',
			@v_source_id_name, ',',
			'''', @p_destinationTable, ''',',
			@v_destination_id_name, ' ',
			'FROM ',
			@p_destinationTable, ' ',
			'WHERE ', @v_source_id_name, ' IS NOT NULL',
			';'
		);
	PRINT @v_sql_stmt;

	EXECUTE sp_executesql @v_sql_stmt;

-- drop the util_insert_data_old_ID column
	SET @v_sql_stmt = CONCAT( 'ALTER TABLE ', @p_destinationTable, ' DROP COLUMN util_insert_data_old_ID;' );
	PRINT @v_sql_stmt;

	EXECUTE sp_executesql @v_sql_stmt;

END;