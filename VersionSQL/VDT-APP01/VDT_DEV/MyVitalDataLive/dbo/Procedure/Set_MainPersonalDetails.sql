/****** Object:  Procedure [dbo].[Set_MainPersonalDetails]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[Set_MainPersonalDetails]

	@ICENUMBER varchar(15),
	@LastName varchar(50),
	@FirstName varchar(50),
	@MiddleName varchar(50) = NULL,
	@SSN varchar(9),
	@GenderId int,
	@DOB smalldatetime,
	@Address1 varchar(50),
	@Address2 varchar(50),
	@City varchar(50),
	@State varchar(2),
	@PostalCode varchar(5),
	@HomePhone varchar(10),
	@CellPhone varchar(10),
	@WorkPhone varchar(10),
	@FaxPhone varchar(10),
	@BloodTypeId int,
	@OrganDonor varchar(3),
	@HeightInches int,
	@WeightLbs int,
	@MaritalStatusId int,
	@EconomicStatusId int,
	@Occupation varchar(50),
	@Hours varchar(50),
	@Email varchar(50),
	@ModifyDate datetime = NULL,
	@UpdatedBy nvarchar(250) = NULL,
	@UpdatedByContact nvarchar(256) = NULL,
	@Organization nvarchar(64) = NULL

AS

	SET NOCOUNT ON

	UPDATE	MainPersonalDetails
	SET		FirstName = @FirstName,
			MiddleName = @MiddleName,
			LastName = @LastName,
			SSN = @SSN,
			GenderId = @GenderId,
			DOB = @DOB,
			Address1 = @Address1,
			Address2 = @Address2,
			City = @City,
			State = @State,
			PostalCode = @PostalCode,
			HomePhone = @HomePhone,
			CellPhone = @CellPhone,
			WorkPhone = @WorkPhone,
			FaxPhone = @FaxPhone,
			Email = @Email,
			BloodTypeId = @BloodTypeId,
			OrganDonor = @OrganDonor,
			HeightInches = @HeightInches,
			WeightLbs = @WeightLbs,
			MaritalStatusId = @MaritalStatusId,
			EconomicStatusId = @EconomicStatusId,
			Occupation = @Occupation,
			Hours = @Hours,
			ModifyDate = ISNULL(@ModifyDate, GETUTCDATE()),
			UpdatedBy =@UpdatedBy,
			UpdatedByContact = @UpdatedByContact,
			UpdatedByOrganization=@Organization
	WHERE	ICENUMBER = @ICENUMBER


	--- Update email for non-main account

--	DECLARE @MainAccount bit

--

--	SELECT	@MainAccount = MainAccount 
--	FROM	MainICENUMBERGroups
--	WHERE	ICENUMBER = @ICENUMBER
--
--	IF @MainAccount = 0
--		UPDATE	MainPersonalDetails
--		SET		Email = @Email
--		WHERE	ICENUMBER = @ICENUMBER