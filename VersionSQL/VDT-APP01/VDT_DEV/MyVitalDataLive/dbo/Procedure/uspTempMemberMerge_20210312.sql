/****** Object:  Procedure [dbo].[uspTempMemberMerge_20210312]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE
[dbo].[uspTempMemberMerge_20210312]
(  
	@TempMemberID nvarchar(30),
	@PermMemberID nvarchar(30),
	@IsMatched bit, -- 0-No Match, 1-Match
	@ProductID int = NULL,
	@CustID int,
	@UserName nvarchar(100)
)
AS
BEGIN 

	SET NOCOUNT ON;

	DECLARE 
	@v_mvdid_temporary nvarchar(30), 
	@v_mvdid_permanent nvarchar(30), 
	@v_merged_yn bit=1,
	@v_sql nvarchar(max),
	@v_schema_name nvarchar(50),
	@v_column_name nvarchar(500),
	@v_table_name nvarchar(1000),
	@v_mvdid_column_name nvarchar(50),
	@v_temporary_member_table nvarchar(50), 
	@v_temporary_eligibility_table nvarchar(50),
	@v_now datetime = GETUTCDATE();

	SET @v_temporary_member_table = 'FinalMemberTemporary';
	SET @v_temporary_eligibility_table = 'FinalEligibilityTemporary';
	SET @v_mvdid_column_name = 'MVDID';

	SELECT
	@v_mvdid_temporary = MVDID
	FROM
	FinalMember
	WHERE
	MemberID = @TempMemberID
	AND CustID = @CustID
	AND MVDID LIKE '%TMP';

	SELECT
	@v_mvdid_permanent = MVDID
	FROM
	FinalMember
	WHERE
	MemberID = @PermMemberID
	AND CustID = @CustID
	AND MVDID NOT LIKE '%TMP';

	DROP TABLE IF EXISTS #MergeTableList;

	CREATE TABLE
	#MergeTableList
	(
		Id int identity(1,1),
		SchemaName varchar(50),
		TableName varchar(1000),
		ColumnName varchar(50)
	);

	INSERT INTO
	#MergeTableList
	(
		SchemaName,
		TableName,
		ColumnName
	)
	SELECT
	SCHEMA_NAME( t.[schema_id] ) as SchemaName,
	t.name TableName,
	c.name ColumnName
	FROM
	sys.columns c
	JOIN
	(
		SELECT
		*
		FROM
		sys.tables
		WHERE
		name NOT LIKE 'Parkland%'
		AND name NOT LIKE 'FinalClaims%'
		AND name NOT LIKE '%178'
		AND name NOT LIKE '%19'
		AND name NOT LIKE '%20%'
		AND name NOT LIKE '%bak%'
		AND name NOT LIKE '%bk%'
		AND name NOT LIKE '%old'
		AND name NOT LIKE '%temp'
		AND name NOT LIKE 'zzz%'
		AND name NOT IN
		(
			'EDVisitHistory',
			'EDVisitHistory_History',
			'FinalEligibility',
			'FinalEligibilityETL',
			'FinalEligibilityTemporary',
			'FinalLab',
			'FinalMember',
			'FinalMemberETL',
			'FinalMemberTemporary',
			'FinalRX',
			'Link_LegacyMemberId_MVD_Ins',
			'Link_MemberId_MVD_Ins',
			'MainICENUMBERGroups',
			'MainInsurance',
			'MainPersonalDetails',
			'MergeMembersOnIDLog',
			'NMW_SampleDemo'
		)
	) t
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
	#MergeTableList
	ORDER BY
	1,
	2;

	SET @v_sql =
		CONCAT
		(
			'DELETE FROM', CHAR(10),
			@v_temporary_member_table, CHAR(10),
			'WHERE', CHAR(10),
			@v_mvdid_column_name, ' = ''', @v_mvdid_temporary, ''';'
		);
	EXEC sp_executesql @v_sql;
-- PRINT @v_sql;

	SET @v_sql =
		CONCAT
		(
			'DELETE FROM', CHAR(10),
			@v_temporary_eligibility_table, CHAR(10),
			'WHERE', CHAR(10),
			@v_mvdid_column_name, ' = ''', @v_mvdid_temporary, ''';'
		);
EXEC sp_executesql @v_sql;
-- PRINT @v_sql;

	SET @v_sql =
		CONCAT
		(
			'UPDATE', CHAR(10),
			'Link_LegacyMemberId_MVD_Ins', CHAR(10),
			'SET', CHAR(10),
			'Active = 0,', CHAR(10),
			'IsArchived = 1', CHAR(10),
			'WHERE', CHAR(10),
			'MVDID = ''', @v_mvdid_temporary, '''', CHAR(10),
			'AND InsMemberId = ''', @TempMemberID, ''';'
		);
	EXEC sp_executesql @v_sql;
-- PRINT @v_sql;

	SET @v_sql =
		CONCAT
		(
			'INSERT INTO', CHAR(10),
			'MergeMembersOnIDLog', CHAR(10),
			'(', CHAR(10),
			' TempID,', CHAR(10),
			' MemberID,', CHAR(10),
			' TempMVDIDID,', CHAR(10),
			' PermMVDIDID,', CHAR(10),
			' IsMatched,', CHAR(10),
			' IsMerged,', CHAR(10),
			' CreatedDT,', CHAR(10),
			' CreatedBy', CHAR(10),
			')', CHAR(10),
			'VALUES', CHAR(10),
			'(', CHAR(10),
			'''', @TempMemberID, ''',', CHAR(10),
			'''', @PermMemberID, ''',', CHAR(10),
			'''', @v_mvdid_temporary, ''',', CHAR(10),
			'''', @v_mvdid_permanent, ''',', CHAR(10),
			CAST( @IsMatched AS varchar(1) ), ',', CHAR(10),
			CAST( @v_merged_yn AS varchar(1) ), ',', CHAR(10),
			'''',CONVERT( varchar(50), @v_now, 120 ), ''',', CHAR(10),
			'''', @UserName, '''', CHAR(10),
			');'
		);
EXEC sp_executesql @v_sql;
-- PRINT @v_sql;

	OPEN table_cursor;
	FETCH NEXT FROM table_cursor INTO
		@v_schema_name,
		@v_table_name,
		@v_column_name;

	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @v_sql =
			CONCAT
			(
				'UPDATE', CHAR(10),
				@v_schema_name, '.', @v_table_name, CHAR(10),
				'SET', CHAR(10),
				@v_column_name, ' = ''', @v_mvdid_permanent, '''', CHAR(10),
				'WHERE', CHAR(10),
				@v_column_name, ' = ''', @v_mvdid_temporary, ''';'				
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


END;