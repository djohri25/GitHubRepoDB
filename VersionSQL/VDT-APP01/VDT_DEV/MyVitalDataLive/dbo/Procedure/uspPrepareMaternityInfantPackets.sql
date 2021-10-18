/****** Object:  Procedure [dbo].[uspPrepareMaternityInfantPackets]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE
[dbo].[uspPrepareMaternityInfantPackets]
(
	@p_CMOrgRegion nvarchar(255) = NULL,
	@p_CustomerId int = NULL,
	@p_ProductId int = NULL,
	@p_PrintOnlyYN bit = 0
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @v_procedure_name nvarchar(255) = 'uspPrepareMaternityInfantPackets';

	DECLARE @v_gestation_threshold_weeks int = 36;
	DECLARE @v_gestation_threshold_days int = @v_gestation_threshold_weeks * 7;

	DECLARE @v_current_gestation_threshold_weeks int = 33;
	DECLARE @v_current_gestation_threshold_days int = @v_current_gestation_threshold_weeks * 7;

	DECLARE @v_member_packet_id bigint;

	DECLARE @v_mvd_id varchar(20);
	DECLARE @v_case_owner varchar(max);
	DECLARE @v_mmf_id bigint;
	DECLARE @v_mmf_form_date datetime;
	DECLARE @v_case_id varchar(100);
	DECLARE @v_mef_id bigint;
	DECLARE @v_mef_form_date datetime;
	DECLARE @v_due_date datetime;
	DECLARE @v_gestation bigint;
	DECLARE @v_member_id nvarchar(50);
	DECLARE @v_member_name nvarchar(max);
	DECLARE @v_other_language nvarchar(255);
	DECLARE @v_file_name nvarchar(255);
	DECLARE @v_tobacco_user_yn nvarchar(50);

	DECLARE @v_file_transfer_location nvarchar(255) = '\\lrd1fil4\hcis\FTP\VitalData\MaternityPackets';
	DECLARE @v_short_code_vartext nvarchar(255) = '[short code]';
	DECLARE @v_file_name_template nvarchar(255) =
		CONCAT( 'Packets_', @v_short_code_vartext, '_INFANT_ccyymmdd_ccyymmdd.xlsx' );
	DECLARE @v_weight float = 5;
	DECLARE @v_package_type nvarchar(50) = 'Package';
	DECLARE @v_service nvarchar(50) = 'Ground';
	DECLARE @v_bill_to nvarchar(50) = 'Prepaid';
	DECLARE @v_country nvarchar(255) = 'United States';
	DECLARE @v_resind nvarchar(50) = 'Y';
	DECLARE @v_ref1 nvarchar(255) = '0187-0045';

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

	DECLARE @v_packet_name nvarchar(255) = 'Infant Packet';
	DECLARE @v_user_name nvarchar(255) = 'executive1';
	DECLARE @v_note_type_id bigint = 172;

	DROP TABLE IF EXISTS #ResultSet;

	CREATE TABLE #ResultSet
	(
		MemberID nvarchar(50),
		Name nvarchar(max),
		Email nvarchar(255),
		Address nvarchar(max),
		City nvarchar(255),
		State nvarchar(255),
		Zip nvarchar(50),
		Weight float,
		PkgType nvarchar(50),
		Service nvarchar(50),
		Billto nvarchar(50),
		Country nvarchar(255),
		Resind nvarchar(50),
		Ref1 nvarchar(50),
		PrimaryLanguage nvarchar(255),
		PrimaryLanguageOther nvarchar(255),
		EligibleDentalBenefit nvarchar(1),
		TobaccoUser nvarchar(10)
	);

-- Get the candidate list of packets
	DECLARE packet_cursor
	CURSOR FOR
	SELECT DISTINCT
	mef.MVDID,
	mef.MMFID,
	fm.MemberID,
	CONCAT( fm.MemberLastName, ', ', fm.MemberFirstName ) MemberName,
	fm.OtherLanguage,
	REPLACE
	(
		@v_file_name_template,
		@v_short_code_vartext,
		CASE
		WHEN @p_CMOrgRegion = 'TYSON' THEN 'HT'
		WHEN @p_CMOrgRegion = 'WALMART' THEN 'LWB'
		ELSE 'SD'
		END
	) FileName,
/*
There should be a column on this mail file to indicate if the member is a smoker/tobacco user. A Yes/No indicator.
See question on Enrollment Assmt:  "Do you use any tobacco or nicotine products such as cigarettes or electronic
nicotine delivery systems?" If yes, indicate this in the mail file.
*/
	mef.q37Tobacco tobacco_user_yn
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
		dbo.Get_NumberOfDaysFromWD( mef.q3MemberGestation ) gestationAtEnrollmentDays,
		CASE
		WHEN mef.q37Tobacco = 'Yes' THEN 'Yes'
		WHEN mef.q37Tobacco = 'No' THEN 'No'
		ELSE NULL
		END q37Tobacco
		FROM
		ABCBS_MaternityEnrollment_Form mef
		INNER JOIN HPAlertNote hpan_mef
		ON hpan_mef.LinkedFormType = 'ABCBS_MaternityEnrollment'
		AND hpan_mef.LinkedFormID = mef.ID
		AND ISNULL( hpan_mef.IsDelete, 0 ) != 1
		LEFT OUTER JOIN
		(
			SELECT
			*
			FROM
			(
				SELECT
				ammf.*,
				RANK() OVER ( PARTITION BY ammf.OriginalFormID ORDER BY ammf.SectionCompleted DESC, ammf.ID DESC ) order_rank
				FROM
				ABCBS_MMFHistory_Form ammf
				INNER JOIN HPAlertNote hpan_ammf
				ON hpan_ammf.LinkedFormType = 'ABCBS_MMFHistory'
				AND hpan_ammf.LinkedFormID = ammf.ID
				AND ISNULL( hpan_ammf.IsDelete, 0 ) != 1
				WHERE
				ammf.CaseProgram = 'Maternity'
				AND dbo.MVDIsNull( ammf.CaseID ) = 0
			) mmfr
			WHERE
			mmfr.order_rank = 1
		) mmf
		ON mmf.MVDID = mef.MVDID
		WHERE
		CASE
