/****** Object:  Procedure [dbo].[Import_Claims_Diagnoses_Tax]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		sw
-- Create date: 2/10/2009
-- Description:	Import diagnosis from Claims data
-- =============================================
Create PROCEDURE [dbo].[Import_Claims_Diagnoses_Tax]
	@RecordId int,
	@HPAssignedRecordID varchar(50),
	@MVDId varchar(15),
	@DiagCode1 varchar(50),
	@DiagCode2 varchar(50),
	@DiagCode3 varchar(50),
	@DiagCode4 varchar(50),
	@DiagCode5 varchar(50),
	@DiagCode6 varchar(50),
	@DiagCode7 varchar(50),
	@DiagCode8 varchar(50),
	@DiagCode9 varchar(50),
	@ServDate varchar(50),
	@ServProvNPI varchar(50),
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
	@Result int output
AS
BEGIN
	SET NOCOUNT ON;
	
	declare @ImportResult int			-- 0 - success, -1 - failure

	BEGIN TRY

		-- Diagnosis 1
		EXEC Import_Claims_Diag_Tax 
			@ClaimRecordID = @RecordId, @HPAssignedRecordID = @HPAssignedRecordID, 
			@MVDId = @MVDId, @DiagnosisCode = @DiagCode1, @isPrincipal = 1, @ServDate = @ServDate, @ServProvNPI = @ServProvNPI,
			@UpdatedBy = @UpdatedBy, @UpdatedByContact = @UpdatedByContact, @Organization = @Organization, 
			@Result = @ImportResult OUTPUT, @Customer = @Customer, @RevCode = @RevCode, @BillType = @BillType,
			@POS = @POS, @DRGCode = @DRGCode, @DischargeStatus = @DischargeStatus, @AdmissionDate = @AdmissionDate,
			@DischargeDate = @DischargeDate, @Taxonomy = @Taxonomy

		-- Diagnosis 2
		-- Check the status of the previous import before proceeding
		IF @ImportResult = 0 AND ISNULL(@DiagCode2,'') != ''
		begin			
			EXEC Import_Claims_Diag_Tax 
				@ClaimRecordID = @RecordId, @HPAssignedRecordID = @HPAssignedRecordID, 
				@MVDId = @MVDId, @DiagnosisCode = @DiagCode2, @isPrincipal = 0, @ServDate = @ServDate, @ServProvNPI = @ServProvNPI,
				@UpdatedBy = @UpdatedBy, @UpdatedByContact = @UpdatedByContact, @Organization = @Organization, 
				@Result = @ImportResult OUTPUT, @Customer = @Customer, @RevCode = @RevCode, @BillType = @BillType,
				@POS = @POS, @DRGCode = @DRGCode, @DischargeStatus = @DischargeStatus, @AdmissionDate = @AdmissionDate,
				@DischargeDate = @DischargeDate, @Taxonomy = @Taxonomy
		end

		-- Diagnosis 3
		IF @ImportResult = 0 AND ISNULL(@DiagCode3,'') != ''
		begin
			EXEC Import_Claims_Diag_Tax
				@ClaimRecordID = @RecordId, @HPAssignedRecordID = @HPAssignedRecordID, 
				@MVDId = @MVDId, @DiagnosisCode = @DiagCode3, @isPrincipal = 0, @ServDate = @ServDate, @ServProvNPI = @ServProvNPI,
				@UpdatedBy = @UpdatedBy, @UpdatedByContact = @UpdatedByContact, @Organization = @Organization, 
				@Result = @ImportResult OUTPUT, @Customer = @Customer, @RevCode = @RevCode, @BillType = @BillType,
				@POS = @POS, @DRGCode = @DRGCode, @DischargeStatus = @DischargeStatus, @AdmissionDate = @AdmissionDate,
				@DischargeDate = @DischargeDate, @Taxonomy = @Taxonomy
		end

		-- Diagnosis 4
		IF @ImportResult = 0 AND ISNULL(@DiagCode4,'') != ''
		begin
			EXEC Import_Claims_Diag_Tax 
				@ClaimRecordID = @RecordId, @HPAssignedRecordID = @HPAssignedRecordID, 
				@MVDId = @MVDId, @DiagnosisCode = @DiagCode4, @isPrincipal = 0, @ServDate = @ServDate, @ServProvNPI = @ServProvNPI,
				@UpdatedBy = @UpdatedBy, @UpdatedByContact = @UpdatedByContact, @Organization = @Organization, 
				@Result = @ImportResult OUTPUT, @Customer = @Customer, @RevCode = @RevCode, @BillType = @BillType,
				@POS = @POS, @DRGCode = @DRGCode, @DischargeStatus = @DischargeStatus, @AdmissionDate = @AdmissionDate,
				@DischargeDate = @DischargeDate, @Taxonomy = @Taxonomy
		end

		-- Diagnosis 5
		IF @ImportResult = 0 AND ISNULL(@DiagCode5,'') != ''
		begin
			EXEC Import_Claims_Diag_Tax 
				@ClaimRecordID = @RecordId, @HPAssignedRecordID = @HPAssignedRecordID, 
				@MVDId = @MVDId, @DiagnosisCode = @DiagCode5, @isPrincipal = 0, @ServDate = @ServDate, @ServProvNPI = @ServProvNPI,
				@UpdatedBy = @UpdatedBy, @UpdatedByContact = @UpdatedByContact, @Organization = @Organization, 
				@Result = @ImportResult OUTPUT, @Customer = @Customer, @RevCode = @RevCode, @BillType = @BillType,
				@POS = @POS, @DRGCode = @DRGCode, @DischargeStatus = @DischargeStatus, @AdmissionDate = @AdmissionDate,
				@DischargeDate = @DischargeDate, @Taxonomy = @Taxonomy
		end

		-- Diagnosis 6
		IF @ImportResult = 0 AND ISNULL(@DiagCode6,'') != ''
		begin
			EXEC Import_Claims_Diag_Tax 
				@ClaimRecordID = @RecordId, @HPAssignedRecordID = @HPAssignedRecordID, 
				@MVDId = @MVDId, @DiagnosisCode = @DiagCode6, @isPrincipal = 0, @ServDate = @ServDate, @ServProvNPI = @ServProvNPI,
				@UpdatedBy = @UpdatedBy, @UpdatedByContact = @UpdatedByContact, @Organization = @Organization, 
				@Result = @ImportResult OUTPUT, @Customer = @Customer, @RevCode = @RevCode, @BillType = @BillType,
				@POS = @POS, @DRGCode = @DRGCode, @DischargeStatus = @DischargeStatus, @AdmissionDate = @AdmissionDate,
				@DischargeDate = @DischargeDate, @Taxonomy = @Taxonomy
		end

		-- Diagnosis 7
		IF @ImportResult = 0 AND ISNULL(@DiagCode7,'') != ''
		begin
			EXEC Import_Claims_Diag_Tax 
				@ClaimRecordID = @RecordId, @HPAssignedRecordID = @HPAssignedRecordID, 
				@MVDId = @MVDId, @DiagnosisCode = @DiagCode7, @isPrincipal = 0, @ServDate = @ServDate, @ServProvNPI = @ServProvNPI,
				@UpdatedBy = @UpdatedBy, @UpdatedByContact = @UpdatedByContact, @Organization = @Organization, 
				@Result = @ImportResult OUTPUT, @Customer = @Customer, @RevCode = @RevCode, @BillType = @BillType,
				@POS = @POS, @DRGCode = @DRGCode, @DischargeStatus = @DischargeStatus, @AdmissionDate = @AdmissionDate,
				@DischargeDate = @DischargeDate, @Taxonomy = @Taxonomy
		end

		-- Diagnosis 8
		IF @ImportResult = 0 AND ISNULL(@DiagCode8,'') != ''
		begin
			EXEC Import_Claims_Diag_Tax 
				@ClaimRecordID = @RecordId, @HPAssignedRecordID = @HPAssignedRecordID, 
				@MVDId = @MVDId, @DiagnosisCode = @DiagCode8, @isPrincipal = 0, @ServDate = @ServDate, @ServProvNPI = @ServProvNPI,
				@UpdatedBy = @UpdatedBy, @UpdatedByContact = @UpdatedByContact, @Organization = @Organization, 
				@Result = @ImportResult OUTPUT, @Customer = @Customer, @RevCode = @RevCode, @BillType = @BillType,
				@POS = @POS, @DRGCode = @DRGCode, @DischargeStatus = @DischargeStatus, @AdmissionDate = @AdmissionDate,
				@DischargeDate = @DischargeDate, @Taxonomy = @Taxonomy
		end

		-- Diagnosis 9
		IF @ImportResult = 0 AND ISNULL(@DiagCode9,'') != ''
		begin
			EXEC Import_Claims_Diag_Tax 
				@ClaimRecordID = @RecordId, @HPAssignedRecordID = @HPAssignedRecordID, 
				@MVDId = @MVDId, @DiagnosisCode = @DiagCode9, @isPrincipal = 0, @ServDate = @ServDate, @ServProvNPI = @ServProvNPI,
				@UpdatedBy = @UpdatedBy, @UpdatedByContact = @UpdatedByContact, @Organization = @Organization, 
				@Result = @ImportResult OUTPUT, @Customer = @Customer, @RevCode = @RevCode, @BillType = @BillType,
				@POS = @POS, @DRGCode = @DRGCode, @DischargeStatus = @DischargeStatus, @AdmissionDate = @AdmissionDate,
				@DischargeDate = @DischargeDate, @Taxonomy = @Taxonomy
		end

	END TRY
	BEGIN CATCH
		SELECT @ImportResult = -1

		EXEC ImportCatchError	
	END CATCH
   
	set @Result = @ImportResult
END