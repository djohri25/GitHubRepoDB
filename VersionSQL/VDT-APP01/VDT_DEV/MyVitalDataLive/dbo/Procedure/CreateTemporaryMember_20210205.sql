/****** Object:  Procedure [dbo].[CreateTemporaryMember_20210205]    Committed by VersionSQL https://www.versionsql.com ******/

/*
Changes
WHO		WHEN		WHAT
Deepank 2020-12-17  TFS4056-Updated logic to identify subgroupid along with groupid
Mike	2020-01-27	Prod issue 242. SP is ahead of deployed code. Adding parameters as interim fix to PROD deployment
*/
CREATE PROCEDURE
[dbo].[CreateTemporaryMember_20210205]
(
	@MemberID varchar(30),
-- If @MVDID is supplied, then the temp member should be updated; otherwise, attempt to create a new temp member
	@MVDID varchar(30) = NULL,
	@LastName varchar(50),
	@FirstName varchar(50),
	@Gender varchar(1),
	@DOB date,
	@Address1 varchar(128),
	@Address2 varchar(128),
	@City varchar(50),
	@State varchar(2),
	@Postal varchar(5),
	@HomePhone varchar(20),
	@Email varchar(100),
	@Ethnicity varchar(50),
	@LOB varchar(255) = NULL,
	@CMOrgRegion varchar(255) = NULL,
	@BrandingName varchar(255) = NULL,
	@GroupID varchar(255) = NULL,
	@GroupKey varchar(255) = NULL,
	@GroupName varchar(255) = NULL,
	@SubGroupID varchar(255) = NULL,
	@SubGroupKey varchar(255) = NULL,
	@SubGroupName varchar(255) = NULL,
	@CompanyID varchar(255) = NULL,
	@CompanyKey varchar(255) = NULL,
	@CompanyName varchar(255) = NULL,
	@AssociatedMemberID varchar(15) = NULL,
	@UserName varchar(255) = NULL,
	@EffStartDate date, 
	@EffEndDate date,
	--@HealthPlanEmployeeFlag varchar(1),
	@CustID int,
	@ReturnValue1 int output,
	@ReturnValue2 varchar(30) output
)
AS
BEGIN
	SET NOCOUNT ON;
-- Exec CreateTemporaryMember 'Jamies', 'Jonny', 'F','1965-06-28', '111 Peckham St', '','Dallas', 'TX', '75001','','','',null,'2019-02-01',NULL,16, null, null

	DECLARE @GroupKey1 int;
	DECLARE @SubGroupKey1 int;
	DECLARE @CompanyKey1 int;

-- Create MemberID/MVDID
	DECLARE @v_record_id bigint;
	DECLARE @v_exists_yn bit = 0;
	DECLARE @v_update_yn bit = 1;

	select @HomePhone = left(replace(replace(replace(@HomePhone,'(',''),')',''),'-',''),10) -- strip out punctuation and limit to 10 characters


-- Lookup Group Key / Name
	IF ( @GroupID IS NOT NULL )
	BEGIN
		SELECT
		@GroupKey1 = grp_key
		FROM
		LookupGroup
		WHERE
		grp_id = @GroupID;
	END;
	ELSE
	BEGIN
		SELECT
		@GroupKey1 = grp_key
		FROM
		LookupGroup
		WHERE
		grp_name = @GroupName;
	END;

-- Lookup SubGroup Key / Name
	IF ( @SubGroupID IS NOT NULL )
	BEGIN
		SELECT
		@SubGroupKey1 = sub_grp_key
		FROM
		LookupSubGroup
		WHERE
		sub_grp_id = @SubGroupID
        AND grp_id = @GroupID;
	END;
	ELSE
	BEGIN
		SELECT
		@SubGroupKey1 = sub_grp_key
		FROM
		LookupSubGroup
		WHERE
		sub_grp_name = @SubGroupName
	END;

-- Lookup Company Key / Name
	IF ( @CompanyID IS NOT NULL )
	BEGIN
		SELECT
		@CompanyKey1 = company_key
		FROM
		LookupCompanyName
		WHERE
		common_emp_id = @CompanyID;
	END;
	ELSE
	BEGIN
		SELECT
		@CompanyKey1 = company_key
		FROM
		LookupCompanyName
		WHERE
		company_name = @CompanyName;
	END;

	IF ( ISNULL( @MVDID, '' ) = '' )
	BEGIN
		SET @MVDID = RTRIM( LEFT( CAST( @CustID AS varchar(2) ) + SUBSTRING( CONVERT( varchar(40), NEWID() ), 0, 5 ), 15 ) ) + 'TMP';
		SET @v_update_yn = 0;
	END;

	IF ( ISNULL( @MemberID, '' ) = '' )
	BEGIN
		SET  @MemberID = 'TMP' + REPLACE( @MVDID, 'TMP', '' );
	END;

	IF ( @v_update_yn = 1 )
