/****** Object:  Procedure [dbo].[Upd_ImportedProfile]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		SW
-- Create date: 8/29/2008
-- Description:	Updates MVD account/profile
--		based on data imported FROM external
--		data providers. 
-- Date			Name			Comments			
-- 09/26/2017	PPetluri		Added code to not insert null or blank data into firstname, lastname, middlename
-- =============================================
CREATE PROCEDURE [dbo].[Upd_ImportedProfile]
	@IceNumber varchar(10),
	@LastName varchar(50),
	@FirstName varchar(50),
	@MiddleName nvarchar(50) = NULL,
	@Phone varchar(10),
	@Email varchar(100),
	@Address1 varchar(50),
	@Address2 varchar(50),
	@City varchar(50),
	@State char(2),
	@Zip varchar(5),
	@DOB varchar(35),
	@Gender int,
	@SSN varchar(9),
	@Ethnicity varchar(100) = null,
	@Language	varchar(100) = null,
	@MaritalStatus int,
	@EconomicStatus int,
	@Height int,
	@Weight int,
	@UpdatedBy varchar(250),		-- Only set when Individual updates a record
	@UpdatedByContact varchar(50),	-- Common field for UpdatedBy and Organization
	@Organization varchar(250),
	@InCaseManagement bit = NULL,
	@NarcoticLockdown bit = NULL,
	@System_Memid varchar(30) = NULL,
	@LOB	varchar(10) = NULL,
	@RecordNumber int OUTPUT
AS
BEGIN

	SET NOCOUNT ON

	DECLARE @LOB_ID	INT, @HPCustomerId	INT
	-- Address could be updated by EMS so prevent overwritting new value
	DECLARE @newAddress varchar(250), @curAddress varchar(250), @history varchar(250), @curPhone varchar(10),

			@curAddress1 varchar(50), @curAddress2 varchar(50), @curCity varchar(50), @curState varchar(2), @curZip varchar(5),
			@curSSN varchar(20)

	Select @HPCustomerId = Cust_ID from Link_MemberId_MVD_Ins where MVDID = @IceNumber
	SELECT @newAddress = ISNULL(@address1, '') + ISNULL(' ' + @address2, '') + ISNULL(' ' + @city, '') + ISNULL(' ' + @state, '') + ISNULL(' ' + @Zip, '')

	SELECT	@curAddress = ISNULL(address1, '') + ISNULL(' ' + address2, '') + ISNULL(' ' + city, '') + ISNULL(' ' + state, '') + ISNULL(' ' + postalcode, ''),
			@curAddress1 = ISNULL(address1, ''),
			@curAddress2 = ISNULL(address2, ''),
			@curCity = ISNULL(city, ''),
			@curState = ISNULL(state, ''),
			@curZip = ISNULL(postalcode, ''),
			@curPhone = ISNULL(HomePhone, ''),
			@RecordNumber = RecordNumber,
			@curSSN = ISNULL(SSN, '')
	FROM	MainPersonalDetails
	WHERE	ICENUMBER = @ICENUMBER

	-- Don't overwrite address
	if(ISNULL(@Address1,'') = '')
	begin
		select @Address1 = @curAddress1,
			@Address2 = @curAddress2,
			@City = @curCity,
			@State = @curState,
			@Zip = @curZip			
	end

	-- Set new member ID column (if provided)
	if(ISNULL(@System_Memid,'') <> '')
	begin
		update Link_MemberId_MVD_Ins 
		set System_Memid = @System_Memid
		where MVDId = @IceNumber
	end

	SELECT @history = FieldValue
	FROM dbo.HPFieldValueHistory
	WHERE mvdid = @icenumber AND tableName = 'MainPersonalDetails' AND FieldName = 'Address'

	IF @history IS NOT NULL
	BEGIN
		IF @newAddress <> @history
			DELETE FROM dbo.HPFieldValueHistory
			WHERE mvdid = @icenumber AND tableName = 'MainPersonalDetails' AND FieldName = 'Address'
		ELSE
			SELECT @Address1 = @curAddress1, @Address2 = @curAddress2, @City = @curCity, @State = @curState, @Zip = @curZip
	END

	SELECT @history = FieldValue
	FROM dbo.HPFieldValueHistory
	WHERE mvdid = @icenumber AND tableName = 'MainPersonalDetails' AND FieldName = 'HomePhone'

	if(ISNULL(@Phone,'') <> '')
	begin
		IF @history IS NOT NULL
		BEGIN
			IF @Phone <> @history
				DELETE FROM dbo.HPFieldValueHistory
				WHERE mvdid = @icenumber AND tableName = 'MainPersonalDetails' AND FieldName = 'HomePhone'
			ELSE
				SELECT @Phone = @curPhone
		END
	end
	else
	begin
		SELECT @Phone = @curPhone
	end
	
	if(ISNULL(@ssn,'') = '')
	begin
		set @SSN = @curSSN
	end

	IF (@LOB is not null)
	BEGIN
		Select @LOB_ID = CodeID from Lookup_Generic_Code WHere Cust_ID = @HPCustomerId and Label = @LOB
	END
	
	UPDATE MainPersonalDetails SET 
		FirstName = CASE WHEN ISNULL(@FirstName,'') = '' then FirstName Else @FirstName END,
		MiddleName = CASE WHEN ISNULL(@MiddleName,'')  = ''  then MiddleName ELSE @MiddleName END,
		LastName = CASE WHEN ISNULL(@LastName,'')  = ''  then LastName Else @LastName END,
		HomePhone = @Phone,
		Address1 = @Address1,
		Address2 = @Address2,
		City = @City,
		State = @State,
		PostalCode = @Zip,
		GenderId = @Gender,
		DOB = @DOB,
		SSN = @SSN,
		Email = @Email,
		HeightInches = @Height,
		WeightLbs = @Weight,
		MaritalStatusId = @MaritalStatus,
		EconomicStatusId = @EconomicStatus,
		ModifyDate = GETUTCDATE(),
		UpdatedBy = @UpdatedBy,
		UpdatedByContact = @UpdatedByContact,
		UpdatedByOrganization = @Organization,
		InCaseManagement = @InCaseManagement,
		NarcoticLockdown = @NarcoticLockdown,
		Organization = CAST(@LOB_ID as VARCHAR(10)),
		Ethnicity = @Ethnicity,
		Language = @Language
	WHERE ICENUMBER = @IceNumber
END