/****** Object:  Procedure [dbo].[Import_RX_Single]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		SW
-- Create date: 2/27/2009
-- Description:	Import single RX record (Medications)
-- =============================================
CREATE PROCEDURE [dbo].[Import_RX_Single]
    @recordId int,
	-- Owner
	@MemberID varchar(30),
	@MemberLastName varchar(35),
	@MemberFirstName varchar(25),
	@MemberDOB varchar(35),
	@MemberGender char(1),

	-- Medication related
	@RxControlNumber nvarchar(50),
	@PharmacyID nvarchar(50),
	@PharmacyName nvarchar(50),
	@PrescriberId nvarchar(50),
	@PrescriberLastName nvarchar(50),
	@PrescriberFirstName nvarchar(50),
	@DateFilled nvarchar(50),
	@NDC nvarchar(50),
	@DaysSupply nvarchar(50),
	@Quantity nvarchar(50),
	@ClaimStatus char(1),
	@Customer varchar(50) = 'Health Plan of Michigan',
	@ImportResult int output			-- 0 - success, -1 - failure, -2 - item listed on "ignore list"

AS
BEGIN
	SET NOCOUNT ON

	declare
			-- mvd data
			@MVDGroupId varchar(15),
			@MVDId varchar(15), 
			@MVDGender int,
			@UpdatedBy varchar(250),
			@UpdatedByContact varchar(50),
			@UpdatedByNPI varchar(20),
			@Organization varchar(250),
			@HPCustomerId int,
			-- provider info from LookupNPI table
			@TempUpdatedByNPI varchar(20),
			@TempProvOrgName varchar(50),
			@TempProvLastName varchar(50),
			@TempProvFirstName varchar(50),
			@TempProvCredentials varchar(50),	-- prefix in the individual's name
			@TempProvPhone varchar(50),
			@TempProvType int,					-- 1 - individual, 2 - organization
			-- Insurance info
			@InsName varchar(50),
			@InsAddress1 varchar(50),
			@InsAddress2 varchar(50),
			@InsCity varchar(50),
			@InsState varchar(2),
			@InsZip varchar(5),
			@InsPhone varchar(10)

	-- provider info from LookupNPI table
	create table #tempProv 
	(
		npi varchar(50),
		type char(1),
		organizationName varchar(50),
		lastName varchar(50),
		firstName varchar(50),
		credentials varchar(50),
		address1 varchar(50),
		address2 varchar(50),
		city  varchar(50),
		state  varchar(2),
		zip	 varchar(50),
		Phone varchar(10),
		Fax varchar(50)
	)

	BEGIN TRY
		BEGIN TRAN

		set @MemberID = dbo.RemoveLeadChars(@MemberID,'0')

		IF ISNULL(@customer,'') = ''
			-- Default
			SET @Customer = 'Health Plan of Michigan'
 
		IF LEN(@customer) < 3
		BEGIN
			-- Customer ID was passed (e.g. from ImportHPM_Claims_LIVE), so retrieve customer name
			SET @HPCustomerId = @Customer

			SELECT	TOP 1
					@Customer = Name,
					@HPCustomerId = Cust_ID,
					@InsName = Name, 
					@InsAddress1 = Address1, 
					@InsAddress2 = Address2, 
					@InsCity = City, 
					@InsState = State, 
					@InsZip = PostalCode, 
					@InsPhone = Phone
			FROM	HPCustomer
			WHERE	cust_ID = @HPCustomerId
		END
		ELSE
			-- Get the customer the account belongs to
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

		----------------------------------------------------------------------------------
		-- Set prescriber as data provider
		-- Retrieved provider info if it could be located in lookup NPI table
		insert into #tempProv (npi, type, organizationName, lastName, firstName, credentials, 
				address1, address2,city, state, zip, Phone, Fax)
		exec Get_ProviderByID @ID = @PrescriberId, @Name = @PrescriberLastName

		SELECT	TOP 1
				@UpdatedByNPI = NPI,
				@TempProvOrgName = organizationName,
				@TempProvLastName = lastName,
				@TempProvFirstName = firstName,
				@TempProvCredentials = credentials,
				@TempProvPhone = Phone,
				@TempProvType = type
		FROM	#tempProv

		IF @UpdatedByNPI IS NOT NULL
		begin
			-- Info was successfully retrieved from lookup
			If @TempProvType = '1'
			begin
				-- Person (e.g. a doctor format: John Smith, Dr.)
				select	@UpdatedBy = isnull(@TempProvFirstName+ ' ','')  + isnull(@TempProvLastName,'') + isnull(', ' + @TempProvCredentials,''),
						@UpdatedByContact = @TempProvPhone,
						@Organization = ''

				-- Since current RX doesn't provide Prescriber First Name, set it based on lookup data
				select @PrescriberFirstName = @TempProvFirstName,
					@PrescriberLastName = @TempProvLastName				
			end
			else
			begin
				-- Organization
				select	@UpdatedBy = '',
						@UpdatedByContact = @TempProvPhone,
						@Organization = @TempProvOrgName

				-- If prescriber not provided set from lookup
				IF ISNULL(@PrescriberLastName,'') = '' AND ISNULL(@PrescriberFirstName,'') = ''
				begin
					select @PrescriberLastName = @TempProvOrgName
				end
			end
		end
		else
		begin
			IF ISNULL(@PrescriberLastName,'') != '' AND ISNULL(@PrescriberFirstName,'') != ''
			begin
				-- Person (e.g. a doctor)
				select	@UpdatedBy = @PrescriberFirstName + ' ' + @PrescriberLastName,
						@UpdatedByContact = '',
						@Organization = ''
			end
			ELSE IF ISNULL(@PrescriberLastName,'') != ''
			begin
				-- Currently there is no prescriber first name set in the import file
				-- Check if there are spaces in the name, if not assume it's individual
				IF (CHARINDEX(' ', @PrescriberLastName) = 0 
					AND CHARINDEX(' ', @PrescriberLastName) != LEN(@PrescriberLastName))
				begin
					select	@UpdatedBy = @PrescriberLastName, 
						@UpdatedByContact = '',
						@Organization = ''
				end
				else
				begin
					 -- Organization
					 select	@UpdatedBy = '',
							@UpdatedByContact = '',
							@Organization = @PrescriberLastName
				end
			end
			else 
			begin
				-- Default Organization
				select	@UpdatedBy = '',
						@Organization = @Customer
			end
		end
		----------------------------------------------------------------------------------

		-- MEMBER SECTION
		-- Same fields are provided in Claims records, so use the same
		-- procedure to process that section. 
		EXEC Import_Personal
			@IsPrimary = 1,
			@MemberID = @MemberID,
			@InsGroupId = '',
			@MVDGroupId = @MVDGroupId,
			@LastName = @MemberLastName,
			@FirstName = @MemberFirstName,
			@DOB = @MemberDOB,
			@Gender = @MemberGender,
			@MVDId = @MVDId output, -- At this point, @MVDId has the MVD Id of the newly created or updated MVD record
			@ReportDate = @DateFilled,
			@UpdatedBy = @UpdatedBy,
			@UpdatedByContact = @UpdatedByContact,	
			@Organization = @Organization,
			@HPCustomerId = @HPCustomerId,
			@SourceName = 'RX',
			@SourceRecordID = @recordId,
			@HPAssignedRecordID = @RxControlNumber,
			@Customer = @Customer, 
			@Result = @ImportResult output				

		-- INSURANCE SECTION
		IF @ImportResult = 0 AND ISNULL(@MVDId,'') != ''
		begin
			EXEC Import_Insurance
				@MVDId = @MVDId,
				@PolicyNumber = @MemberID,
				@PolicyHolderFirstName = @MemberFirstName,
				@PolicyHolderLastName = @MemberLastName,
				@SourceName = 'RX',
				@SourceRecordID = @recordId,
				@HPAssignedRecordID = @RxControlNumber,
				@UpdatedBy = @UpdatedBy, 
				@UpdatedByContact = @UpdatedByContact,
				@Organization = @Organization, 
				@UpdatedByNPI = @UpdatedByNPI,
				@InsName = @InsName,
				@InsAddress1 = @InsAddress1,
				@InsAddress2 = @InsAddress2,
				@InsCity = @InsCity,
				@InsState = @InsState,
				@InsZip = @InsZip,
				@InsPhone = @InsPhone,
				@Customer = @Customer, 
				@Result = @ImportResult OUTPUT
		end

		-- MEDICATION SECTION
		IF @ImportResult = 0 AND ISNULL(@MVDId,'') != ''
		begin
			EXEC Import_RX_Medication 
				@RxRecordId = @recordId,
				@MVDId = @MVDId, 
				@RxControlNumber = @RxControlNumber,
				@PharmacyID = @PharmacyID,
				@PharmacyName = @PharmacyName,
				@PrescriberId = @PrescriberId,
				@PrescriberLastName = @PrescriberLastName,
				@PrescriberFirstName = @PrescriberFirstName,
				@DateFilled = @DateFilled,
				@NDC = @NDC,
				@DaysSupply = @DaysSupply,
				@Quantity = @Quantity,
				@ClaimStatus = @ClaimStatus,
				@UpdatedBy = @UpdatedBy, 
				@UpdatedByContact = @UpdatedByContact,	
				@UpdatedByNPI = @UpdatedByNPI,
				@Organization = @Organization, 
				@Customer = @Customer, 
				@Result = @ImportResult OUTPUT
		end
/*
		if(db_name() = 'MyVitalDataLive')
		begin
			-------- Update import result
			declare @tempRecordID int

			set @tempRecordID = 0

			select @tempRecordID = ID
			from hpm_import.dbo.RX with (index (IX_RX_MemberID))
				where [Member ID] = @MemberID
					and [Rx Control number] = @RxControlNumber
					and isProcessed = 0

			IF @ImportResult = 0 AND @tempRecordID != 0
			begin
				-- Successful import and record exists
				update hpm_import.dbo.RX
					set isProcessed = '1', processedDate = convert(varchar,getutcdate(),20), forceProcess = 0   
				where ID = convert(varchar,@tempRecordID,10)
			end
			ELSE IF @ImportResult != 0
			begin
				-- Record will have to be reprocessed
					
				if(@tempRecordID = 0)
				begin
					insert into hpm_import.dbo.RX
						([Rx Control number],[Action Code],[Pharmacy ID],[Pharmacy Name],[Prescriber Id],[Prescriber Last Name],[Prescriber First Name]
						,[Member ID],[Member Last Name],[Member First Name],[Member DOB],[Member Gender]
						,[Claim Status],[Date Filled],[Rx Number],[NDC],[Days Supply],[Total Amount],[Quantity]
						,[IsProcessed],[ProcessedDate],[Created],[ProcessNote],[ProcessAttemptCount],[forceProcess],[Cust_ID])
					values(@RxControlNumber,'',@PharmacyID,@PharmacyName,@PrescriberId, @PrescriberLastName,@PrescriberFirstName,
						@MemberID, @MemberLastName,@MemberFirstName,@MemberDOB,@MemberGender,
						@ClaimStatus,@DateFilled,'',@NDC,@DaysSupply,'',@Quantity,
						0,null,getutcdate(),null,1,0,@HPCustomerId)				
				end		
				else
				begin
					update hpm_import.dbo.RX
						set processAttemptCount = processAttemptCount + 1, forceProcess = 0 
					where id = convert(varchar,@tempRecordID,10)
				end
			end
		end
*/		
		COMMIT TRAN
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN
		SELECT @ImportResult = -1
		DECLARE @addInfo nvarchar(MAX)
		SELECT	@addInfo = 'recordId=' + CAST(@recordId AS varchar(16)) + ', MemberID=' + @MemberID + ', MemberLastName=' + @MemberLastName + 
					', MemberFirstName=' + @MemberFirstName + ', MemberDOB=' + @MemberDOB + ', MemberGender=' + @MemberGender + 
					', RxControlNumber=' + @RxControlNumber + ', PharmacyID=' + @PharmacyID + ', PharmacyName=' + @PharmacyName + 
					', PrescriberId=' + @PrescriberId + ', PrescriberLastName=' + @PrescriberLastName + 
					', PrescriberFirstName=' + @PrescriberFirstName + ', DateFilled=' + @DateFilled + ', NDC=' + @NDC + 
					', DaysSupply=' + @DaysSupply + ', Quantity=' + @Quantity + ', ClaimStatus=' + @ClaimStatus + 
					', Customer=' + @Customer

		EXEC ImportCatchError @addInfo
	END CATCH

	drop table #tempProv
end