/****** Object:  Procedure [dbo].[utilConfirmRequiredIndexes]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE
utilConfirmRequiredIndexes
(
-- Set to 1 to create indexes; or, 0 to list missing indexes
	@p_create_yn bit = 0
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @v_table_name nvarchar(255);
	DECLARE @v_index_name nvarchar(255);
	DECLARE @v_index_type nvarchar(50);

	DECLARE @v_sql nvarchar(max);

	DROP TABLE IF EXISTS #TableList;
	DROP TABLE IF EXISTS #MissingIndexes;
	DROP TABLE IF EXISTS #ExtraIndexes;
	DROP TABLE IF EXISTS #UnmatchedIndexes;

	CREATE TABLE #TableList( table_name nvarchar(255) );
	CREATE TABLE #MissingIndexes( table_name nvarchar(255), index_name nvarchar(255), index_type nvarchar(50) );
	CREATE TABLE #ExtraIndexes( table_name nvarchar(255), index_name nvarchar(255), index_type nvarchar(50) );
	CREATE TABLE #UnmatchedIndexes( table_name nvarchar(255), index_name nvarchar(255), index_type nvarchar(50) );

	INSERT INTO #TableList( table_name ) VALUES( 'FinalClaimsDetail' );
	INSERT INTO #TableList( table_name ) VALUES( 'FinalClaimsDetailCode' );
	INSERT INTO #TableList( table_name ) VALUES( 'FinalClaimsHeader' );
	INSERT INTO #TableList( table_name ) VALUES( 'FinalClaimsHeaderCode' );
	INSERT INTO #TableList( table_name ) VALUES( 'FinalEligibilityETL' );
	INSERT INTO #TableList( table_name ) VALUES( 'FinalLab' );
	INSERT INTO #TableList( table_name ) VALUES( 'FinalMemberETL' );
	INSERT INTO #TableList( table_name ) VALUES( 'FinalProvider' );
	INSERT INTO #TableList( table_name ) VALUES( 'FinalRX' );

	DECLARE table_cursor
	CURSOR FOR
		SELECT
		tl.table_name table_name,
		i.name index_name,
		i.type_desc index_type
		FROM
		#TableList tl
		INNER JOIN [vd-rpt02].[BatchImportABCBS].sys.indexes i
		ON 1 = 1
		INNER JOIN [vd-rpt02].[BatchImportABCBS].sys.tables t
		ON t.object_id = i.object_id
		AND t.name = REPLACE( tl.table_name, 'ETL', '' )
		WHERE
		i.name NOT LIKE '%RecordID'
		AND
		CASE
		WHEN t.name = 'FinalRX' AND i.name = 'IX_Claimkey' THEN 0
		ELSE 1
		END = 1
		EXCEPT
		SELECT
		tl.table_name table_name,
		i.name index_name,
		i.type_desc index_type
		FROM
		#TableList tl
		INNER JOIN sys.indexes i
		ON 1 = 1
		INNER JOIN sys.tables t
		ON t.object_id = i.object_id
		AND t.name = tl.table_name;

	OPEN table_cursor;
	FETCH NEXT FROM table_cursor INTO
		@v_table_name,
		@v_index_name,
		@v_index_type;

	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF ( @p_create_yn = 1 )
		BEGIN
			SET @v_sql =
				dbo.utilGetIndexCreateStatementFromRPT02( @v_table_name, @v_index_name );
			PRINT @v_sql;
			EXEC sp_executesql @v_sql;
		END
		ELSE
		BEGIN
			INSERT INTO
			#MissingIndexes
			(
				table_name,
				index_name,
				index_type
			)
			VALUES
			(
				@v_table_name,
				@v_index_name,
				@v_index_type
			);
		END;

		FETCH NEXT FROM table_cursor INTO
			@v_table_name,
			@v_index_name,
			@v_index_type;
	END;

	CLOSE table_cursor;
	DEALLOCATE table_cursor;

	IF ( @p_create_yn = 0 )
	BEGIN
		PRINT CONCAT( char(13), char( 10), 'Missing indexes:' );
		SELECT
		table_name,
		index_name,
		index_type
		FROM
		#MissingIndexes
		ORDER BY
		1,
		2;
	END;

END;