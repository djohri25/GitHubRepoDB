/****** Object:  Procedure [dbo].[uspGetMemberReach]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE
uspGetMemberReach
(  
	@p_MVDID nvarchar(30),
	@p_ProductID bigint = NULL,
	@p_CustomerID bigint
)
AS
BEGIN
	DECLARE @v_schema_name nvarchar(50);
	DECLARE @v_column_name nvarchar(500);
	DECLARE @v_table_name nvarchar(1000);
	DECLARE @v_sql nvarchar(max);
	DECLARE @v_num bigint;

	DROP TABLE IF EXISTS #TableList;

	CREATE TABLE
	#TableList
	(
		Id int identity(1,1),
		SchemaName varchar(50),
		TableName varchar(1000),
		ColumnName varchar(50),
		Num bigint
	);

	INSERT INTO
	#TableList
	(
		SchemaName,
		TableName,
		ColumnName,
		Num
	)
	SELECT
	SCHEMA_NAME( t.[schema_id] ) as SchemaName,
	t.name TableName,
	c.name ColumnName,
	0 num
	FROM
	sys.columns c
	INNER JOIN sys.tables t
	ON t.object_id = c.object_id
	WHERE
	CASE
	WHEN c.name like '%IceNumber%' THEN 1
	WHEN c.name LIKE '%MVDID%' THEN 1
	ELSE 0
	END = 1
	ORDER BY
	TableName,
	ColumnName;

	DECLARE table_cursor
	CURSOR FOR
	SELECT
	SchemaName,
	TableName,
	ColumnName
	FROM
	#TableList
	ORDER BY
	1,
	2;

	OPEN table_cursor;
	FETCH NEXT FROM table_cursor INTO
		@v_schema_name,
		@v_table_name,
		@v_column_name;

	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @v_num = 0;

		SET @v_sql =
			CONCAT
			(
				'SELECT', CHAR(10),
				'@v_num = COUNT(1)', CHAR(10),
				'FROM', CHAR(10),
				@v_table_name, CHAR(10),
				'WHERE', CHAR(10),
				@v_column_name, ' = ''', @p_MVDID, ''';'				
			);
		EXEC sp_executesql
			@stmt = @v_sql,
			@params = N'@v_num bigint OUTPUT',
			@v_num = @v_num OUTPUT;

		SET @v_sql =
			CONCAT
			(
				'UPDATE', CHAR(10),
				'#TableList', CHAR(10),
				'SET', CHAR(10),
				'num = ', @v_num, CHAR(10),
				'WHERE', CHAR(10),
				'TableName = ''', @v_table_name, ''';'
			);
		EXEC sp_executesql @v_sql;
-- PRINT @v_sql;

		FETCH NEXT FROM table_cursor INTO
			@v_schema_name,
			@v_table_name,
			@v_column_name;
	END;

	CLOSE table_cursor;
	DEALLOCATE table_cursor;

	SELECT
	*
	FROM
	#TableList
	ORDER BY
	1;

END;