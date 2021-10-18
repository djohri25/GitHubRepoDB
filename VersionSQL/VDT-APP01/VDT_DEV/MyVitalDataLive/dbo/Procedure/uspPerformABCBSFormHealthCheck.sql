/****** Object:  Procedure [dbo].[uspPerformABCBSFormHealthCheck]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[uspPerformABCBSFormHealthCheck]
AS
BEGIN
	DECLARE @v_form_id bigint;
	DECLARE @v_form_name nvarchar(255);
	DECLARE @v_num bigint;
	DECLARE @v_num_unique bigint;
	DECLARE @v_num_hpalertnote bigint;
	DECLARE @v_num_orphans bigint;
	DECLARE @v_sql nvarchar(max);
	DECLARE @v_table_exists_yn bit = 0;

	DELETE FROM
	ABCBSFormHealthCheck;

	INSERT INTO
	ABCBSFormHealthCheck
	(
		FormID,
		FormName,
		Num,
		NumUnique,
		NumOrphans
	)
	SELECT
	FormID,
	ProcedureName,
	0,
	0,
	0
	FROM
	LookupCS_MemberNoteForms
	WHERE
	CASE
	WHEN ProcedureName LIKE 'ABCBS%' THEN 1
	WHEN ProcedureName LIKE 'ARBCBS%' THEN 1
	ELSE 0
	END = 1
	AND Active = 1;

	DECLARE form_cursor CURSOR FOR
	SELECT
	FormID,
	FormName
	FROM
	ABCBSFormHealthCheck
	ORDER BY
	2;

	OPEN form_cursor;
	FETCH NEXT FROM form_cursor INTO
		@v_form_id,
		@v_form_name;

	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @v_table_exists_yn = 0;

		SET @v_sql =
			CONCAT
			(
				'SELECT', CHAR(10),
				'@v_table_exists_yn = 1', CHAR(10),
				'FROM', CHAR(10),
				'information_schema.tables', CHAR(10),
				'WHERE', CHAR(10),
				'table_name = ''', @v_form_name, '_Form''', CHAR(10),
				'AND table_name != ''ABCBS_MemberManagement_Form'';'
			);
--PRINT @v_sql;

		EXEC sp_executesql
			@stmt = @v_sql,
			@params = N'@v_table_exists_yn bit OUTPUT',
			@v_table_exists_yn = @v_table_exists_yn OUTPUT;

		IF ( @v_table_exists_yn IS NULL )
		BEGIN
			SET @v_table_exists_yn = 0;
		END;

		IF ( @v_table_exists_yn = 1 )
		BEGIN
			SET @v_sql =
				CONCAT
				(
					'SELECT', CHAR(10),
					'@v_num = COUNT( f.id ),', CHAR(10),
					'@v_num_unique = COUNT( DISTINCT f.id ),', CHAR(10),
					'@v_num_hpalertnote = COUNT( DISTINCT hpan.first_id )', CHAR(10),
					'FROM ', @v_form_name, '_Form f', CHAR(10),
					'LEFT OUTER JOIN', CHAR(10),
					'(', CHAR(10),
					' SELECT DISTINCT', CHAR(10),
					' LinkedFormID,', CHAR(10),
					' FIRST_VALUE( ID ) OVER ( PARTITION BY LinkedFormID ORDER BY ID ) first_id', CHAR(10),
					' FROM', CHAR(10),
					' HPAlertNote', CHAR(10),
					' WHERE', CHAR(10),
					' LinkedFormType = ''', @v_form_name, '''', CHAR(10),
					') hpan', CHAR(10),
					'ON hpan.LinkedFormID = f.ID;'
				);
--PRINT @v_sql;

			EXEC sp_executesql
				@stmt = @v_sql,
				@params = N'@v_num bigint OUTPUT, @v_num_unique bigint OUTPUT, @v_num_hpalertnote bigint OUTPUT',
				@v_num = @v_num OUTPUT,
				@v_num_unique = @v_num_unique OUTPUT,
				@v_num_hpalertnote = @v_num_hpalertnote OUTPUT;
	
			SET @v_num_orphans = @v_num_unique - @v_num_hpalertnote;

			UPDATE
			ABCBSFormHealthCheck
			SET
			Num = @v_num,
			NumUnique = @v_num_unique,
			NumOrphans = @v_num_orphans
			WHERE
			FormName = @v_form_name;
		END;
	
		FETCH NEXT FROM form_cursor INTO
			@v_form_id,
			@v_form_name;
	END;

	CLOSE form_cursor;
	DEALLOCATE form_cursor;

/*
	SELECT
	*
	FROM
	ABCBSFormHealthCheck
	ORDER BY
	FormName;
*/

	DECLARE form_cursor CURSOR FOR
	SELECT
	FormID,
	FormName
	FROM
	ABCBSFormHealthCheck
	WHERE
	NumOrphans > 0
	ORDER BY
	2;

	OPEN form_cursor;
	FETCH NEXT FROM form_cursor INTO
		@v_form_id,
		@v_form_name;

	WHILE @@FETCH_STATUS = 0
	BEGIN
