/****** Object:  Function [dbo].[utilGetIndexCreateStatementFromRPT02]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE FUNCTION
utilGetIndexCreateStatementFromRPT02
(
	@p_table_name nvarchar(255),
	@p_index_name nvarchar(255)
)
RETURNS nvarchar(max)
AS
BEGIN
	DECLARE @v_index_type nvarchar(50);
	DECLARE @v_found_yn bit = 0;
	DECLARE @v_column_name nvarchar(255);
	DECLARE @v_idx int = 0;
	DECLARE @v_sql nvarchar(max);

	SELECT
	@v_index_type = ISNULL( i.type_desc, '' ),
	@v_found_yn = 1
	FROM
	[vd-rpt02].[BatchImportABCBS].sys.indexes i
	INNER JOIN [vd-rpt02].[BatchImportABCBS].sys.tables t
	ON t.object_id = i.object_id
	AND t.name = REPLACE( @p_table_name, 'ETL', '' )
	WHERE
	i.name = @p_index_name;

	IF ( ISNULL( @v_found_yn, 0 ) = 0 )
	BEGIN
		RETURN CAST( NULL AS nvarchar(max) );
	END;

	SET @v_sql = CONCAT( 'CREATE ', @v_index_type, ' INDEX ', @p_index_name, ' ON ', @p_table_name, '( ' );

	DECLARE column_cursor
	CURSOR FOR
		SELECT
		c.name
		FROM
		[vd-rpt02].[BatchImportABCBS].sys.indexes i
		INNER JOIN [vd-rpt02].[BatchImportABCBS].sys.tables t
		ON t.object_id = i.object_id
		AND t.name = REPLACE( @p_table_name, 'ETL', '' )
		INNER JOIN [vd-rpt02].[BatchImportABCBS].sys.index_columns ic
		ON ic.object_id = t.object_id
		AND ic.index_id = i.index_id
		INNER JOIN [vd-rpt02].[BatchImportABCBS].sys.columns c
		ON c.object_id = ic.object_id
		AND c.column_id = ic.column_id
		WHERE
		i.name = @p_index_name
		ORDER BY
		ic.key_ordinal;


	OPEN column_cursor;
	FETCH NEXT FROM column_cursor INTO
		@v_column_name;

	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF ( @v_idx != 0 )
		BEGIN
			SET @v_sql = CONCAT( @v_sql, ', ' );
		END;

		SET @v_sql = CONCAT( @v_sql, @v_column_name );

		FETCH NEXT FROM column_cursor INTO
			@v_column_name;
	END;

	SET @v_sql = CONCAT( @v_sql, ' );' );

	CLOSE column_cursor;
	DEALLOCATE column_cursor;

	RETURN @v_sql;

END;