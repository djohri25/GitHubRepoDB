/****** Object:  Procedure [dbo].[uspSetFinalSynonyms]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE
uspSetFinalSynonyms
(
	@p_PrintOnlyYN bit = 0
)
AS
BEGIN
	DECLARE @v_final1_db nvarchar(255) = 'FINAL1';
	DECLARE @v_final2_db nvarchar(255) = 'FINAL2';
	DECLARE @v_table_name nvarchar(255);
	DECLARE @v_synonym_name nvarchar(255);

	DECLARE @v_sql nvarchar(max);
	DECLARE @v_max_client_load_date datetime;
	DECLARE @v_target_db nvarchar(255);

	DROP TABLE IF EXISTS #FinalTables;
	CREATE TABLE
	#FinalTables
	(
		TableName nvarchar(255),
		SynonymName nvarchar(255)
	);

	INSERT INTO #FinalTables ( TableName ) VALUES ( 'FinalClaimsDetail' );
	INSERT INTO #FinalTables ( TableName ) VALUES ( 'FinalClaimsDetailCode' );
	INSERT INTO #FinalTables ( TableName ) VALUES ( 'FinalClaimsHeader' );
	INSERT INTO #FinalTables ( TableName ) VALUES ( 'FinalClaimsHeaderCode' );
	INSERT INTO #FinalTables ( TableName ) VALUES ( 'FinalEligibility' );
	INSERT INTO #FinalTables ( TableName ) VALUES ( 'FinalLab' );
	INSERT INTO #FinalTables ( TableName ) VALUES ( 'FinalMember' );
	INSERT INTO #FinalTables ( TableName ) VALUES ( 'FinalProvider' );
	INSERT INTO #FinalTables ( TableName ) VALUES ( 'FinalRX' );

	UPDATE #FinalTables
	SET
	SynonymName =
	CASE
	WHEN TableName IN ( 'FinalEligibility', 'FinalMember' ) THEN CONCAT( TableName, 'ETL' )
	ELSE TableName
	END;

	DECLARE final_tables_cursor
	CURSOR FOR
	SELECT
	*
	FROM
	#FinalTables
	ORDER BY
	1;

	OPEN final_tables_cursor;
	FETCH NEXT FROM final_tables_cursor INTO
		@v_table_name,
		@v_synonym_name;

-- Iterate through tables
	WHILE @@FETCH_STATUS = 0
	BEGIN
-- Determine which FINAL database is the most current for the table
		SET @v_sql =
			CONCAT
			(
				'SELECT TOP 1', CHAR(10),
				'@v_target_db = TargetDB,', CHAR(10),
				'@v_max_client_load_date = MaxClientLoadDate', CHAR(10),
				'FROM', CHAR(10),
				'(', CHAR(10),
				' SELECT', CHAR(10),
				' ''', @v_final1_db, ''' TargetDB,', CHAR(10),
				' MAX( ClientLoadDt ) MaxClientLoadDate', CHAR(10),
				' FROM', CHAR(10),
				' ', @v_final1_db, '.dbo.', @v_table_name, CHAR(10),
				' UNION', CHAR(10),
				' SELECT', CHAR(10),
				' ''', @v_final2_db, ''' TargetDB,', CHAR(10),
				' MAX( ClientLoadDt )', CHAR(10),
				' FROM', CHAR(10),
				' ', @v_final2_db, '.dbo.', @v_table_name, CHAR(10),
				') f', CHAR(10),
				'ORDER BY', CHAR(10),
				'2 DESC;'
			);

		EXEC sp_executesql
			@stmt = @v_sql,
			@params = N'@v_target_db nvarchar(255) OUTPUT, @v_max_client_load_date datetime OUTPUT',
			@v_target_db = @v_target_db OUTPUT,
			@v_max_client_load_date = @v_max_client_load_date OUTPUT;

		IF ( @v_target_db IS NULL )
		BEGIN
			SET @v_target_db = @v_final1_db;
		END;

-- Drop syonym if exists
		SET @v_sql =
			CONCAT
			(
				'DROP SYNONYM IF EXISTS', CHAR(10),
				@v_synonym_name, ';'
			);

		IF ( @p_PrintOnlyYN = 1 )
		BEGIN
			PRINT @v_sql;
		END
		ELSE
		BEGIN
			EXEC sp_executesql @v_sql;
		END;

-- Create the synonym
		SET @v_sql =
			CONCAT
			(
				'CREATE SYNONYM', CHAR(10),
				@v_synonym_name, CHAR(10),
				'FOR', CHAR(10),
				@v_target_db, '.dbo.', @v_table_name, ';'
			);

		IF ( @p_PrintOnlyYN = 1 )
		BEGIN
			PRINT @v_sql;
		END
		ELSE
		BEGIN
			EXEC sp_executesql @v_sql;
		END;

		FETCH NEXT FROM final_tables_cursor INTO
			@v_table_name,
			@v_synonym_name;
	END;
	CLOSE final_tables_cursor;
	DEALLOCATE final_tables_cursor;

END;