-- If @MVDID is supplied, then the temp member should be updated
	BEGIN
		SET @v_record_id = -1;

		SELECT
		@v_record_id = RecordID
		FROM
		FinalMemberTemporary
		WHERE
		MVDID = @MVDID;

		IF ( @v_record_id != -1 )
		BEGIN
			UPDATE
			FinalMemberTemporary
			SET
			MemberLastName = @LastName,
			MemberFirstName = @FirstName,
			Gender = @Gender,
			DateOfBirth = @DOB,
			Address1 = LEFT( @Address1, 100 ),
			Address2 = LEFT( @Address2, 50 ),
			City = @City,
			State = @State,
			Zipcode = @Postal,
			HomePhone = @HomePhone,
			Email = @Email,
			Ethnicity = LEFT( @Ethnicity, 2 ),
			LOB = @LOB,
			CMOrgRegion = @CMOrgRegion,
			BrandingName = @BrandingName,
			PlanGroup = @GroupKey1,
			SubgroupKey = @SubGroupKey1,
			CompanyKey = @CompanyKey1,
			AssociatedMemberID = @AssociatedMemberID,
			LastModifiedBy = @UserName,
			LastModifiedDate = getDate()
			WHERE
			MVDID = @MVDID;

			UPDATE
			FinalEligibilityTemporary
			SET
			MemberEffectiveDate = @EffStartDate,
			MemberTerminationDate = @EffEndDate,
			MemberLastName = @LastName,
			MemberFirstName = @FirstName,
			LOB = @LOB,
			PlanGroup = @GroupKey1,
			SubgroupKey = @SubGroupKey1,
			CompanyKey = @CompanyKey1
			WHERE
			MVDID = @MVDID;
		END;
	END
	ELSE
	BEGIN
-- Check to see if there is already a record in FinalMemberTemporary with the same MemberID
		SELECT
		@v_exists_yn = 1
		FROM
		FinalMemberTemporary
		WHERE
		MemberID = @MemberID;

		IF ( @v_exists_yn = 0 )
-- If there is not already a record in FinalMemberTemporary with the same MemberID, then create one
		BEGIN
-- Insert Link
			INSERT INTO
			Link_LegacyMemberId_MVD_Ins
			(
				MVDID,
				InsMemberId,
				Cust_ID,
				Created,
				Active
			)
			VALUES
			(
				@MVDID,
				@MemberID,
				@CustID,
				GetDate(),
				1
			);

-- Insert Member Info
			INSERT INTO
			FinalMemberTemporary
			(
				MVDID,
				MemberID,
				MemberLastName,
				MemberFirstName,
				Gender,
				DateOfBirth,
				Address1,
				Address2,
				City,
				State,
				Zipcode,
				HomePhone,
				Email,
				Ethnicity,
				CustID,
				BaseBatchID,
				CurrentBatchID,
				HealthPlanEmployeeFlag,
				LOB,
				CMOrgRegion,
				BrandingName,
				PlanGroup,
				SubGroupKey,
				CompanyKey,
				AssociatedMemberID,
				CreatedBy,
				CreatedDate,
				LastModifiedBy,
				LastModifiedDate
			)
			VALUES
			(
				@MVDID,
				@MemberID,
				@LastName,
				@FirstName,
				@Gender,
				@DOB,
				LEFT( @Address1, 100 ),
				LEFT( @Address2, 50 ),
				@City,
				@State,
				@Postal,
				@HomePhone,
				@Email,
				LEFT( @Ethnicity, 2 ),
				@CustID,
				0,
				0,
				0,
				@LOB,
				@CMOrgRegion,
				@BrandingName,
				@GroupKey1,
				@SubGroupKey1,
				@CompanyKey1,
				@AssociatedMemberID,
				@UserName,
				getDate(),
				@UserName,
				getDate()
			);
	
			SELECT
			@v_record_id = RecordID
			FROM
			FinalMemberTemporary
			WHERE
			MVDID = @MVDID;

-- Insert Insurance Info
			INSERT INTO
			FinalEligibilityTemporary
			(
				MVDID,
				MemberID,
				MemberLastName,
				MemberFirstName,
				MemberEffectiveDate,
				MemberTerminationDate,
				CustID,
				LOB,
				PlanGroup,
				SubGroupKey,
				CompanyKey,
				BaseBatchID,
				CurrentBatchID
			)
			VALUES
			(
				@MVDID,
				LEFT( @MemberID, 15 ),
				@LastName,
				@FirstName,
				@EffStartDate,
				@EffEndDate,
				@CustID,
				@LOB,
				@GroupKey1,
				@SubGroupKey1,
				@CompanyKey1,
				0,
				0
			);
		END
		ELSE
-- If there is already a record in FinalMemberTemporaray with the same MemberID, notify calling program
		BEGIN
			SET @v_record_id = -1;
			SET @MVDID = '-1';
		END;
	END;

	SET @ReturnValue1 = @v_record_id
	SET @ReturnValue2 = @MVDID
END;