/****** Object:  Procedure [dbo].[uspPrepareMaternityFEPRewardBoxLetters]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE
[dbo].[uspPrepareMaternityFEPRewardBoxLetters]
(
	@p_CustomerId int = NULL,
	@p_ProductId int = NULL
)
AS
/*
11/11/2020			Sunil Nokku				TFS 3857
1/11/2021		SunilNokku		Readuncommitted on MMF
*/
BEGIN
	SET NOCOUNT ON;

	DECLARE @v_procedure_name nvarchar(255) = 'uspPrepareMaternityFEPRewardBoxLetters';
	DECLARE @v_birth_threshold_weeks int = 2;
	DECLARE @v_birth_threshold_days int = @v_birth_threshold_weeks * 7;

	DECLARE @v_user_name nvarchar(255);
	DECLARE @v_letter_name nvarchar(255) = 'Maternity FEP Reward Box Letter';
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
	DECLARE @v_member_firstname nvarchar(max);
	DECLARE @v_member_lastname nvarchar(max);
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

-- Get the candidate list of packets
	DECLARE letter_cursor
	CURSOR FOR
	SELECT DISTINCT
	mef.MVDID,
	NULL CFID,
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
		SELECT
		mef.MVDID,
		mmf.q1CaseOwner CaseOwner,
		mmf.ID MMFID,
		mmf.FormDate MMFFormDate,
		mmf.CaseID,
		mef.ID MEFID,
		mef.FormDate MEFFormDate,
		CASE
		WHEN mef.q2BabyDue = '1900-01-01' THEN NULL
		ELSE mef.q2BabyDue
		END DueDate,
		dbo.Get_NumberOfDaysFromWD( mef.q3MemberGestation ) gestationAtEnrollmentDays
		FROM
-- Trigger criteria: Maternity Enrollment Assmt: completed/saved
		ABCBS_MaternityEnrollment_Form mef
		INNER JOIN HPAlertNote hpan_mef
		ON hpan_mef.LinkedFormType = 'ABCBS_MaternityEnrollment'
		AND hpan_mef.LinkedFormID = mef.ID
		AND ISNULL( hpan_mef.IsDelete, 0 ) != 1
		INNER JOIN
		(
			--SELECT
			--ammf.*
			--FROM
			--ABCBS_MemberManagement_Form ammf
			--INNER JOIN HPAlertNote hpan_ammf
			--ON hpan_ammf.LinkedFormType = 'ABCBS_MemberManagement'
			--AND hpan_ammf.LinkedFormID = ammf.ID
			--AND ISNULL( hpan_ammf.IsDelete, 0 ) != 1

			
			SELECT
			FIRST_VALUE( ammf.MVDID ) OVER ( PARTITION BY ammf.OriginalFormID ORDER BY CAST(ammf.SectionCompleted AS INT) DESC, ammf.ID DESC ) MVDID,
			FIRST_VALUE( ammf.q1CaseOwner ) OVER ( PARTITION BY ammf.OriginalFormID ORDER BY CAST(ammf.SectionCompleted AS INT) DESC, ammf.ID DESC ) q1CaseOwner,
			FIRST_VALUE( ammf.ID ) OVER ( PARTITION BY ammf.OriginalFormID ORDER BY CAST(ammf.SectionCompleted AS INT) DESC, ammf.ID DESC ) ID,
			FIRST_VALUE( ammf.FormDate ) OVER ( PARTITION BY ammf.OriginalFormID ORDER BY CAST(ammf.SectionCompleted AS INT) DESC, ammf.ID DESC ) FormDate,
			FIRST_VALUE( ammf.CaseID ) OVER ( PARTITION BY ammf.OriginalFormID ORDER BY CAST(ammf.SectionCompleted AS INT) DESC, ammf.ID DESC ) CaseID,
			FIRST_VALUE( ammf.CaseProgram ) OVER ( PARTITION BY ammf.OriginalFormID ORDER BY CAST(ammf.SectionCompleted AS INT) DESC, ammf.ID DESC ) CaseProgram,
			FIRST_VALUE( ammf.qCloseCase ) OVER ( PARTITION BY ammf.OriginalFormID ORDER BY CAST(ammf.SectionCompleted AS INT) DESC, ammf.ID DESC ) qCloseCase
			FROM
			ABCBS_MMFHistory_Form ammf (READUNCOMMITTED)
			INNER JOIN HPAlertNote hpan_ammf
			ON hpan_ammf.LinkedFormType = 'ABCBS_MMFHistory'
			AND hpan_ammf.LinkedFormID = ammf.ID
			AND ISNULL( hpan_ammf.IsDelete, 0 ) != 1
		) mmf
		ON mmf.MVDID = mef.MVDID
-- Trigger criteria: MMF/Case Program:  Maternity
		AND mmf.CaseProgram = 'Maternity'
-- Trigger criteria: Case is open
		AND dbo.MVDIsNull( mmf.CaseID ) = 0
		AND ISNULL( mmf.qCloseCase, 'No' ) != 'Yes'
	) mef
	INNER JOIN FinalMemberEtl fm
	ON fm.MVDID = mef.MVDID
-- Trigger criteria: CM_ORG_REGION = FEP
	AND fm.CMOrgRegion = 'FEP'
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

-- No Spanish version of this letter in Affinite.
			SET @v_language = 'English';

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

			SELECT 
			@v_member_firstname = MemberFirstName, 
			@v_member_lastname = MemberLastName
			FROM FinalMember
			WHERE MVDID = @v_mvd_id
								
			IF ( ISNULL(@v_member_firstname, '') = ''
					 OR ISNULL(@v_member_lastname, '') = ''
					 OR ISNULL(@v_city, '') = ''
					 OR ISNULL(@v_state, '') = ''
					 OR ISNULL(@v_postal_code, '') = ''
					 OR (ISNULL(@v_address1,'')='' AND ISNULL(@v_address2,'')='')
				) 
			BEGIN
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
					CONCAT( REPLACE( @v_letter_name, ' Letter', '' ), ' Invalid Address Letter Not Saved.' ),
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
				)
			END
			ELSE
			BEGIN
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
				)
			END
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