-- Trigger criteria: If a user completed the MMF to close a maternity enrollment case, member should no longer be identified on the weekly maternity pregnancy tips file.
		WHEN mmf.ID IS NOT NULL AND ISNULL( mmf.qCloseCase, 'No' ) != 'Yes' THEN 1
		WHEN mmf.ID IS NULL THEN 1
		ELSE 0
		END = 1
		UNION
		SELECT
		*
		FROM
		(
-- Get members requested from the Contact form
			SELECT
			fme.MVDID,
			NULL CaseOwner,
			NULL MMFID,
			NULL MMFFormDate,
			NULL CaseID,
			NULL MEFID,
			NULL MEFFormDate,
			NULL DueDate,
			NULL gestationAtEnrollmentDays,
			NULL q37Tobacco
			FROM
			PacketMembers pm
			INNER JOIN FinalMemberEtl fme
			ON fme.MemberID = pm.MemberID
			WHERE pm.FileName =
			REPLACE
			(
				@v_file_name_template,
				@v_short_code_vartext,
				CASE
				WHEN @p_CMOrgRegion = 'TYSON' THEN 'HT'
				WHEN @p_CMOrgRegion = 'WALMART' THEN 'LWB'
				ELSE 'SD'
				END
			)
			EXCEPT
-- Need to exclude those members picked up by the normal MEF flow
			SELECT
			mef.MVDID,
			NULL CaseOwner,
			NULL MMFID,
			NULL MMFFormDate,
			NULL CaseID,
			NULL MEFID,
			NULL MEFFormDate,
			NULL DueDate,
			NULL gestationAtEnrollmentDays,
			NULL q37Tobacco
			FROM
			ABCBS_MaternityEnrollment_Form mef
			INNER JOIN HPAlertNote hpan_mef
			ON hpan_mef.LinkedFormType = 'ABCBS_MaternityEnrollment'
			AND hpan_mef.LinkedFormID = mef.ID
			AND ISNULL( hpan_mef.IsDelete, 0 ) != 1
			INNER JOIN FinalMemberEtl fme
			ON fme.MVDID = mef.MVDID
			INNER JOIN PacketMembers pm
			ON pm.MemberID = fme.MemberID
			LEFT OUTER JOIN ABCBS_MemberPacket amp
			ON amp.MVDID = mef.MVDID
			WHERE
			CASE
-- This situation should be picked up from the normal MEF flow, so it should be excluded
			WHEN amp.ID IS NULL AND dbo.Get_NumberOfDaysFromWD( mef.q3MemberGestation ) <= @v_gestation_threshold_days
				AND dbo.Get_NumberOfDaysFromWD( mef.q3MemberGestation ) + DATEDIFF( DAY, mef.FormDate, getUTCDate() ) > @v_current_gestation_threshold_days
				THEN 1
-- If the packet was sent after the ad hoc request, it should be excluded
			WHEN amp.ID IS NOT NULL AND ISNULL( amp.CreatedDatetime, DATEADD( DAY, -1, pm.CreatedDate ) ) > pm.CreatedDate THEN 1
			ELSE 0
			END = 1
		) p
	) mef
	INNER JOIN FinalMemberEtl fm
	ON fm.MVDID = mef.MVDID
