/****** Object:  Procedure [dbo].[Import_Insurance]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		SW
-- Create date: 2/9/2009
-- Description:	Import insurance info of the member.
--		If the record exists, update. Otherwise crete new record.
--		This import is specific to members
-- =============================================
CREATE PROCEDURE [dbo].[Import_Insurance]
	@MVDId varchar(15),
	@EffectiveDate varchar(35) = null,
	@TerminationDate varchar(35) = null,
	@PolicyNumber varchar(30),
	@PolicyHolderLastName varchar(35),
	@PolicyHolderFirstName varchar(25),
	@MedicareID varchar(30) = null,
	@MedicaidID varchar(30) = null,
	@CHIP_ID varchar(30) = null, 
	@SourceName varchar(50),
	@SourceRecordID int,
	@HPAssignedRecordID varchar(50),
	@UpdatedBy varchar(250),			-- Only set when Individual creates/updates a record
	@UpdatedByContact varchar(50),		-- Common field for CreatedBy and Organization
	@Organization varchar(250),
	@UpdatedByNPI varchar(50) = null,
	-- Insurance info
	@InsName varchar(50),
	@InsAddress1 varchar(50),
	@InsAddress2 varchar(50),
	@InsCity varchar(50),
	@InsState varchar(2),
	@InsZip varchar(5),
	@InsPhone varchar(100),
	@ProductType varchar(50) = null,
	
	@Customer varchar(50) = 'Health Plan of Michigan',
	@Result int OUTPUT					-- 0 - success, -1 - failure
as
	SET NOCOUNT ON
	declare
		-- mvd data
		@MVDGender int,
		@ExistingRecordModifDate datetime,
		@InsuranceTypeID int,
		-- History
		@MVDUpdatedRecordId int,
		@Action char(1),
		@curEffectiveDate varchar(35), 
		@curTerminationDate varchar(35),
		@tempMedicaidID varchar(30), 
		@tempMedicareID varchar(30),
		
		@originalEffectiveDate varchar(35),
		@originalTerminationDate varchar(35)

	select @Result = -1,
		@originalEffectiveDate = @EffectiveDate,
		@originalTerminationDate = @TerminationDate
		
	BEGIN TRY
		-- Set the imported insurance as primary
		SELECT	TOP 1 @InsuranceTypeID = InsuranceTypeID
		FROM	dbo.LookupInsuranceTypeID 
		WHERE	InsuranceTypeName LIKE 'Primary%'

		-- Set HPM as data provider
		SELECT	@UpdatedBy = '',
				@Organization = @InsName,
				@UpdatedByContact = @InsPhone

		-- Prevent inserting default date 1900/1/1
		IF @EffectiveDate = ''
			SET @EffectiveDate = NULL
		
		IF @TerminationDate IN ('', '12/31/2199', '12/31/2099')
			SET @TerminationDate = NULL

		-- Check if user was already imported
		-- Insurance info is provided by HPM and MVD so just make sure the record exists
		SELECT	@MVDUpdatedRecordId = RecordNumber,
				@curEffectiveDate = EffectiveDate,
				@curTerminationDate = TerminationDate,
				@tempMedicareID = MedicareNumber,
				@tempMedicaidID = Medicaid
		FROM	MainInsurance 
		WHERE	ICENUMBER = @MVDId AND Name = @InsName
		
		IF @InsName IS NOT NULL AND @MVDUpdatedRecordId IS NULL
		begin			
			-- Create new user profile
			insert into MainInsurance (ICENUMBER,Name,Address1,Address2,City,State,Postal,Phone,
				PolicyHolderName,PolicyNumber,InsuranceTypeID,EffectiveDate,TerminationDate,
				MedicareNumber,Medicaid,CHIP_ID,
				CreationDate,ModifyDate,
				CreatedBy,CreatedByOrganization,CreatedByNPI,UpdatedBy,UpdatedByOrganization,UpdatedByNPI,UpdatedByContact,
				ProductType)
			values (
				@MVDId, @InsName, @InsAddress1, @InsAddress2, @InsCity, @InsState, @InsZip, @InsPhone,
				isnull(@PolicyHolderFirstName,'') + ' ' + isnull(@PolicyHolderLastName,''),
				@PolicyNumber, @InsuranceTypeID, @EffectiveDate, @TerminationDate,
				@MedicareID,@MedicaidID,@CHIP_ID,
				getutcdate(), getutcdate(), 
				@UpdatedBy, @Organization,@UpdatedByNPI, @UpdatedBy, @Organization,@UpdatedByNPI, @UpdatedByContact,
				@ProductType
				)

			set @Result = 0

			select @Action = 'A', @MVDUpdatedRecordId = (SCOPE_IDENTITY())
		end
		else if(@originalEffectiveDate is not null OR @originalTerminationDate is not null)
		begin
			-- Update existing record
			if(@Customer = 'Driscoll')
			begin
				IF @EffectiveDate IS NULL AND @TerminationDate IS NULL
				begin
					-- Data not provided, don't overwrite
					SELECT	@EffectiveDate = @curEffectiveDate, 
							@TerminationDate = @curTerminationDate
				end
			end
			else
			begin			
				
				IF @EffectiveDate IS NULL AND @TerminationDate IS NULL
				begin
					-- Data not provided, don't overwrite
					SELECT	@EffectiveDate = @curEffectiveDate, 
							@TerminationDate = @curTerminationDate
				end
				ELSE IF @curEffectiveDate IS NOT NULL AND @TerminationDate IS NOT NULL AND 
						CONVERT(datetime,@curEffectiveDate) > CONVERT(datetime,@TerminationDate)
				begin
					-- The import dates are older than the existing dates - ignore
					SELECT	@EffectiveDate = @curEffectiveDate, 
							@TerminationDate = @curTerminationDate	
				end
			end
			
			-- Don't overwrite medicare and medicaid
			IF ISNULL(@MedicareID,'') = '' AND ISNULL(@MedicaidID,'') = ''
				SELECT	@MedicareID = @tempMedicareID, 
						@MedicaidID = @tempMedicaidID

			update MainInsurance set 
				Address1 = @InsAddress1,
				Address2 = @InsAddress2,
				City = @InsCity,
				State = @InsState,
				Postal = @InsZip,
				Phone = @InsPhone,
				PolicyHolderName = isnull(@PolicyHolderFirstName,'') + ' ' + isnull(@PolicyHolderLastName,''),
				PolicyNumber = @PolicyNumber,
				InsuranceTypeID = @InsuranceTypeID,
				EffectiveDate = @EffectiveDate,
				TerminationDate = @TerminationDate,
				MedicareNumber = @MedicareID,
				Medicaid = @MedicaidID,
				CHIP_ID = @CHIP_ID,
				ModifyDate = (GETUTCDATE()),
				UpdatedBy = @UpdatedBy,
				UpdatedByContact = @UpdatedByContact,
				UpdatedByOrganization = @Organization,
				UpdatedByNPI = @UpdatedByNPI,
				ProductType = @ProductType
			where RecordNumber = @MVDUpdatedRecordId

			set @Action = 'U'
			set @Result = 0
		end
		else
		begin
			-- claim records don't have insurance info so if effective and termination dates are null it doesn't mean the claim import should fail
			set @Result = 0
		end

		if(@originalEffectiveDate is not null OR @originalTerminationDate is not null)
		begin
			-- Driscoll sends full updated history of insurance each week. So once new batch starts delete the old one
			if(@Customer = 'Driscoll' 
				and not exists(select top 1 ICENUMBER from MainInsurance_History 
					where ICENUMBER = @MVDId and CreationDate > DATEADD(day,-2,getutcdate()))
			)
			begin
					delete from MainInsurance_History 
					where ICENUMBER = @MVDId
			end
			
			insert into MainInsurance_history (ICENUMBER,Name,Address1,Address2,City,State,Postal,Phone,
				PolicyHolderName,PolicyNumber,InsuranceTypeID,EffectiveDate,TerminationDate,
				MedicareNumber,Medicaid,CHIP_ID,
				CreationDate,ModifyDate,
				CreatedBy,CreatedByOrganization,CreatedByNPI,UpdatedBy,UpdatedByOrganization,UpdatedByNPI,UpdatedByContact,
				ProductType)
			values (
				@MVDId, @InsName, @InsAddress1, @InsAddress2, @InsCity, @InsState, @InsZip, @InsPhone,
				isnull(@PolicyHolderFirstName,'') + ' ' + isnull(@PolicyHolderLastName,''),
				@PolicyNumber, @InsuranceTypeID, @originalEffectiveDate, @originalTerminationDate,
				@MedicareID,@MedicaidID,@CHIP_ID,
				getutcdate(), getutcdate(), 
				@UpdatedBy, @Organization,@UpdatedByNPI, @UpdatedBy, @Organization,@UpdatedByNPI, @UpdatedByContact,
				@ProductType)
		end
		
		IF @Result = 0 AND @Action != 'I'
		begin	
			-- Keep the history of changes

			EXEC Import_SetHistoryLog
				@MVDID = @MVDId,
				@ImportRecordID = @SourceRecordID,
				@HPAssignedID = @HPAssignedRecordID,
				@MVDRecordID = @MVDUpdatedRecordId,
				@Action = @Action,
				@RecordType = 'INSURANCE',
				@Customer = @Customer,
				@SourceName = @SourceName
		end

	END TRY
	BEGIN CATCH

		DECLARE @addInfo nvarchar(MAX)	
				
		SELECT @Result = -1,
			@addInfo = 
				'@MVDId=' + ISNULL( @MVDId, 'NULL') + ', 
				@EffectiveDate=' + ISNULL( @EffectiveDate, 'NULL') + ', 
				@TerminationDate=' + ISNULL( @TerminationDate, 'NULL') + ', 
				@PolicyNumber=' + ISNULL( @PolicyNumber, 'NULL') + ', 
				@PolicyHolderLastName=' + ISNULL( @PolicyHolderLastName, 'NULL') + ', 
				@PolicyHolderFirstName=' + ISNULL( @PolicyHolderFirstName, 'NULL') + ', 
				@MedicareID=' + ISNULL( @MedicareID, 'NULL') + ', 
				@MedicaidID=' + ISNULL( @MedicaidID, 'NULL') + ', 
				@CHIP_ID=' + ISNULL( @CHIP_ID, 'NULL') + ',  
				@SourceName=' + ISNULL( @SourceName, 'NULL') + ', 
				@SourceRecordID=' + ISNULL( convert(varchar,@SourceRecordID), 'NULL') + ', 
				@HPAssignedRecordID=' + ISNULL( @HPAssignedRecordID, 'NULL') + ', 
				@UpdatedBy=' + ISNULL( @UpdatedBy, 'NULL') + ', 
				@UpdatedByContact=' + ISNULL( @UpdatedByContact, 'NULL') + ', 
				@Organization=' + ISNULL( @Organization, 'NULL') + ', 
				@UpdatedByNPI=' + ISNULL( @UpdatedByNPI, 'NULL') + ', 
				@InsName=' + ISNULL( @InsName, 'NULL') + ', 
				@InsAddress1=' + ISNULL( @InsAddress1, 'NULL') + ', 
				@InsAddress2=' + ISNULL( @InsAddress2, 'NULL') + ', 
				@InsCity=' + ISNULL( @InsCity, 'NULL') + ', 
				@InsState=' + ISNULL( @InsState, 'NULL') + ', 
				@InsZip=' + ISNULL( @InsZip, 'NULL') + ', 
				@InsPhone=' + ISNULL( @InsPhone, 'NULL') + ', 
				@ProductType=' + ISNULL( @ProductType, 'NULL') + ', 	
				@Customer=' + ISNULL( @Customer, 'NULL')

		EXEC ImportCatchError @addinfo = @addInfo	
		
	END CATCH