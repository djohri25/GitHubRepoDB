/****** Object:  Procedure [dbo].[Import_Demog_Single]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		sw
-- Create date: 2/26/2009
-- Description:	Import single Demographic record
-- =============================================
CREATE PROCEDURE [dbo].[Import_Demog_Single]
	@RecordId int,
	@InsMemberID varchar(30),
	@MedicareID varchar(30) = NULL,
	@MedicaidID varchar(30) = NULL,
	@CHIP_ID varchar(30) = NULL,
	@EffectiveDate varchar(35),
	@TerminationDate varchar(35),
	@LastName varchar(50),
	@FirstName varchar(50),
	@MiddleName	nvarchar(50) = NULL,
	@HomePhone varchar(20),
	@Address1 varchar(55),
	@Address2 varchar(55),
	@City varchar(30),
	@State char(2),
	@Zip varchar(15),
	@DOB varchar(35),
	@Gender char(1),
	@SSN varchar(9),
	-- contact info
	@Cont_FirstName varchar(35), 
	@Cont_LastName varchar(35),

	@InCaseManagement char(1),
	@NarcoticLockdown char(1),
	@DMProgram varchar(1000),
	@PCPName varchar(150),
	@PCPPhone varchar(50),
	@ProductType varchar(50),
	@PCP_Tin varchar(50),
	
	--CCC Additional Info
	@Ethnicity [varchar](100) =NULL,
	@MaritalStatus [varchar](100) =NULL,
	@Language [varchar](100) =NULL,
	@Homeless [varchar](100)= NULL,
	@PCP [varchar](100) =NULL,
	@Household_size [int] =NULL,
	@Housing_Status [varchar](50) =NULL,
	@CitizenshipStatus [varchar](50) =NULL,
	@FPL_Level [varchar](50) =NULL,
	@ProgramHandle [varchar](50) =NULL,

	@HPCustomerID int,
	@Customer varchar(50),
	@System_Memid varchar(30),
	
	@MemberID_MVDID	VARCHAR(30) = null,
	@LOB	VARCHAR(10) = null,
	
	@IsNewMember bit output,
	@IsDeactivated bit output,
	@UpdateResult int output
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		-- mvd data
		@MVDId varchar(15), 
		@MVDGroupId varchar(15),
		@MVDGender int,

		@Organization varchar(250),
		@UpdatedByContact varchar(50),		-- Health Plan phone
		-- History
		@MVDUpdatedRecordId varchar(50),
		-- Insurance info
		@InsName varchar(50),
		@InsAddress1 varchar(50),
		@InsAddress2 varchar(50),
		@InsCity varchar(50),
		@InsState varchar(2),
		@InsZip varchar(5),
		@InsPhone varchar(25),
		--I/U
		@Action	CHAR(1),
		@MaritalStatusID	INT 

	SET @UpdateResult = 0 

	set @InsMemberID = dbo.RemoveLeadChars(@InsMemberID,'0')

	SELECT @InCaseManagement =
		CASE @InCaseManagement
			WHEN 'Y' THEN '1'
			WHEN 'N' THEN '0'
			ELSE NULL
		END,
		@NarcoticLockdown =
		case @NarcoticLockdown
			WHEN 'Y' THEN '1'
			WHEN 'N' THEN '0'
			ELSE NULL
		END

	BEGIN TRY
		BEGIN TRAN
		-- Get info about organization which provided data
		IF @HPCustomerID IS NULL
			SELECT	TOP 1
					@HPCustomerId = Cust_ID,
					@InsName = Name, 
					@InsAddress1 = Address1, 
					@InsAddress2 = Address2, 
					@InsCity = City, 
					@InsState = State, 
					@InsZip = PostalCode, 
					@InsPhone = Phone
			FROM	HPCustomer WHERE Name = @Customer

		IF @HPCustomerID IS NOT NULL
			SELECT	TOP 1 
					@Organization = Name,
					@Customer = Name,
					@HPCustomerId = Cust_ID,
					@InsName = Name, 
					@InsAddress1 = Address1, 
					@InsAddress2 = Address2, 
					@InsCity = City, 
					@InsState = State, 
					@InsZip = PostalCode, 
					@InsPhone = Phone,
					@UpdatedByContact = Phone
			FROM	HPCustomer
			WHERE	cust_ID = @HPCustomerId

/*		IF @HPCustomerID IS NULL
			SELECT @HPCustomerID = cust_ID FROM HPCustomer WHERE Name = @Customer
		ELSE
		select @Organization = Name, @Customer = Name from hpcustomer where cust_ID = @HPCustomerID

		select @UpdatedByContact = Phone 
		from HPCustomer 
		where name = @Organization
*/
		------------------------------- Map data
		-- Gender
		SELECT @MVDGender = MVDGenderId FROM Link_Gender_MVD_Ins WHERE InsGenderId = @Gender

		-- Empty string for state violates FK
		IF LEN(ISNULL(@State,'')) = 0
			SET @State = NULL
		---------------------------------------

		-- Check if user was already imported
		SELECT @MVDId = MVDId FROM Link_MemberId_MVD_Ins WHERE InsMemberId = @InsMemberId and cust_id = @HPCustomerID
	IF (@HPCustomerID = 15)
	BEGIN
		IF EXISTS (Select 1 from Link_MemberId_MVD_Ins Where Cust_ID = @HPCustomerID and MVDID = @MemberID_MVDID and InsMemberId <> @InsMemberID)
		BEGIN
			UPDATE Link_MemberId_MVD_Ins
			SET InsMemberId = @InsMemberID
			Where Cust_ID = @HPCustomerID and MVDID = @MemberID_MVDID and InsMemberId <> @InsMemberID

			SET @MVDID = @MemberID_MVDID
		END

	END
		
		if(len(isnull(@TerminationDate,'')) > 0 AND @TerminationDate < getdate())
		begin
			set @IsDeactivated = 1
		end 
		else
		begin
			set @IsDeactivated = 0
		end

		IF @MaritalStatus = 'Single'
		BEGIN
			SET @MaritalStatus = 'Never Married'
		END
		SELECT @MaritalStatusID = MaritalStatusID FROM LookupMaritalStatusID WHERE MaritalStatusName = LTRIM(RTRIM(@MaritalStatus))

		IF @MVDId IS NULL
		BEGIN
			set @IsNewMember = 1

			-- Generate new MVD GroupID
			EXEC GenerateRandomString 0,0,0,'23456789ABCDEFGHJKLMNPQRSTWXYZ',10, @MVDGroupId output

			-- Repeat generating MVD GroupID until it's unique
			WHILE EXISTS (SELECT ICEGROUP FROM MainICENUMBERGroups WHERE ICEGROUP = @MVDGroupId)
				EXEC GenerateRandomString 0,0,0,'23456789ABCDEFGHJKLMNPQRSTWXYZ',10, @MVDGroupId output

			IF (@HPCustomerID = 15) -- CCC -SFS Data (Note: @InsMemberID comes with Cust_id appended ex: 15AB123456) CCC -MAP Data (Note: @InsMemberID comes with LOB and Cust_id appended ex: MAP15AB123456)
			BEGIN
					SET @MVDId = @MemberID_MVDID --@InsMemberId
					
			END
			IF (@HPCustomerID < 15) -- all other Clients
			BEGIN
			-- Generate new MVD ID
			EXEC GenerateMVDId
				@firstName = @FirstName,
				@lastName = @LastName,
				@newID = @MVDId OUTPUT

			SET @MVDId = CAST(@HPCustomerID as VARCHAR(10))+@MVDId
			-- Repeat generating MVD ID until it's unique
			WHILE EXISTS (SELECT ICENUMBER FROM MainICENUMBERGroups WHERE ICENUMBER = @MVDId)
				BEGIN
					EXEC GenerateMVDId
					@firstName = @FirstName,
					@lastName = @LastName,
					@newID = @MVDId OUTPUT

					SET @MVDId = CAST(@HPCustomerID as VARCHAR(10))+@MVDId
				END
			END
			
			IF (@HPCustomerID <> 15)
			BEGIN
				SET @MaritalStatusID = ''
			END
			-- Create new user profile
			EXEC Set_NewImportedProfile
				@MVDGroup = @MVDGroupId,
				@834_GroupId = '',
				@MVDId = @MVDId,
				@LastName = @LastName,
				@FirstName = @FirstName,
				@MiddleName = @MiddleName,
				@IsPrimary = 1,
				@Phone = @HomePhone,
				@Email = '',
				@Address1 = @Address1,
				@Address2 = @Address2,
				@City = @City,
				@State = @State,
				@Zip = @Zip,
				@DOB = @DOB,
				@Gender = @MVDGender,
				@SSN = @SSN,
				@Ethnicity = @Ethnicity,
				@Language = @Language,
				@MaritalStatus = @MaritalStatusID,
				@EconomicStatus = '',
				@Height = '',
				@Weight = '',
				@InsGroupID = '',
				@InsMemberID = @InsMemberId,
				@CreatedBy = '',						-- Only set when Individual creates a record
				@CreatedByContact = @UpdatedByContact,	-- Common field for CreatedBy and Organization
				@Organization = @Organization,
				@HPCustomerId = @HPCustomerId,
				@InCaseManagement = @InCaseManagement,
				@NarcoticLockdown = @NarcoticLockdown,
				@System_Memid = @System_Memid,
				@LOB = @LOB,
				@RecordNumber = @MVDUpdatedRecordId OUTPUT,
				@Result = @UpdateResult OUTPUT

			IF @UpdateResult = 0
			BEGIN
				-- Keep the history of changes
				EXEC Import_SetHistoryLog
					@MVDID = @MVDId,
					@ImportRecordID = @RecordId,
					@HPAssignedID = '',
					@MVDRecordID = @MVDUpdatedRecordId,
					@Action = 'A',
					@RecordType = 'PERSONAL',
					@Customer = @Customer,
					@SourceName = 'DEMOGRAPHICS'
			END

			-- If contact information is provided import into MVD
			IF (@UpdateResult = 0 AND LEN(ISNULL(@Cont_LastName,'')) > 0 AND
				(@Cont_LastName <> @LastName or @Cont_FirstName <> @FirstName))
			BEGIN
				EXEC Set_ImportContact
					@ICENUMBER = @MVDId
					,@LastName = @Cont_LastName
					,@FirstName = @Cont_FirstName
					,@Address1 = ''
					,@Address2 = ''
					,@City = ''
					,@State = ''
					,@Postal = ''
					,@PhoneHome = ''
					,@PhoneCell = ''
					,@PhoneOther = ''
					,@CareTypeId = '6' -- Care Type: Secondary Contact
					,@RelationshipId = '8' -- Relationship: Other
					,@ContactType = NULL
					,@EmailAddress = ''
					,@NotifyByEmail = '0'
					,@NotifyBySMS = '0'
					,@CreatedBy = ''
					,@CreatedByContact = @UpdatedByContact
					,@Organization = @Organization
					,@RecordNumber = @MVDUpdatedRecordId OUTPUT
					,@Result = @UpdateResult OUTPUT		

				IF @UpdateResult = 0
				BEGIN
					-- Keep the history of changes
					EXEC Import_SetHistoryLog
						@MVDID = @MVDId,
						@ImportRecordID = @RecordId,
						@HPAssignedID = '',
						@MVDRecordID = @MVDUpdatedRecordId,
						@Action = 'A',
						@RecordType = 'CONTACT',
						@Customer = @Customer,
						@SourceName = 'DEMOGRAPHICS'	
				END
			END
		END
		ELSE
		BEGIN
			set @IsNewMember = 0
	
			-- Update existing record
			-- Get MVD Group ID
			SELECT @MVDGroupId = IceGroup FROM MainICENUMBERGroups WHERE icenumber = @MVDId

			EXEC Upd_ImportedProfile
				@IceNumber = @MVDId,
				@LastName = @LastName,
				@FirstName = @FirstName,
				@MiddleName = @MiddleName,
				@Phone = @HomePhone,
				@Email = '',
				@Address1 = @Address1,
				@Address2 = @Address2,
				@City = @City,
				@State = @State,
				@Zip = @Zip,
				@DOB = @DOB,
				@Gender = @MVDGender,
				@SSN = @SSN,
				@Ethnicity = @Ethnicity,
				@Language = @Language,
				@MaritalStatus = @MaritalStatusID,
				@EconomicStatus = '',
				@Height = '',
				@Weight = '',
				@UpdatedBy = '',
				@UpdatedByContact = @UpdatedByContact,
				@Organization = @Organization,
				@InCaseManagement = @InCaseManagement,
				@NarcoticLockdown = @NarcoticLockdown,
				@System_Memid = @System_Memid,
				@LOB = @LOB,
				@RecordNumber = @MVDUpdatedRecordId OUTPUT

			-- Keep the history of changes
			-- Get ID of just updated record
			SELECT @MVDUpdatedRecordId = RecordNumber 
			FROM MainPersonalDetails
			WHERE ICENUMBER = @MVDId

			EXEC Import_SetHistoryLog
				@MVDID = @MVDId,
				@ImportRecordID = @RecordId,
				@HPAssignedID = '',
				@MVDRecordID = @MVDUpdatedRecordId,
				@Action = 'U',
				@RecordType = 'PERSONAL',
				@Customer = @Customer,
				@SourceName = 'DEMOGRAPHICS'

			-- Check if contact data is provided and exists in contacts section
			IF (LEN(ISNULL(@Cont_LastName,'')) != 0 AND
				(@Cont_LastName <> @LastName or @Cont_FirstName <> @FirstName))
			BEGIN
				DECLARE @contCount int, @recNumber int

				-- Check if already exists
				SELECT @recNumber = RecordNumber FROM maincareinfo 
				WHERE icenumber = @MVDId AND LastName = @Cont_LastName

				IF @recNumber IS NULL
				BEGIN
					-- insert new contact
					EXEC Set_ImportContact
						@ICENUMBER = @MVDId
						,@LastName = @Cont_LastName
						,@FirstName = @Cont_FirstName
						,@Address1 = ''
						,@Address2 = ''
						,@City = ''
						,@State = ''
						,@Postal = ''
						,@PhoneHome = ''
						,@PhoneCell = ''
						,@PhoneOther = ''
						,@CareTypeId = '6' -- Care Type: Secondary Contact
						,@RelationshipId = '8' -- Relationship: Other
						,@ContactType = NULL
						,@EmailAddress = ''
						,@NotifyByEmail = '0'
						,@NotifyBySMS = '0'
						,@CreatedBy = ''
						,@CreatedByContact = @UpdatedByContact
						,@Organization = @Organization
						,@RecordNumber = @MVDUpdatedRecordId OUTPUT
						,@Result = @UpdateResult OUTPUT

					IF @UpdateResult = 0
					BEGIN
						-- Keep the history of changes
						EXEC Import_SetHistoryLog
							@MVDID = @MVDId,
							@ImportRecordID = @RecordId,
							@HPAssignedID = '',
							@MVDRecordID = @MVDUpdatedRecordId,
							@Action = 'A',
							@RecordType = 'CONTACT',
							@Customer = @Customer,
							@SourceName = 'DEMOGRAPHICS'	
					END
				END
				ELSE
				BEGIN			
					-- update existing contact
					EXEC Upd_MainCareInfo
						@RecNum = @recNumber
						,@LastName = @Cont_LastName
						,@FirstName = @Cont_FirstName
						,@Address1 = ''
						,@Address2 = ''
						,@City = ''
						,@State = ''
						,@Postal = ''
						,@PhoneHome = ''
						,@PhoneCell = ''
						,@PhoneOther = ''
						,@CareTypeId = '6' -- Care Type: Secondary Contact
						,@RelationshipId = '8' -- Relationship: Other
						,@ContactType = NULL
						,@EmailAddress = ''
						,@NotifyByEmail = '0'
						,@NotifyBySMS = '0'
						,@UpdatedBy = ''
						,@UpdatedByContact = @UpdatedByContact
						,@Organization = @Organization
						,@Result = @UpdateResult OUTPUT

					-- Keep the history of changes
					IF @UpdateResult = 0
					BEGIN
						-- Get ID of just updated record
						SELECT @MVDUpdatedRecordId = @recNumber

						EXEC Import_SetHistoryLog
							@MVDID = @MVDId,
							@ImportRecordID = @RecordId,
							@HPAssignedID = '',
							@MVDRecordID = @MVDUpdatedRecordId,
							@Action = 'U',
							@RecordType = 'CONTACT',
							@Customer = @Customer,
							@SourceName = 'DEMOGRAPHICS'	
					END
				END
			END
		END
		--CCC Member Additional Info
		IF @HPCustomerID = 15
		BEGIN
			EXEC Set_MemberAdditionalInfo 
			@Cust_ID = @HPCustomerID,
			@MVDID	= @MVDID,
			@InsMemberID = @InsMemberID,
			@Homeless = @Homeless,
			@PCP = @PCP ,
			@Household_size = @Household_size,
			@Housing_Status = @Housing_Status,
			@CitizenshipStatus = @CitizenshipStatus,
			@FPL_Level = @FPL_Level,
			@ProgramHandle = @ProgramHandle,
			@Action = @Action	OUTPUT,
			@Result = @UpdateResult OUTPUT

			IF @UpdateResult = 0
					BEGIN
						-- Get ID of just updated record
						SELECT @MVDUpdatedRecordId = @recNumber

						EXEC Import_SetHistoryLog
							@MVDID = @MVDId,
							@ImportRecordID = @RecordId,
							@HPAssignedID = '',
							@MVDRecordID = @MVDUpdatedRecordId,
							@Action = @Action,
							@RecordType = 'Member Additional Info',
							@Customer = @Customer,
							@SourceName = 'CCC'	
					END
		END

		-- INSURANCE SECTION
		IF @UpdateResult = 0 AND LEN(ISNULL(@MVDId,'')) > 0 and @EffectiveDate is not null
		BEGIN
			EXEC Import_Insurance
				@MVDId = @MVDId,
				@EffectiveDate = @EffectiveDate,
				@TerminationDate = @TerminationDate,
				@PolicyNumber = @InsMemberID,
				@PolicyHolderFirstName = @FirstName,
				@PolicyHolderLastName = @LastName,
				@MedicareID = @MedicareID,
				@MedicaidID = @MedicaidID,
				@CHIP_ID = @CHIP_ID,
				@SourceName = 'DEMOGRAPHICS',
				@SourceRecordID = @RecordId,
				@HPAssignedRecordID = '',
				@UpdatedBy = '', 
				@UpdatedByContact = @UpdatedByContact,
				@Organization = @Organization, 
				@InsName = @InsName,
				@InsAddress1 = @InsAddress1,
				@InsAddress2 = @InsAddress2,
				@InsCity = @InsCity,
				@InsState = @InsState,
				@InsZip = @InsZip,
				@InsPhone = @InsPhone,
				@Customer = @Customer, 
				@ProductType = @ProductType,
				@Result = @UpdateResult OUTPUT
		END

		-- DISEASE MANAGEMENT PROGRAMS
		IF @UpdateResult = 0 AND LEN(ISNULL(@MVDId,'')) > 0 AND LEN(RTRIM(LTRIM(@DMProgram))) > 0
		BEGIN
			EXEC Import_DMPrograms
				@MVDID = @MVDId,
				@DMProgramList = @DMProgram,
				@HPCustomerID = @HPCustomerID,
				@Result = @UpdateResult OUTPUT
		END

		-- PRIMARY CARE PHYSICIAN
		-- don't update pcp based on historical data (determined by termination date)		
		IF @UpdateResult = 0 AND LEN(ISNULL(@MVDId,'')) > 0 AND LEN(RTRIM(LTRIM(@PCPName))) > 0
			and not exists(select top 1 * from MainInsurance where ICENUMBER = @MVDId and Name = @InsName and isnull(TerminationDate,'1/1/2050') > @TerminationDate)
		BEGIN
			EXEC Import_PrimaryCarePhysician
				@MVDID = @MVDId,
				@PCPName = @PCPName,
				@PCPPhone = @PCPPhone,
				@PCP_Tin = @PCP_Tin,
				@Result = @UpdateResult OUTPUT
		END
		COMMIT TRAN
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN
		DECLARE @addInfo nvarchar(MAX)
		SELECT	@UpdateResult = -1,
				@addInfo = 
					'RecordId=' + CAST(@RecordId AS VARCHAR(16)) + ', InsMemberID=' + ISNULL(@InsMemberID, 'NULL') + ', MedicareID=' + ISNULL(@MedicareID, 'NULL') + 
					', MedicaidID=' + ISNULL(@MedicaidID, 'NULL') + ', EffectiveDate=' + ISNULL(@EffectiveDate, 'NULL') + ', TerminationDate=' + ISNULL(@TerminationDate, 'NULL') + 
					', LastName=' + ISNULL(@LastName, 'NULL') + ', FirstName=' + ISNULL(@FirstName, 'NULL') + ', MiddleName=' + ISNULL(@MiddleName, 'NULL') + 
					', HomePhone=' + ISNULL(@HomePhone, 'NULL') + ', Address1=' + ISNULL(@Address1, 'NULL') + ', Address2=' + ISNULL(@Address2, 'NULL') + 
					', City=' + ISNULL(@City, 'NULL') + ', State=' + ISNULL(@State, 'NULL') + ', Zip=' + ISNULL(@Zip, 'NULL') + ', DOB=' + ISNULL(@DOB, 'NULL') + 
					', Gender=' + ISNULL(@Gender, 'NULL') + ', SSN=' + ISNULL(@SSN, 'NULL') + ', Cont_FirstName=' + ISNULL(@Cont_FirstName, 'NULL') + 
					', Cont_LastName=' + ISNULL(@Cont_LastName, 'NULL') + ', Customer=' + ISNULL(@Customer, 'NULL') + ', System_Memid=' + ISNULL(@System_Memid, 'NULL') +
					', PCP_Tin=' + ISNULL(@PCP_Tin, 'NULL')
		EXEC ImportCatchError @addInfo
	END CATCH

