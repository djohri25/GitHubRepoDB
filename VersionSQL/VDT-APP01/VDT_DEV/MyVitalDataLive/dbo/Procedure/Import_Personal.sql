/****** Object:  Procedure [dbo].[Import_Personal]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		SW
-- Create date: 2/9/2009
-- Description:	Import Claims personal info of the member.
--		If the record exists, update. Otherwise crete new record, and
--		update necessary relation tables (e.g. groups)
--		Return MVD ID of the updated/inserted record		
-- =============================================
CREATE PROCEDURE [dbo].[Import_Personal]
	@IsPrimary bit,	
	@MemberID varchar(30),
	@InsGroupId  varchar(30),
	@MVDGroupId varchar(15),
	@LastName varchar(35),
	@FirstName varchar(25),
	@MiddleName nvarchar(50) = NULL,
	@DOB varchar(35),
	@Gender char(1),
	@MVDId varchar(15) output,
	@ReportDate varchar(50),
	@UpdatedBy varchar(250),			-- Only set when Individual creates/updates a record
	@UpdatedByContact varchar(50),		-- Common field for UpdatedBy and Organization
	@Organization varchar(250),
	@HPCustomerId int,
	@SourceName varchar(50),
	@SourceRecordID int,
	@HPAssignedRecordID varchar(50),
	@Customer varchar(50) = 'Health Plan of Michigan',
	@Result int output					-- 0 - success, -1 - failure

AS
	SET NOCOUNT ON
	DECLARE
		-- mvd data
		@MVDGender int,
		@ExistingRecordModifDate datetime,
		-- values not provided but retrieved (if exist) from already existing record
		@Address1 varchar(55),
		@Address2 varchar(55),
		@City varchar(30),
		@State char(2),
		@Zip varchar(15),
		@Phone varchar(10),
		@Email varchar(100),
		@SSN varchar(9),
		@MaritalStatus int,
		@EconomicStatus int,
		@Height int,
		@Weight int,		
		-- History
		@MVDUpdatedRecordId int,
		@Action char(1)

	BEGIN TRY

		-- Check if user was already imported
		SELECT @MVDId = MVDId FROM Link_MemberId_MVD_Ins WHERE InsMemberId = @MemberId AND cust_id = @HPCustomerID
		IF @MVDId IS NULL
		BEGIN
			WHILE 1 = 1
			BEGIN
				EXEC GenerateRandomString 1, 0, 1, '23456789ABCDEFGHJKLMNPQRSTWXYZ', 10, @MVDGroupId output
				-- Repeat generating MVD GroupID until it's unique
				IF NOT EXISTS(SELECT TOP 1 ICEGROUP FROM MainICENUMBERGroups WHERE ICEGROUP = @MVDGroupId)
					BREAK
			END
			WHILE 1 = 1
			BEGIN
				EXEC GenerateMVDId @firstName = @FirstName, @lastName = @LastName, @newID = @MVDId OUTPUT
				IF NOT EXISTS(SELECT TOP 1 ICENUMBER FROM MainICENUMBERGroups WHERE ICENUMBER = @MVDId)
					BREAK
			END

			------------------------------- Map data
			-- Gender
			SELECT @MVDGender = MVDGenderId FROM Link_Gender_MVD_Ins WHERE InsGenderId = @Gender	
			---------------------------------------

			-- Create new user profile
			EXEC Set_NewImportedProfile
				@MVDGroup = @MVDGroupId,
				@834_GroupId = '',
				@MVDId = @MVDId,
				@LastName = @LastName,
				@FirstName = @FirstName,
				@MiddleName = @MiddleName,
				@IsPrimary = @isPrimary,
				@Phone = '',
				@Email = '',
				@Address1 = '',
				@Address2 = '',
				@City = '',
				@State = null,
				@Zip = '',
				@DOB = @DOB,
				@Gender = @MVDGender,
				@MaritalStatus = '',
				@EconomicStatus = '',
				@Height = '',
				@Weight = '',
				@InsGroupID = @InsGroupID,
				@InsMemberID = @MemberID,
				@CreatedBy = @UpdatedBy,
				@CreatedByContact = @UpdatedByContact,
				@Organization = @Organization,
				@HPCustomerId = @HPCustomerId,
				@RecordNumber = @MVDUpdatedRecordId OUTPUT,
				@Result = @Result OUTPUT

			SET @Action = 'A'
		END
		ELSE
		BEGIN
			-- Update existing record
			-- Don't update because demographic info updates come on regular basis
			SET @Action = 'I'
			SELECT @Result = 0

/*
			------------------------------- Map data
			-- Gender
			SELECT @MVDGender = MVDGenderId FROM Link_Gender_MVD_Ins WHERE InsGenderId = @Gender	
			---------------------------------------

			-- We don't want to overwrite existing data on the existing record
			-- Claims don't provide that data so retrieve whatever is currently on record
			SELECT 
				@Address1 = Address1,
				@Address2 = Address2,
				@City = City,
				@State = State,
				@Zip = PostalCode,
				@Phone = HomePhone,
				@Email = Email,
				@Height = HeightInches,
				@Weight = WeightLbs,
				@SSN = SSN,
				@MaritalStatus = MaritalStatusId,
				@EconomicStatus = EconomicStatusId,
				@ExistingRecordModifDate = ModifyDate
			FROM mainpersonaldetails
			WHERE ICENUMBER = @MVDId

			-- NOTE: always update because ReportDate will almost always be older than modifyDate
			-- Check if incoming record is newer than the existing one
--			if( @ExistingRecordModifDate is null or
--				(@ReportDate is not null and 
--				@ExistingRecordModifDate <= @ReportDate))
--			BEGIN
				EXEC Upd_ImportedProfile
					@IceNumber = @MVDId,
					@LastName = @LastName,
					@FirstName = @FirstName,
					@Phone = @Phone,
					@Email = @Email,
					@Address1 = @Address1,
					@Address2 = @Address2,
					@City = @City,
					@State = @State,
					@Zip = @Zip,
					@DOB = @DOB,
					@Gender = @MVDGender,
					@SSN = @SSN,
					@MaritalStatus = @MaritalStatus,
					@EconomicStatus = @EconomicStatus,
					@Height = @Height,
					@Weight = @Weight,
					@UpdatedBy = @UpdatedBy,
					@UpdatedByContact = @UpdatedByContact,
					@Organization = @Organization
--			END

			SET @Action = 'U'
*/
			-- Get ID of just updated record
			SELECT @MVDUpdatedRecordId = RecordNumber 
			FROM MainPersonalDetails
			WHERE ICENUMBER = @MVDId
		END

		IF @Result = 0 AND @Action != 'I'
		BEGIN	
			-- Keep the history of changes

			EXEC Import_SetHistoryLog
				@MVDID = @MVDId,
				@ImportRecordID = @SourceRecordID,
				@HPAssignedID = @HPAssignedRecordID,
				@MVDRecordID = @MVDUpdatedRecordId,
				@Action = @Action,
				@RecordType = 'PERSONAL',
				@Customer = @Customer,
				@SourceName = @SourceName
		END

	END TRY
	BEGIN CATCH
		SELECT @Result = -1		

		EXEC ImportCatchError	
	END CATCH