/****** Object:  Procedure [dbo].[Set_PacketMembers]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE Set_PacketMembers
(
	@p_MVDID nvarchar(255),
	@p_FileName nvarchar(255),
	@p_FileTransferLocation nvarchar(255),
	@p_Weight float = 5,
	@p_PackageType nvarchar(50) = 'Package',
	@p_Service nvarchar(50) = 'Ground',
	@p_BillTo nvarchar(50) = 'Prepaid',
	@p_Country nvarchar(255) = 'United States',
	@p_Resind nvarchar(50) = 'Y',
	@p_Ref1 nvarchar(255) = '0187-0045',
	@p_CustomerId int = NULL,
	@p_ProductId int = NULL
)
AS
BEGIN
	DECLARE @v_today datetime = getUTCDate();

	DECLARE @v_member_id nvarchar(255);
	DECLARE @v_member_name nvarchar(max);
	DECLARE @v_other_language nvarchar(255);
	DECLARE @v_eligible_dental_benefit nvarchar(50);

	DECLARE @v_tobacco_user nvarchar(50);

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

	SELECT DISTINCT
	@v_member_id = fm.MemberID,
	@v_member_name = CONCAT( fm.MemberLastName, ', ', fm.MemberFirstName ),
	@v_other_language = fm.OtherLanguage,
	@v_eligible_dental_benefit = FIRST_VALUE( fe.EligibleDentalBenefit ) OVER ( PARTITION BY fe.MVDID ORDER BY fe.ClientLoadDt DESC )
	FROM
	FinalMemberETL fm
	LEFT OUTER JOIN FinalEligibilityETL fe
	ON fe.MVDID = fm.MVDID
	AND ISNULL( fe.MemberEffectiveDate, @v_today ) <= @v_today
	AND ISNULL( fe.MemberTerminationDate, DATEADD( DAY, 1, @v_today ) ) >= @v_today
	WHERE
	fm.MVDID = @p_MVDID;

	IF ( @p_CustomerID = 16 )
	BEGIN
		SELECT
		@v_tobacco_user = MAX( q37Tobacco )
		FROM
		ABCBS_MaternityEnrollment_Form
		WHERE
		MVDID = @p_MVDID;
	END;

	EXEC Get_MemberPreferredAddress
		@p_MVDID = @p_MVDID,
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

	INSERT INTO
	PacketMembers
	(
		FileName,
		FileTransferLocation,
		CreatedDate,
		MemberID,
		Name,
		Email,
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
		EligibleDentalBenefit,
		TobaccoUser
	)
	VALUES
	(
		@p_FileName,
		@p_FileTransferLocation,
		@v_today,
		@v_member_id,
		@v_member_name,
		@v_email,
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
		@p_Weight,
		@p_PackageType,
		@p_Service,
		@p_BillTo,
		@p_Country,
		@p_Resind,
		@p_Ref1,
		@v_language,
		@v_other_language,
		@v_eligible_dental_benefit,
		@v_tobacco_user
	);

END;