/* Note sure why it was here because all records come from hpm_import.dbo.demographics table

	if(db_name() = 'MyVitalDataLive')
	begin
		-------- Update import result
		declare @tempRecordID int

		set @tempRecordID = 0

		select top 1 @tempRecordID = ID
		from hpm_import.dbo.demographics
			where [Recipient ID] = @InsMemberID
				and isProcessed = 0

		if( @UpdateResult = 0 and @tempRecordID <> 0)
		begin
			-- Successful import and record exists
			update hpm_import.dbo.demographics
				set isProcessed = '1', processedDate = convert(varchar,getutcdate(),20)  
			where ID = convert(varchar,@tempRecordID,10)
		end
		else if( @UpdateResult <> 0)
		begin
			-- Record will have to be reprocessed
				
			if(@tempRecordID = 0)
			begin
				insert into hpm_import.dbo.demographics
					([Recipient Id],[Effective Date],[Termination Date],[Member First Name],[Member Middle Name],[Member Last Name]
					,[Address Line 1],[Address Line 2],[City],[State],[Zip],[County],[Date of Birth],[Gender],[SSN]
					,[Resp Party First Name],[Resp Party Middle Name],[Resp Party Last Name],[Home Phone]
					,[IsProcessed],[ProcessedDate],[Created],[ProcessNote],[ProcessAttemptCount]
					,[InCaseManagement],[NarcoticLockdown],[DMProgram],[PCPName],[PCPPhone],[Cust_ID],MedicareID,MedicaidID)
				values(@InsMemberID,@EffectiveDate,@TerminationDate,@FirstName,@MiddleName,@LastName,
					@Address1,@Address2,@City,@State,@Zip,null,@DOB,@Gender,@SSN,
					@Cont_FirstName,null,@Cont_LastName,@HomePhone,
					0,null,getutcdate(),null,1,
					@InCaseManagement,@NarcoticLockdown,@DMProgram,@PCPName,@PCPPhone,@HPCustomerId,@MedicareID,@MedicaidID)		
			end		
			else
			begin
				update hpm_import.dbo.demographics
					set processAttemptCount = processAttemptCount + 1
				where id = convert(varchar,@tempRecordID,10)
			end
		end
	end
*/	
	
END