/****** Object:  Procedure [dbo].[Import_RX_Medication]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		sw
-- Create date: 2/13/2009
-- Description:	Import Medications from RX input file
-- =============================================
CREATE PROCEDURE [dbo].[Import_RX_Medication]
	@RxRecordId int,
	@MVDId varchar(15),
	@RxControlNumber varchar(50),
	@PharmacyID nvarchar(50),
	@PharmacyName nvarchar(50),
	@PrescriberId nvarchar(50),
	@PrescriberLastName nvarchar(50),
	@PrescriberFirstName nvarchar(50),
	@DateFilled nvarchar(50),
	@NDC nvarchar(50),
	@DaysSupply nvarchar(50),
	@Quantity nvarchar(50),
	@ClaimStatus char(1),				-- X - reverse, P - add/update
	@UpdatedBy varchar(250),			-- Only set when Individual creates/updates a record
	@UpdatedByContact varchar(50),
	@UpdatedByNPI varchar(20),
	@Organization varchar(250),			
	@Customer varchar(50) = 'Health Plan of Michigan',
	@Result int output
AS
BEGIN
	SET NOCOUNT ON;
	
	declare @ImportResult int,			-- 0 - success, -1 - failure or unknown item, -2 - item listed on "ignore list"
		@MedicationName varchar(100),
		@CodingSystem varchar(50),
		@MedicationType char(1),
		@PrescribedByFull varchar(200),
		@MVDDrugId char(1),
		@Count int,
		@IsMedIgnored bit,
		-- History
		@MVDUpdatedRecordId int,		-- inserted or updated record ID
		@Action char(1)					-- A - add, U - update, D - delete


	set @ImportResult = 0

	create table #memberMedication (
		RecordNumber int,
		StartDate datetime,
		RefillDate datetime,
		PrescribedBy varchar(50),
		RxDrug varchar(100)
	) 

	declare @tempRecordNumber int,
		@tempStartDate datetime,
		@tempRefillDate datetime,
		@tempPrescribedBy varchar(50),
		@tempRxDrug varchar(100)

	IF ISNULL(@NDC,'') <> ''
	begin
		BEGIN TRY

			EXEC dbo.Get_Medication_Description
				@NDCCode = @NDC,
				@Description = @MedicationName output,
				@CodingSystem = @CodingSystem output,
				@MedType = @MedicationType output,
				@IgnoreFlag = @IsMedIgnored output

			IF ISNULL(@MedicationName,'') <> ''
			begin

				IF ISNULL(@PrescriberFirstName,'') = ''
				begin
					set @PrescribedByFull = isnull(@PrescriberLastName,'')
				end
				else
				begin
					set @PrescribedByFull = isnull(@PrescriberFirstName,'') + ' ' + isnull(@PrescriberLastName,'')
				end

				-- MVD mapping
				IF @MedicationType = 'O'
				begin
					-- Prescribed OTC
					set @MVDDrugId = 'O';
				end
				ELSE IF @MedicationType = 'R'
				begin
					-- Prescribed
					set @MVDDrugId = 'X';
				end

				IF @ClaimStatus = 'X'
				begin
					declare @tempImportRecordID int, @tempMedName varchar(150), @tempMedCount int

					-- Most likely the medication was already created as a result of previous import
					-- Find it and delete
				
					select @MVDUpdatedRecordId = RecordNumber
					from MainMedication
					where icenumber = @MVDId
						and (startdate = @DateFilled OR RefillDate = @DateFilled)
						and PrescribedBy = @PrescribedByFull
						and Code = @NDC
						and (RefillDate is null OR RefillDate <> startDate)

					IF ISNULL(@MVDUpdatedRecordId,'') <> ''
					begin					
						-- If the medication was updated at least once, don't delete						
						select @tempMedCount = count(recordNumber) 
						from MainMedicationHistory
						where Icenumber = @MVDId and Code = @NDC

						if(@tempMedCount = 1)
						begin
							delete from MainMedication where recordNumber = @MVDUpdatedRecordId
							-- Keep the history of changes
							EXEC Import_SetHistoryLog
								@MVDID = @MVDId,
								@ImportRecordID = @RxRecordId,
								@HPAssignedID = @RxControlNumber,
								@MVDRecordID = @MVDUpdatedRecordId,
								@Action = 'D',
								@RecordType = 'MEDICATION',
								@Customer = @Customer,
								@SourceName = 'RX'
						end

						-- Delete from medication history
						delete from MainMedicationHistory 
						where icenumber = @MVDId
							and filldate = @DateFilled
							and PrescribedBy = @PrescribedByFull
							and Code = @NDC

					end
					else
					begin
						-- In case it exists in medication history
						delete from MainMedicationHistory 
						where icenumber = @MVDId
							and filldate = @DateFilled
							and PrescribedBy = @PrescribedByFull
							and Code = @NDC
					end
				end
				else
				begin
					IF @IsMedIgnored = '1'
					begin
						-- Med was listed in ignore list so don't process it
						select @Action = 'I',
							@ImportResult = -2
					end
					else
					begin
						-- Get member's medications
						insert into #memberMedication (RecordNumber,StartDate,RefillDate,PrescribedBy,RxDrug)
						select RecordNumber,StartDate,RefillDate,PrescribedBy,RxDrug
						from MainMedication 
						where ICENUMBER = @MVDId and RxDrug = @MedicationName

						select @Count = count(recordNumber) from #memberMedication
						-- Set defualt action 
						set @Action = 'I'

						IF @Count = 0
						begin
							-- New
							insert into mainMedication (ICENUMBER, StartDate, PrescribedBy, DrugId, RxDrug, Code, CodingSystem, RxPharmacy,
								CreationDate,ModifyDate,CreatedBy,CreatedByNPI,CreatedByOrganization, UpdatedBy,UpdatedByNPI,UpdatedByOrganization,UpdatedByContact,DaysSupply)
							values(@MVDId, @DateFilled, @PrescribedByFull, @MVDDrugId, @MedicationName, @NDC, @CodingSystem, @PharmacyName, 
								getutcdate(),getutcdate(), @UpdatedBy, @UpdatedByNPI, @Organization, @UpdatedBy, @UpdatedByNPI,@Organization,@UpdatedByContact,@DaysSupply )

							select @Action = 'A', @MVDUpdatedRecordId = (SCOPE_IDENTITY()) 
						end
						ELSE IF @Count = 1
						begin
							select  @tempRecordNumber = RecordNumber,
								@tempStartDate = StartDate,
								@tempRefillDate = RefillDate,
								@tempPrescribedBy = PrescribedBy,
								@tempRxDrug = RxDrug
							from #memberMedication

							IF @tempRefillDate IS NULL
							begin
								-- Never refilled before
								IF @DateFilled < @tempStartDate
								begin
									-- Incoming fill date is older than start date
									-- Reverse those 2 fields, since we want to know when memeber started taking the med
									-- Prescriber stays the same, as the most recent. Same with record owner (updater)
									update MainMedication set StartDate = @DateFilled, RefillDate = @tempStartDate,
										ModifyDate = (getutcdate())
									where RecordNumber = @tempRecordNumber
						
									select @MVDUpdatedRecordId = @tempRecordNumber,
										@Action = 'U'
								end
								ELSE IF @DateFilled >= @tempStartDate
								begin
									-- First refill
									update MainMedication set RefillDate = @DateFilled, PrescribedBy = @PrescribedByFull, 
										UpdatedBy = @UpdatedBy, ModifyDate = (GETUTCDATE()), 
										UpdatedByOrganization = @Organization, 
										UpdatedByNPI = @UpdatedByNPI,
										UpdatedByContact = @UpdatedByContact 
									where RecordNumber = @tempRecordNumber

									select @MVDUpdatedRecordId = @tempRecordNumber,
										@Action = 'U'
								end
								else
								begin
									-- Same day refill, ignore
									set @Action = 'I'
								end
							end
							else
							begin	
								-- Med was refilled before
								-- Set owner/Updater whoever prescribed the med most recently
								IF @DateFilled < @tempStartDate
								begin
									update MainMedication set StartDate = @DateFilled, 
										ModifyDate = (GETUTCDATE())
									where RecordNumber = @tempRecordNumber

									select @MVDUpdatedRecordId = @tempRecordNumber,
										@Action = 'U'								
								end
								ELSE IF @tempStartDate <= @DateFilled AND @DateFilled < @tempRefillDate
								begin
									-- Between start and refill, ignore
									set @Action = 'I'
								end
								ELSE IF @tempRefillDate <= @DateFilled
								begin
									-- Newer refill
									update MainMedication set RefillDate = @DateFilled, PrescribedBy = @PrescribedByFull, 
										UpdatedBy = @UpdatedBy, UpdatedByNPI = @UpdatedByNPI,
										ModifyDate = (GETUTCDATE()), UpdatedByOrganization = @Organization, 
										UpdatedByContact = @UpdatedByContact 
									where RecordNumber = @tempRecordNumber

									select @MVDUpdatedRecordId = @tempRecordNumber,
										@Action = 'U'								
								end
							end
						end
						else
						begin
							-- Multiple matches, we cannot decide which one to update
							set @Action = 'I'
						end

						-- Create a history of medications prescribed to the patient
						IF NOT EXISTS(SELECT TOP 1 recordnumber FROM MainMedicationHistory 
							WHERE ICENUMBER = @MVDId AND FillDate = @DateFilled AND PrescribedBy = @PrescribedByFull
							 AND RxDrug = @MedicationName AND Code = @NDC)
						begin
							insert into MainMedicationHistory (
								ICENUMBER
								,FillDate
								,PrescribedBy
								,DrugId
								,RxDrug
								,Code
								,CodingSystem
								,RxPharmacy
								,CreationDate
								,ImportRecordID
								,CreatedBy
								,CreatedByNPI
								,CreatedByOrganization
								,CreatedByContact
								,DaysSupply
							)
							values
							(
								@MVDId,
								@DateFilled, 
								@PrescribedByFull, 
								@MVDDrugId, 
								@MedicationName,
								@NDC,
								@CodingSystem, 
								@PharmacyName,
								getutcdate(),
								@RxRecordId,
								@UpdatedBy,
								@UpdatedByNPI,
								@Organization,
								@UpdatedByContact,
								@DaysSupply
							)
						end
					end
															
					-- Keep the history of changes
					EXEC Import_SetHistoryLog
						@MVDID = @MVDId,
						@ImportRecordID = @RxRecordId,
						@HPAssignedID = @RxControlNumber,
						@MVDRecordID = @MVDUpdatedRecordId,
						@Action = @Action,
						@RecordType = 'MEDICATION',
						@Customer = @Customer,
						@SourceName = 'RX'
				end
			end
			else
			begin
				EXEC dbo.ImportErrorUnknownItem
					@ClaimRecordID = @RxRecordId,
					@ItemCode = @NDC,
					@ItemType = 'MEDICATION',
					@MVDId = @MVDId
				set @ImportResult = -1
			end			

		END TRY
		BEGIN CATCH
			SELECT @ImportResult = -1

			EXEC ImportCatchError	
		END CATCH
	end

	drop table #memberMedication

	set @Result = @ImportResult
END