/****** Object:  Procedure [dbo].[utilTruncateResetIdentity]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE
utilTruncateResetIdentity
(
	@p_sourceTable nvarchar(255)
)
AS
BEGIN
	DECLARE @v_process_yn bit = 0;
	DECLARE @v_sql_stmt nvarchar(max);

	PRINT CONCAT( 'Processing ', @p_sourceTable, '...' );

	SET @v_process_yn =
		CASE
		WHEN @p_sourceTable = 'FinalEligibilityTemporary' THEN 1
		WHEN @p_sourceTable = 'FinalMemberTemporary' THEN 1
		WHEN @p_sourceTable = 'Final_MemberOwner' THEN 1
		WHEN @p_sourceTable LIKE '%LOOKUP%' THEN 0
		WHEN @p_sourceTable LIKE '%FINAL%' THEN 0
		ELSE 1
		END;

	IF ( @v_process_yn = 0 )
	BEGIN
		PRINT CONCAT( 'Unable to process ', @p_sourceTable );
	END;

	IF ( @v_process_yn = 1 )
	BEGIN
		SET @v_sql_stmt = CONCAT( 'TRUNCATE TABLE ', @p_sourceTable, ';' );
		PRINT @v_sql_stmt;

		EXECUTE sp_executesql @v_sql_stmt;

		PRINT 'Table truncated.';

		SET @v_sql_stmt = CONCAT( 'DBCC CHECKIDENT( ', @p_sourceTable, ', RESEED, 1 );' );
		PRINT @v_sql_stmt;

		EXECUTE sp_executesql @v_sql_stmt;

		PRINT 'IDENTITY reset.';
	END;

END;