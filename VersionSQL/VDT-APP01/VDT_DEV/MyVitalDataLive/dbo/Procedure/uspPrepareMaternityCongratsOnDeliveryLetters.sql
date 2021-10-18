/****** Object:  Procedure [dbo].[uspPrepareMaternityCongratsOnDeliveryLetters]    Committed by VersionSQL https://www.versionsql.com ******/

/*
11/1/2021		SunilNokku		Readuncommitted on MMF
1/13/2021		Sunil Nokku		Remove MVDIsNull Function
*/

CREATE PROCEDURE
[dbo].[uspPrepareMaternityCongratsOnDeliveryLetters]
(
	@p_CustomerId int = NULL,
	@p_ProductId int = NULL
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @v_procedure_name nvarchar(255) = 'uspPrepareMaternityCongratsOnDeliveryLetters';
	DECLARE @v_birth_threshold_weeks int = 2;
	DECLARE @v_birth_threshold_days int = @v_birth_threshold_weeks * 7;

	DECLARE @v_member_mailing nvarchar(255) = '%Congrats on Delivery%';

	DECLARE @v_user_name nvarchar(255);
	DECLARE @v_letter_name nvarchar(255) = 'Maternity Congrats on Delivery Letter';
	DECLARE @v_letter_delete_yn nvarchar(50) = 'N';
	DECLARE @v_letter_flag nvarchar(50) = 'B';
	DECLARE @v_letter_date datetime = getUTCDate();
	DECLARE @v_letter_member_id bigint;
	DECLARE @v_member_case_letter_id bigint;

	DECLARE @v_mvd_id varchar(20);
	DECLARE @v_case_owner varchar(max);
	DECLARE @v_mmf_id bigint;
	DECLARE @v_mmf_form_date datetime;
	DECLARE @v_case_id varchar(100);
	DECLARE @v_mef_id bigint;
	DECLARE @v_mef_form_date datetime;
	DECLARE @v_cf_id bigint;
	DECLARE @v_due_date datetime;
	DECLARE @v_gestation bigint;
	DECLARE @v_member_id nvarchar(50);
	DECLARE @v_member_name nvarchar(max);
	DECLARE @v_other_language nvarchar(255);
	DECLARE @v_line_of_business nvarchar(255);
	DECLARE @v_group nvarchar(255);
	DECLARE @v_cm_org_region nvarchar(255);
	DECLARE @v_branding_name nvarchar(255);
	DECLARE @v_company_name nvarchar(255);
	DECLARE @v_member_type nvarchar(50);
	DECLARE @v_date_of_birth date;

	DECLARE @v_address1 nvarchar(255);
	DECLARE @v_address2 nvarchar(255);
	DECLARE @v_city nvarchar(255);
	DECLARE @v_state nvarchar(2);
	DECLARE @v_postal_code nvarchar(50);
	DECLARE @v_home_phone nvarchar(50);
	DECLARE @v_cell_phone nvarchar(50);
	DECLARE @v_work_phone nvarchar(50);
	DECLARE @v_fax nvarchar(50);
	DECLARE @v_email nvarchar(50);
	DECLARE @v_language nvarchar(50);

	DECLARE @v_note_type_id bigint = 271;

-- Get the candidate list of letters
	DECLARE letter_cursor
	CURSOR FOR
	SELECT DISTINCT
	mef.MVDID,
	mef.CFID,
	mef.CaseOwner,
	fm.MemberID,
	CONCAT( fm.MemberLastName, ', ', fm.MemberFirstName ) MemberName,
	fm.LOB,
	fm.CMOrgRegion,
	fm.BrandingName,
	c.Company_Name CompanyName,
	CASE
	WHEN fm.CMOrgRegion = 'WALMART' THEN 'Care'
	ELSE 'Case'
	END MemberType,
	fm.DateOfBirth,
	fm.OtherLanguage
	FROM
	(
		SELECT DISTINCT
		cf.MVDID,
		ISNULL( mmf.q1CaseOwner, cf.FormAuthor ) CaseOwner,
		mmf.ID MMFID,
		mmf.FormDate MMFFormDate,
		cf.CaseID,
		mef.ID MEFID,
		mef.FormDate MEFFormDate,
		cf.ID CFID,
		cf.FormDate CFFormDate,
		CASE
		WHEN mef.q2BabyDue = '1900-01-01' THEN NULL
		ELSE mef.q2BabyDue
		END DueDate,
		dbo.Get_NumberOfDaysFromWD( mef.q3MemberGestation ) gestationAtEnrollmentDays
		FROM
		ARBCBS_Contact_Form cf
		INNER JOIN HPAlertNote hpan_cf
		ON hpan_cf.LinkedFormType = 'ARBCBS_Contact'
		AND hpan_cf.LinkedFormID = cf.ID
		AND ISNULL( hpan_cf.IsDelete, 0 ) != 1
		LEFT OUTER JOIN
		(
			SELECT
			amef.*
			FROM
			ABCBS_MaternityEnrollment_Form amef 
			INNER JOIN HPAlertNote hpan_amef 
			ON hpan_amef.LinkedFormType = 'ABCBS_MaternityEnrollment'
			AND hpan_amef.LinkedFormID = amef.ID
			AND ISNULL( hpan_amef.IsDelete, 0 ) != 1
		)mef
		ON mef.MVDID = cf.MVDID
		LEFT OUTER JOIN
		(
			SELECT
			ammf.*
			FROM
			ABCBS_MemberManagement_Form ammf (READUNCOMMITTED)
			INNER JOIN HPAlertNote hpan_ammf 
			ON hpan_ammf.LinkedFormType = 'ABCBS_MemberManagement'
			AND hpan_ammf.LinkedFormID = ammf.ID
			AND ISNULL( hpan_ammf.IsDelete, 0 ) != 1
		) mmf
		ON mmf.MVDID = cf.MVDID
		AND mmf.CaseProgram = 'Maternity'
		--AND dbo.MVDIsNull( mmf.CaseID ) = 0
		AND CASE
			WHEN mmf.CaseID IS NULL THEN 1
			WHEN mmf.CaseID = '' THEN 1
			WHEN mmf.CaseID = 'NULL' THEN 1
			ELSE 0
			END = 0
		AND ISNULL( mmf.qCloseCase, 'No' ) != 'Yes'
		LEFT OUTER JOIN LetterTemplate lt
		ON lt.LetterName = @v_letter_name
		LEFT OUTER JOIN LetterMembers lm
		ON lm.LetterType = lt.LetterType
		AND lm.MVDID = cf.MVDID
		AND lm.LetterDelete = 'N'
		AND lm.Processed = 'N'
		WHERE
-- Trigger criteria: Contact Form/Maternity/Mom section: “Member needs” question = Congrats On Delivery Letter
		cf.qMemberMailing LIKE @v_member_mailing
		AND lm.ID IS NULL
	) mef
	INNER JOIN FinalMemberEtl fm
	ON fm.MVDID = mef.MVDID
	LEFT OUTER JOIN LookupCompanyName c
	ON c.Company_Key = CAST( fm.CompanyKey AS varchar(50) )
	ORDER BY
	mef.MVDID;

	OPEN letter_cursor;
	-- Get the first record
	FETCH NEXT FROM letter_cursor INTO
		@v_mvd_id,
		@v_cf_id,
		@v_case_owner,
		@v_member_id,
		@v_member_name,
		@v_line_of_business,
		@v_cm_org_region,
		@v_branding_name,
		@v_company_name,
		@v_member_type,
		@v_date_of_birth,
		@v_other_language;

	-- Iterate through the list
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @v_member_case_letter_id = NULL;
		SET @v_letter_member_id = NULL;

		EXEC Get_MemberPreferredAddress
			@p_MVDID = @v_mvd_id,
			@p_Address1 = @v_address1 OUTPUT,
			@p_Address2 = @v_address2 OUTPUT,
			@p_City = @v_city OUTPUT,
			@p_State = @v_state OUTPUT,
			@p_PostalCode = @v_postal_code OUTPUT,
			@p_HomePhone = @v_home_phone OUTPUT,
			@p_CellPhone = @v_cell_phone OUTPUT,
			@p_WorkPhone = @v_work_phone OUTPUT,
			@p_FAX = @v_fax OUTPUT,
			@p_Email = @v_email OUTPUT,
			@p_Language = @v_language OUTPUT;

			SET @v_language =
				CASE
				WHEN @v_language = 'Spanish' THEN @v_language
				ELSE 'English'
				END;

-- Check to see if letter has already been sent
			EXEC Get_ABCBS_MemberContactLetter
				@p_MVDID = @v_mvd_id,
				@p_LetterName = @v_letter_name,
				@p_ID = @v_member_case_letter_id OUTPUT,
				@p_LetterMemberID = @v_letter_member_id OUTPUT,
				@p_ContactFormID = @v_cf_id OUTPUT;

-- If letter has already been sent, don't send it again
			IF ( @v_member_case_letter_id IS NULL )
			BEGIN
-- Send the letter
				SET @v_user_name = @v_case_owner;

				EXEC uspABCBSMergeLetterMembers
					@UserName = @v_user_name,
					@MVDID = @v_mvd_id,
					@MemberID = @v_member_id,
					@MemberLOB = @v_line_of_business,
					@MemberGroup = NULL,
					@MemberCMOrgReg = @v_cm_org_region,
					@MemberBrandingName = @v_branding_name,
					@CompanyName = @v_company_name,
					@MemberType = @v_member_type,
					@MemberName =@v_member_name,
					@MemberDOB = @v_date_of_birth,
					@MemberAddress1 = @v_address1,
					@MemberAddress2 = @v_address2,
					@MemberCity =@v_city,
					@MemberState = @v_state,
					@MemberZip = @v_postal_code,
					@LetterName = @v_letter_name,
					@LetterDate = @v_letter_date,
					@LetterLanguage = @v_language,
					@LetterDelete = @v_letter_delete_yn,
					@CareManagerName = @v_case_owner,
					@CareManagerCredentials = NULL,
					@CareManagerExtension = NULL,
					@LetterFlag = @v_letter_flag,
					@ID = @v_letter_member_id OUTPUT;

				EXEC uspABCBSUpdateLetterMembers
					@ID = @v_letter_member_id,
					@LetterDelete = @v_letter_delete_yn,
					@LetterFlag = @v_letter_flag;

-- Record that the letter was sent
				EXEC Set_ABCBS_MemberContactLetter
					@p_ID = @v_member_case_letter_id OUTPUT,
					@p_LetterMemberID = @v_letter_member_id,
					@p_ContactFormID = @v_cf_id;

				INSERT INTO
				HPAlertNote
				(
					Note,
					AlertStatusID,
					DateCreated,
					CreatedBy,
					DateModified,
					ModifiedBy,
					MVDID,
					CreatedByType,
					ModifiedByType,
					Active,
					SendToHP,
					SendToPCP,
					SendToNurture,
					SendToNone,
					LinkedFormType,
					LinkedFormID,
					NoteTypeID,
					CaseID,
					IsDelete
				)
				VALUES
				(
					CONCAT( REPLACE( @v_letter_name, ' Letter', '' ), ' Letter Saved.' ),
					0,
					getDate(),
					@v_user_name,
					getDate(),
					@v_user_name,
					@v_mvd_id,
					'HP',
					'HP',
					1,
					0,
					0,
					0,
					0,
					NULL,
					@v_letter_member_id,
					@v_note_type_id,
					NULL,
					0
				);
			END;

		-- Get the next record
		FETCH NEXT FROM letter_cursor INTO
			@v_mvd_id,
			@v_cf_id,
			@v_case_owner,
			@v_member_id,
			@v_member_name,
			@v_line_of_business,
			@v_cm_org_region,
			@v_branding_name,
			@v_company_name,
			@v_member_type,
			@v_date_of_birth,
			@v_other_language;
	END;

	CLOSE letter_cursor;
	DEALLOCATE letter_cursor;

END;