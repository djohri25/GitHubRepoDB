/****** Object:  Procedure [dbo].[uspDefragmentTable]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE
[dbo].[uspDefragmentTable]
(
	@p_TableName nvarchar(255),
	@p_FragmentationThreshold float = 10
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @v_database_name nvarchar(255) = DB_NAME()
	DECLARE @v_index_name nvarchar(255);
	DECLARE @v_sql nvarchar(max);

	DECLARE index_cursor CURSOR FOR
	SELECT
	i.name
	FROM
	sys.dm_db_index_physical_stats( DB_ID( @v_database_name ), OBJECT_ID( @p_TableName ), NULL, NULL, NULL ) ipt
	INNER JOIN sys.indexes i
	ON i.object_id = ipt.object_id
	AND i.index_id = ipt.index_id
	AND i.name IS NOT NULL
	WHERE
	ipt.avg_fragmentation_in_percent >= @p_FragmentationThreshold
	ORDER BY
	1;

	OPEN index_cursor;
	FETCH NEXT FROM index_cursor INTO
		@v_index_name;

	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @v_sql = CONCAT( 'ALTER INDEX [', @v_index_name, '] ON [', @p_TableName, '] REORGANIZE;' ); 
		EXEC sp_executesql @v_sql;
		PRINT @v_sql;

		FETCH NEXT FROM index_cursor INTO
			@v_index_name;
	END;
	CLOSE index_cursor;
	DEALLOCATE index_cursor;

END;