--		PRINT @v_form_name;

		SET @v_sql =
			CONCAT
			(
				'INSERT INTO', CHAR(10),
				'HPAlertNote', CHAR(10),
				'(', CHAR(10),
				' Note,', CHAR(10),
				' AlertStatusID,', CHAR(10),
				' DateCreated,', CHAR(10),
				' CreatedBy,', CHAR(10),
				' DateModified,', CHAR(10),
				' ModifiedBy,', CHAR(10),
				' MVDID,', CHAR(10),
				' CreatedByType,', CHAR(10),
				' ModifiedByType,', CHAR(10),
				' Active,', CHAR(10),
				' SendToHP,', CHAR(10),
				' SendToPCP,', CHAR(10),
				' SendToNurture,', CHAR(10),
				' SendToNone,', CHAR(10),
				' LinkedFormType,', CHAR(10),
				' LinkedFormID,', CHAR(10),
				' NoteTypeID,', CHAR(10),
				' CaseID,', CHAR(10),
				' IsDelete', CHAR(10),
				')', CHAR(10),
				'SELECT', CHAR(10),
				CASE
				WHEN @v_form_name = 'ABCBS_CaseSaving' THEN '''Case Savings Saved.'''
				WHEN @v_form_name = 'ABCBS_ExcessLoss' THEN '''Excess Loss Saved.'''
				WHEN @v_form_name = 'ABCBS_FEPCMScreening' THEN '''FEP CM Screening Saved.'''
				WHEN @v_form_name = 'ABCBS_FEPDMDischarge' THEN '''FEP DM Discharge Saved.'''
				WHEN @v_form_name = 'ABCBS_FEPDMEnrollment' THEN '''FEP DM Enrollment Saved.'''
				WHEN @v_form_name = 'ABCBS_FEPPharmacist' THEN
						'CASE WHEN f.SectionCompleted > 1 THEN ''Update | FEP Pharmacy Referral Updated'' ELSE ''Request | FEP Pharmacy Referral Saved'' END'
				WHEN @v_form_name = 'ABCBS_GapsInCare' THEN '''GAPS in Care Saved.'''
				WHEN @v_form_name = 'ABCBS_HEP_AdultEnrollment' THEN '''HEP Adult Enrollment Saved.'''
				WHEN @v_form_name = 'ABCBS_HEP_EDEnrollment' THEN '''Health Ed Enrollment Packet Request Saved.'''
				WHEN @v_form_name = 'ABCBS_InterdisciplinaryTeam' THEN '''Interdisciplinary Team Saved.'''
				WHEN @v_form_name = 'ABCBS_MaternityComplexAssessment' THEN '''Maternity Complex Assessment Saved.'''
				WHEN @v_form_name = 'ABCBS_MaternityEnrollment' THEN '''Maternity Enrollment Saved.'''
				WHEN @v_form_name = 'ABCBS_MaternityRiskREEvaluation' THEN '''Maternity Risk Re-Evaluation Saved.'''
				WHEN @v_form_name = 'ABCBS_MedHUB' THEN '''Med HUB Saved.'''
				WHEN @v_form_name = 'ABCBS_MemberManagement' THEN
						'CONCAT( CASE WHEN f.CaseProgram = '''' THEN ''Unknown Program'' ELSE f.CaseProgram END, '' | '', CASE WHEN f.SectionCompleted > 2 THEN ''Locked'' ELSE ''Active'' END, '' | Member Management Form Saved.'' )'
				WHEN @v_form_name = 'ABCBS_MRR' THEN '''MRR Saved.'''
				WHEN @v_form_name = 'ABCBS_NeonatalAssessment' THEN '''Neonatal Assessment Saved.'''
				WHEN @v_form_name = 'ABCBS_PreAdmitCall' THEN '''Pre-Admit Call Saved.'''
				WHEN @v_form_name = 'ABCBS_ReferraltoNewDirections' THEN '''ABCBS and New Directions Referral Form Saved.'''
				WHEN @v_form_name = 'ABCBS_TransitionOfCare' THEN '''Transition of Care Saved.'''
				WHEN @v_form_name = 'ARBCBS_ComplexAssessment' THEN '''Complex Assessment Saved.'''
				WHEN @v_form_name = 'ARBCBS_Contact' THEN '''Locked | Contact Form Saved.'''
				WHEN @v_form_name = 'ARBCBS_InitialAssessment' THEN '''Initial Assessment Saved.'''
				END, ' Note,', CHAR(10),
				'NULL AlertStatusID,', CHAR(10),
				'f.FormDate DateCreated,', CHAR(10),
				'f.FormAuthor CreatedBy,', CHAR(10),
				'f.FormDate DateModified,', CHAR(10),
				'f.FormAuthor ModifiedBy,', CHAR(10),
				'f.MVDID,', CHAR(10),
				'''HP'' CreatedByType,', CHAR(10),
				'''HP'' ModifiedByType,', CHAR(10),
				'1 Active,', CHAR(10),
				'0 SendToHP,', CHAR(10),
				'0 SendToPCP,', CHAR(10),
				'0 SendToNurture,', CHAR(10),
				'0 SendToNone,', CHAR(10),
				'''', @v_form_name,''' LinkedFormType,', CHAR(10),
				'f.ID LinkedFormID,', CHAR(10),
				'175 NoteTypeID,', CHAR(10),
				'CASE WHEN ''', @v_form_name, ''' = ''ABCBS_MemberManagement'' THEN f.ID ELSE NULL END  CaseID,', CHAR(10),
				'0 IsDelete', CHAR(10),
				'FROM ',@v_form_name, '_Form f', CHAR(10),
				'LEFT OUTER JOIN', CHAR(10),
				'(', CHAR(10),
				' SELECT DISTINCT', CHAR(10),
				' LinkedFormID,', CHAR(10),
				' FIRST_VALUE( ID ) OVER ( PARTITION BY LinkedFormID ORDER BY ID ) first_id', CHAR(10),
				' FROM', CHAR(10),
				' HPAlertNote', CHAR(10),
				' WHERE', CHAR(10),
				' LinkedFormType = ''', @v_form_name, '''', CHAR(10),
				') hpan', CHAR(10),
				'ON hpan.LinkedFormID = f.ID', CHAR(10),
				'WHERE', CHAR(10),
				'hpan.first_id IS NULL;'
			);
 --PRINT @v_sql;

		EXEC sp_executesql
			@stmt = @v_sql,
			@params = N'@v_num bigint OUTPUT, @v_num_unique bigint OUTPUT, @v_num_hpalertnote bigint OUTPUT',
			@v_num = @v_num OUTPUT,
			@v_num_unique = @v_num_unique OUTPUT,
			@v_num_hpalertnote = @v_num_hpalertnote OUTPUT;

		FETCH NEXT FROM form_cursor INTO
			@v_form_id,
			@v_form_name;
	END;

	CLOSE form_cursor;
	DEALLOCATE form_cursor;
END;