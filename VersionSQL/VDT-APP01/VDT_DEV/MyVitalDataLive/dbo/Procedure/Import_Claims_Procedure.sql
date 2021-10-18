/****** Object:  Procedure [dbo].[Import_Claims_Procedure]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		sw
-- Create date: 2/10/2009
-- Description:	Import Procedure from Claims data
-- =============================================
CREATE PROCEDURE [dbo].[Import_Claims_Procedure]
	@ClaimRecordId int,
	@HPAssignedRecordID varchar(50),
	@MVDId varchar(15),
	@ProcedureCode varchar(50),
	@ProcedureDate varchar(50),
	@ServProvNPI varchar(50),
	@UpdatedBy varchar(250),			-- Only set when Individual updates a record
	@UpdatedByContact varchar(50),		-- Common field for UpdatedBy and Organization
	@Organization varchar(250),
	@Customer varchar(50) = 'Health Plan of Michigan',
	@RevCode varchar(20),
	@BillType varchar(4), 
	@POS varchar(5), 
	@DRGCode varchar(5),	
	@DischargeStatus varchar(10),
	@AdmissionDate varchar(20),	
	@DischargeDate varchar(20),	
	@Taxonomy varchar(50),
	@Result int output
AS
BEGIN
	SET NOCOUNT ON;
	
	declare @ImportResult int,			-- 0 - success, -1 - failure
		@Description varchar(400),
		@Type varchar(50),
		@CodingSystem varchar(50),
		@ToUpdateProcDate datetime,		-- Procedure/Test date of the already existing item
		-- History
		@Action char(1),
		@MVDUpdatedRecordId int

	set @ImportResult = 0

	IF ISNULL(@ProcedureCode,'') != ''
	begin
		BEGIN TRY

			EXEC dbo.Get_Procedure_Description
				@OriginalCode = @ProcedureCode,
				@Description = @Description output,
				@Type = @Type output,
				@CodingSystem = @CodingSystem output

			-- Import if we find in lookup or not
			--IF ISNULL(@Description,'') != ''
			begin
				-- MVD support 150 characters for description
				set @Description = left(@Description,150)

				-- Check if procedure already exists on record
				SET @MVDUpdatedRecordId = NULL
				
				SELECT	TOP 1 @MVDUpdatedRecordId = RecordNumber,  @ToUpdateProcDate =  YearDate
				FROM	MainSurgeries
				WHERE	ICENUMBER = @MVDId AND Code = @ProcedureCode -- Treatment = @Description
				ORDER BY YearDate DESC
	
				
				IF @MVDUpdatedRecordId IS NULL
				begin				
					insert into mainSurgeries (ICENUMBER, YearDate, Treatment, Code, CodingSystem, CreationDate,ModifyDate,CreatedBy,CreatedByOrganization,CreatedByNPI,UpdatedBy,UpdatedByOrganization,UpdatedByNPI,UpdatedByContact,RevCode,BillType,POS,DRGCode,DischargeStatus,AdmissionDate,DischargeDate)
					values(@MVDId, @ProcedureDate, @Description, @ProcedureCode, @CodingSystem, getutcdate(),getutcdate(), @UpdatedBy,@Organization,@ServProvNPI, @UpdatedBy,@Organization,@ServProvNPI,@UpdatedByContact,@RevCode,@BillType,@POS,@DRGCode,@DischargeStatus,@AdmissionDate,@DischargeDate)

					select @Action = 'A', @MVDUpdatedRecordId = SCOPE_IDENTITY()
				end
				else
				begin
					-- Don't create procedure/test with same name
					-- Keep most recent procedure/test. 
					-- Update UpdatedBy and Organization as the most recent data provider


					if( convert(datetime, @ProcedureDate,112) >= convert(datetime, @ToUpdateProcDate,112))
					begin
						update mainSurgeries set YearDate = @ProcedureDate,UpdatedBy = @UpdatedBy, 
							UpdatedByContact = @UpdatedByContact, UpdatedByOrganization = @Organization, 
							UpdatedByNPI = @ServProvNPI, ModifyDate = getutcdate(), RevCode = @RevCode,
							BillType = @BillType, POS = @POS, DRGCode = @DRGCode, DischargeStatus = @DischargeStatus , AdmissionDate = @AdmissionDate, dischargeDate = @DischargeDate
						where RecordNumber = @MVDUpdatedRecordId
 
						select @Action = 'U'
					end
					else
					begin
						select @Action = 'I'	-- Ignore
					end
				end
 
				-- Check if the record is not reimported
				--IF NOT EXISTS(SELECT TOP 1 ImportRecordID FROM MainSurgeriesHistoryLive.dbo.MainSurgeriesHistory WHERE ImportRecordID = @ClaimRecordID)
				--IF @Action = 'A' OR @Action = 'U'
				begin

					delete MainSurgeriesHistoryLive.dbo.MainSurgeriesHistory
					WHERE ICENUMBER = @MVDId and Code = @ProcedureCode and convert(date,YearDate) = convert(date,@ProcedureDate)

					-- Create a history of procedures/tests performed				
					insert into MainSurgeriesHistoryLive.dbo.MainSurgeriesHistory
					(
						ICENUMBER
						,YearDate
						,Treatment
						,Code
						,CodingSystem
						,CreationDate
						,CreatedBy
						,CreatedByOrganization
						,CreatedByNPI
						,CreatedByContact
						,ImportRecordID
						,RevCode
						,BillType
						,POS
						,DRGCode
						,DischargeStatus
						,AdmissionDate
						,DischargeDate
						,Taxonomy
					)
					values
					(
						@MVDId, 
						@ProcedureDate, 
						@Description, 
						@ProcedureCode, 
						@CodingSystem,
						getutcdate(),
						@UpdatedBy,
						@Organization, 
						@ServProvNPI,
						@UpdatedByContact,
						@ClaimRecordID,
						@RevCode,
						@BillType,
						@POS,
						@DRGCode,
						@DischargeStatus
						,
						@AdmissionDate,
						@DischargeDate	
						,@Taxonomy					
					)			
				end

				-- Keep the history of changes
				EXEC Import_SetHistoryLog
					@MVDID = @MVDId,
					@ImportRecordID = @ClaimRecordID,
					@HPAssignedID = @HPAssignedRecordID,
					@MVDRecordID = @MVDUpdatedRecordId,
					@Action = @Action,
					@RecordType = 'PROCEDURE',
					@Customer = @Customer,
					@SourceName = 'CLAIMS'
			end
			--else
			--begin
			--	EXEC dbo.ImportErrorUnknownItem
			--		@ClaimRecordID = @ClaimRecordID,
			--		@ItemCode = @ProcedureCode,
			--		@ItemType = 'PROCEDURE',
			--		@MVDId = @MVDId
			--	set @ImportResult = -1
			--end			

		END TRY
		BEGIN CATCH
			SELECT @ImportResult = -1

		DECLARE @addInfo nvarchar(MAX)	
				
		SELECT @Result = -1,
			@addInfo = 
				'@ClaimRecordId=' + convert(varchar,@ClaimRecordId) + ', 
				@HPAssignedRecordID=' + ISNULL( @HPAssignedRecordID, 'NULL') + ', 
				@MVDId=' + ISNULL( @MVDId, 'NULL') + ', 
				@ProcedureCode =' + ISNULL( @ProcedureCode, 'NULL') + ', 
				@ProcedureDate =' + ISNULL( @ProcedureDate, 'NULL') + ', 
				@ServProvNPI =' + ISNULL( @ServProvNPI, 'NULL') + ', 
				@UpdatedBy=' + ISNULL( @UpdatedBy, 'NULL') + ', 
				@UpdatedByContact=' + ISNULL( @UpdatedByContact, 'NULL') + ', 
				@Organization=' + ISNULL( @Organization, 'NULL') + ', 
				@Customer=' + ISNULL( @Customer, 'NULL') + ', 
				@RevCode=' + ISNULL( @RevCode, 'NULL') + ', 
				@BillType=' + ISNULL( @BillType, 'NULL') + ',  
				@POS=' + ISNULL( @POS, 'NULL') + ',  
				@DRGCode=' + ISNULL( @DRGCode, 'NULL') + ', 	
				@DischargeStatus=' + ISNULL( @DischargeStatus, 'NULL') + ', 
				@AdmissionDate=' + ISNULL( @AdmissionDate, 'NULL') + ', 	
				@DischargeDate=' + ISNULL( @DischargeDate, 'NULL')

		EXEC ImportCatchError @addinfo = @addInfo	
		END CATCH
	end

	set @Result = @ImportResult
END