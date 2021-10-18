/****** Object:  Procedure [dbo].[uspRebuildFragmentedIndexes]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE
uspRebuildFragmentedIndexes
(
	@p_FragmentationThreshold float = 10
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @v_table_name nvarchar(255);

	DECLARE table_cursor CURSOR FOR
	SELECT
	table_name
	FROM
	information_schema.tables
	WHERE
	table_schema = 'dbo'
	ORDER BY
	1;

	OPEN table_cursor;
	FETCH NEXT FROM table_cursor INTO
		@v_table_name;

	WHILE @@FETCH_STATUS = 0
	BEGIN
		EXEC uspDefragmentTable @p_TableName = @v_table_name, @p_FragmentationThreshold  = @p_FragmentationThreshold;

		FETCH NEXT FROM table_cursor INTO
			@v_table_name;
	END;
	CLOSE table_cursor;
	DEALLOCATE table_cursor;

END;