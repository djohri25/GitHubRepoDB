/****** Object:  Procedure [dbo].[Import_Claims_Diag_Tax]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		sw
-- Create date: 2/10/2009
-- Description:	Import diagnosis from Claims data
-- =============================================
CREATE PROCEDURE [dbo].[Import_Claims_Diag_Tax]
	@ClaimRecordID nvarchar(50),
	@HPAssignedRecordID varchar(50),
	@MVDId varchar(15),
	@DiagnosisCode varchar(50),
	@IsPrincipal bit,
	@ServDate varchar(50),
	@ServProvNPI varchar(100),
	@UpdatedBy varchar(250),
	@UpdatedByContact varchar(50),
	@Organization varchar(250),
	@Customer varchar(50) = 'Health Plan of Michigan',
	@RevCode varchar(20),
	@BillType varchar(4), 
	@POS varchar(5), 
	@DRGCode varchar(5),
	@DischargeStatus varchar(50),
	@AdmissionDate varchar(50),	
	@DischargeDate varchar(20),
	@Taxonomy varchar(50),
	@Result int output			-- 0 - success, -1 - failure
AS
BEGIN
	SET NOCOUNT ON;
	declare @Description varchar(400),
		@CodingSystem varchar(50),
		@Type varchar(50),
		@ExistingConditionDate datetime,
		-- History
		@Action char(1),
		@MVDUpdatedRecordId int

	set @Result = 0

	IF ISNULL(@DiagnosisCode,'') != ''
	begin
		BEGIN TRY
			EXEC dbo.Get_Diag_Description
				@OriginalCode = @DiagnosisCode,
				@Description = @Description output,
				@CodingSystem = @CodingSystem output,
				@Type = @Type output

			-- Import regardless if found in lookup or not
			--IF ISNULL(@Description,'') != '' AND @Type = 'Diseases/Conditions'
			begin
				-- MVD support 50 characters for description
				set @Description = left(@Description,50)

				-------------------- Check if condition already exists on record
				SET @MVDUpdatedRecordId = NULL
				SELECT	TOP 1 @MVDUpdatedRecordId = RecordNumber, @ExistingConditionDate = ReportDate
				FROM	MainCondition
				WHERE ICENUMBER = @MVDId and Code = @DiagnosisCode -- changed on 5/30/2014: OtherName = @Description
				
				IF @MVDUpdatedRecordId IS NULL
				begin
					insert into MainCondition (ICENUMBER, OtherName, Code, CodingSystem,ReportDate,CreationDate,CreatedBy,CreatedByOrganization,CreatedByNPI,UpdatedBy,UpdatedByOrganization,UpdatedByNPI,UpdatedByContact,RevCode,BillType,POS,DRGCode,DischargeStatus,AdmissionDate,DischargeDate,IsPrincipal)
					values(@MVDId, @Description, @DiagnosisCode, @CodingSystem, @ServDate, getutcdate(), @UpdatedBy, @Organization, @ServProvNPI, @UpdatedBy, @Organization, @ServProvNPI, @UpdatedByContact,@RevCode,@BillType,@POS,@DRGCode,@DischargeStatus,@AdmissionDate,@DischargeDate,@IsPrincipal)

					select @Action = 'A', @MVDUpdatedRecordId = SCOPE_IDENTITY()
				end
				else
				begin
					-- Check if incoming record is newer than the existing one
					-- Get ID of updated record
					IF @ExistingConditionDate IS NULL OR (@ServDate IS NOT NULL AND @ExistingConditionDate <= @ServDate)
					begin
						-- Set UpdatedBy and Organization as the most recent data provider
						UPDATE	MainCondition
						SET		ReportDate  = @ServDate,
								UpdatedBy = @UpdatedBy,
								UpdatedByContact = @UpdatedByContact, 
								UpdatedByOrganization = @Organization,
								UpdatedByNPI = @ServProvNPI,
								ModifyDate = GETUTCDATE(),
								RevCode = @RevCode,
								BillType = @BillType,
								POS = @POS,
								DRGCode = @DRGCode,
								DischargeStatus = @DischargeStatus,
								AdmissionDate = @AdmissionDate,
								DischargeDate = @DischargeDate
						WHERE	RecordNumber = @MVDUpdatedRecordId
 
						set @Action = 'U'
					end
					else
					begin
						select @Action = 'I'
					end		
				end

				delete MainConditionHistory
				WHERE ICENUMBER = @MVDId and Code = @DiagnosisCode and convert(date,ReportDate) = convert(date,@ServDate)

				insert into MainConditionHistory (ICENUMBER, OtherName, Code, CodingSystem,ReportDate,CreationDate,CreatedBy,CreatedByOrganization,CreatedByNPI,UpdatedBy,UpdatedByOrganization,UpdatedByNPI,UpdatedByContact,RevCode,BillType,POS,DRGCode,DischargeStatus,AdmissionDate,DischargeDate,IsPrincipal, Taxonomy)
				values(@MVDId, @Description, @DiagnosisCode, @CodingSystem, @ServDate, getutcdate(), @UpdatedBy, @Organization, @ServProvNPI, @UpdatedBy, @Organization, @ServProvNPI, @UpdatedByContact,@RevCode,@BillType,@POS,@DRGCode,@DischargeStatus,@AdmissionDate,@DischargeDate,@IsPrincipal,@Taxonomy)

				-- Keep the history of changes
				EXEC Import_SetHistoryLog
					@MVDID = @MVDId,
					@ImportRecordID = @ClaimRecordID,
					@HPAssignedID = @HPAssignedRecordID,
					@MVDRecordID = @MVDUpdatedRecordId,
					@Action = @Action,
					@RecordType = 'CONDITION',
					@Customer = @Customer,
					@SourceName = 'CLAIMS'
			end
			--else
			--begin
			--	EXEC dbo.ImportErrorUnknownItem
			--		@ClaimRecordID = @ClaimRecordID,
			--		@ItemCode = @DiagnosisCode,
			--		@ItemType = 'DIAGNOSIS',
			--		@MVDId = @MVDId
			--	set @Result = -1
			--end
		END TRY
		BEGIN CATCH
			DECLARE @addInfo nvarchar(MAX)	
					
			SELECT @Result = -1,
				@addInfo = 
				'@ClaimRecordID=' + CAST(@ClaimRecordID AS VARCHAR(16)) + 
				', @HPAssignedRecordID=' + ISNULL(@HPAssignedRecordID, 'NULL') + 
				', @MVDId=' + ISNULL(@MVDId, 'NULL') + 
				', @DiagnosisCode=' + ISNULL(@DiagnosisCode, 'NULL') + 
				', @IsPrincipal=' + ISNULL(convert(varchar,@IsPrincipal), 'NULL') + 
				', @ServDate=' + ISNULL(@ServDate, 'NULL') + 
				', @ServProvNPI=' + ISNULL(@ServProvNPI, 'NULL') + 
				', @UpdatedBy=' + ISNULL(@UpdatedBy, 'NULL') + 
				', @UpdatedByContact=' + ISNULL(@UpdatedByContact, 'NULL') + 
				', @Organization=' + ISNULL(@Organization, 'NULL') + 
				', @Customer=' + ISNULL(@Customer, 'NULL') + 
				', @RevCode=' + ISNULL(@RevCode, 'NULL') + 
				', @BillType=' + ISNULL(@BillType, 'NULL') +  
				', @POS=' + ISNULL(@POS, 'NULL') +  
				', @DRGCode=' + ISNULL(@DRGCode, 'NULL') + 
				', @DischargeStatus=' + ISNULL(@DischargeStatus, 'NULL') + 
				', @AdmissionDate=' + ISNULL(@AdmissionDate, 'NULL') + 	
				', @DischargeDate=' + ISNULL(@DischargeDate, 'NULL')
		
			EXEC ImportCatchError @addinfo = @addInfo	
		
		END CATCH
   end
END