-- Exception: Exchange members should never be on the infant file.
	AND fm.CmOrgRegion != 'EXCHNG'
	AND
	CASE
	WHEN @p_CMOrgRegion IS NULL AND fm.CmOrgRegion NOT IN ( 'TYSON', 'WALMART' ) THEN 1
	WHEN @p_CMOrgRegion = fm.CmOrgRegion THEN 1
	ELSE 0
	END = 1
-- Check to see if packet has been sent
	LEFT OUTER JOIN ABCBS_MemberPacket mp
	ON mp.MVDID = mef.MVDID
	AND mp.ProcedureName = @v_procedure_name
	AND
	CASE
	WHEN mp.FormID = mef.MMFID THEN 1
	WHEN mef.MMFID IS NULL THEN 1
	END = 1
	WHERE
	CASE
	WHEN
-- Exception: If Gestation at time of enrollment is 36 weeks or greater, do not include on infant file.
		mef.gestationAtEnrollmentDays < @v_gestation_threshold_days
-- Trigger criteria: Member has reached EITHER 34 OR 35 weeks gestation in the last 7 days.
		AND mef.gestationAtEnrollmentDays + DATEDIFF( DAY, mef.MEFFormDate, getUTCDate() ) > @v_current_gestation_threshold_days
		THEN 1
	WHEN mef.MEFID IS NULL THEN 1
	ELSE 0
	END = 1
-- Packet has not been sent
	AND	mp.ID IS NULL
	ORDER BY
	mef.MVDID;

	OPEN packet_cursor;
	-- Get the first record
	FETCH NEXT FROM packet_cursor INTO
		@v_mvd_id,
		@v_mmf_id,
		@v_member_id,
		@v_member_name,
		@v_other_language,
		@v_file_name,
		@v_tobacco_user_yn;

	-- Iterate through the list
	WHILE @@FETCH_STATUS = 0
	BEGIN
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

-- Check to see if packet has already been sent
/*
		EXEC Get_ABCBS_MemberPacket
			@p_MVDID = @v_mvd_id,
			@p_ProcedureName = @v_procedure_name,
			@p_ID = @v_member_packet_id OUTPUT,
			@p_FormID = @v_mmf_id OUTPUT;
*/

-- If packet has already been sent, don't send it again
/*
		IF ( @v_member_packet_id IS NULL )
		BEGIN
*/
-- Send the packet
			INSERT INTO
			#ResultSet
			(
				MemberID,
				Name,
				Address,
				City,
				State,
				Zip,
				Weight,
				PkgType,
				Service,
				Billto,
				Country,
				Resind,
				Ref1,
				PrimaryLanguage,
				PrimaryLanguageOther,
				TobaccoUser
			)
			VALUES
			(
					@v_member_id,
					@v_member_name,
					CASE
					WHEN @v_address1 IS NOT NULL AND @v_address2 IS NOT NULL THEN
						CONCAT( @v_address1, CHAR(13), CHAR(10), @v_address2 )
					WHEN @v_address1 IS NOT NULL THEN @v_address1
					WHEN @v_address2 IS NOT NULL THEN @v_address2
					ELSE NULL
					END,
					@v_city,
					@v_state,
					@v_postal_code,
					@v_weight,
					@v_package_type,
					@v_service,
					@v_bill_to,
					@v_country,
					@v_resind,
					@v_ref1,
					@v_language,
					@v_other_language,
					@v_tobacco_user_yn
			);

			IF ( @p_PrintOnlyYN = 0 )
			BEGIN
-- Record that the packet was sent
				EXEC Set_ABCBS_MemberPacket
					@p_ID = @v_member_packet_id OUTPUT,
					@p_MVDID = @v_mvd_id,
					@p_ProcedureName = @v_procedure_name,
					@p_FormID = @v_mmf_id;

-- Add to chart history
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
					CONCAT( REPLACE( @v_packet_name, ' Packet', '' ), ' Packet Saved.' ),
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
					NULL,
					@v_note_type_id,
					NULL,
					0
				);
			END; -- IF ( @p_PrintOnlyYN = 0 )
/*
		END; -- IF ( @v_member_packet_id IS NULL )
*/

		-- Get the next record
		FETCH NEXT FROM packet_cursor INTO
			@v_mvd_id,
			@v_mmf_id,
			@v_member_id,
			@v_member_name,
			@v_other_language,
			@v_file_name,
			@v_tobacco_user_yn;
	END; -- WHILE @@FETCH_STATUS = 0

	CLOSE packet_cursor;
	DEALLOCATE packet_cursor;

	SELECT DISTINCT
	*
	FROM
	#ResultSet;

END;