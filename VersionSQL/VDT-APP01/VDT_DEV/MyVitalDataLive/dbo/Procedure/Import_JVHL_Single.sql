/****** Object:  Procedure [dbo].[Import_JVHL_Single]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 9/17/2010
-- Description:	Import single JVHL record
-- =============================================
CREATE PROCEDURE [dbo].[Import_JVHL_Single] 
	@RecordID int,						
	@JVHLClaimNumber varchar(50),
	@DateOfService varchar(20),
	@ContractNumber varchar(50),
	@PatientLastName varchar(60),
	@PatientFirstName varchar(50),
	@Gender varchar(10),
	@DOB varchar(20),
	@OrderingPhysicianID varchar(50),
	@OrderingPhysicianFirstName varchar(50),
	@OrderingPhysicianLastName varchar(50),
	@BilledCPT varchar(20),
	@ResultCPT varchar(20),
	@DiagCode1 varchar(10),
	@DiagCode2 varchar(10),
	@DiagCode3 varchar(10),
	@DiagCode4 varchar(10),
	@TestName varchar(100),
	@TestResult varchar(max),
	@Units varchar(60),
	@ResultInterpretationFlag varchar(50),
	@ReferenceLow varchar(60),
	@ReferenceHigh varchar(60),
	@ReferenceAlpha varchar(max),
	@PayorClaimNumber varchar(50),
	@LOINC_Code varchar(20),
	@ResultType varchar(10),
	@QuantityBilled varchar(10),
	@ProviderName varchar(50),
	@ProviderID varchar(50),
	@ResultNote varchar(max),
	@ImportResult int out			-- 0 - success, -1 - failure or unknown item found, -2 - item listed on "ignore list"
AS
BEGIN
	SET NOCOUNT ON;

	declare @orderName varchar(200), @resultName varchar(200), 
		@sourceName varchar(50), @extraNote varchar(max)

	set @sourceName = 'JVHL'

--select * from dbo.Link_MemberId_MVD_Ins

	select @ImportResult = -1
/*
	select 
		@RecordID = '82463',						
		@JVHLClaimNumber = 'ME-33262076',
		@DateOfService = '20100105',
		@ContractNumber = '008888888801',
		@PatientLastName = 'GEIB',
		@PatientFirstName = 'KEITH',
		@Gender = 't',
		@DOB = '19590317',
		@OrderingPhysicianID = '1780691402',
		@OrderingPhysicianFirstName = 'RENAE',
		@OrderingPhysicianLastName = 'CARTER',
		@BilledCPT = '80061',
		@ResultCPT = '13457-7',
		@DiagCode1 = '2724',
		@DiagCode2 = '3784',
		@DiagCode3 = '',
		@DiagCode4 = '',
		@TestName = 'CHOLESTEROL, LDL (CALCULATED)',
		@TestResult = 'Number of Slides:   1    Source:   Uterine Cervix  Clinical History:   Last menstrual period (08/20/2010)  HPV any interpretation   AddPhysician  **********Addendum **********  CYTOLOGY NUMBER  ROC-10-44679  SPECIMEN ADEQUACY:  Satisfactory for evaluation: endocervical/transformation zone component present  DIAGNOSIS:  Uterine Cervix (Thin Layer Liquid-based Preparation)  NEGATIVE FOR INTRAEPITHELIAL LESION AND MALIGNANCY  BENIGN INFLAMMATORY CHANGES  NOTE:  ---HPV testing to follow---  AUTOMATED SCREENING:  This specimen was screened by the FDA approved ThinPrep Imaging System and  manually reviewed.  ###Additional Report Data###  ReportTitle: CYTOPATHOLOGY REPORT  DateReceived: 9/15/2010  PI:  TL: William Beaumont Hospital - 3601 W. Thirteen Mile Road - ROYAL OAK, MI 48073  Antonina Griffin  Cytotechnologist  Electronically signed 09/16/2010  I have reviewed all slides and the report.  Christopher K Hysell M.D.  Pathologist  Electronically signed 09/17/2010  HPV TESTING:  REASON FOR ADDENDUM: To include results of HPV testing  High Risk Group:  NEGATIVE  Test Method:  HPV DNA Hybrid Capture II  Note:  This test detects the presence of Human Papillomavirus (HPV) types 16,  18, 31, 33, 35, 39, 45, 51, 52, 56, 58, 59, and 68 usually associated with a  high/intermediate risk for development or progression of invasive cancer of the  cervix.  Negative assay results do not rule out the presence of HPV. Low levels of  infection or sampling error may cause a false negative result. Results of this  test should be interpreted only in conjunction with information available from  clinical evaluation of the patient and from other procedures. Additional  testing is recommended in any circumstance when false positive or false  negative results could lead to adverse medical, social or psychological  consequences.  This test is FDA approved for diagnostic purposes.  Molecular Pathology Number  10-13495  Jacob Lonteen  Medical Technologist  Electronically signed 09/17/2010',
		@Units = 'NA',
		@ResultInterpretationFlag = 'N',
		@ReferenceLow = '0',
		@ReferenceHigh = '100',
		@ReferenceAlpha = 'NA',
		@PayorClaimNumber = '12146497',
		@LOINC_Code = '13457-7',
		@ResultType = '1',
		@QuantityBilled = '1',
		@ProviderName = 'MEMORIAL HEALTHCARE CTR.',
		@ProviderID = '401557687',
		@ResultNote = 'F'
*/
	declare @mvdid varchar(20),
		@parentOrderID int,
		-- provider info from LookupNPI table
		@TempUpdatedByNPI varchar(20),
		@TempProvOrgName varchar(50),
		@TempProvLastName varchar(50),
		@TempProvFirstName varchar(50),
		@TempProvCredentials varchar(50),	-- prefix in the individual's name
		@TempProvPhone varchar(50),
		@TempProvType int					-- 1 - individual, 2 - organization


	declare @tempProv table 
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

	set @parentOrderID = -1

	select @mvdid = mvdid 
	from dbo.Link_MemberId_MVD_Ins
	where insmemberID = dbo.RemoveLeadChars(@ContractNumber,'0')

	--select @mvdid as '@mvdid'

	BEGIN TRY
		if(isnull(@mvdid,'') <> '')
		begin
			select @orderName = left(Description1,200) 
			from LookupCPT 
			where Code = @BilledCPT

			if(isnull(@orderName,'') <> '')
			begin

				-- Retrieved provider info if it could be located in lookup NPI table
				insert into @tempProv (npi, type, organizationName, lastName, firstName, credentials, 
						address1, address2,city, state, zip, Phone, Fax)
				exec Get_ProviderByID @ID = @OrderingPhysicianID, @Name = NULL

				if exists (select top 1 organizationName from @tempProv)
				begin
					SELECT	TOP 1
						@TempProvOrgName = organizationName,
						@TempProvLastName = lastName,
						@TempProvFirstName = firstName,
						@TempProvCredentials = credentials,
						@TempProvPhone = Phone,
						@TempProvType = type
					FROM	@tempProv
				end
				else
				begin
					select @TempProvLastName = @OrderingPhysicianLastName,
						@TempProvFirstName = @OrderingPhysicianFirstName
				end
				
				
				select top 1 @parentOrderID = OrderID from mainLabRequest 
				where ICENUMBER = @mvdid and ordercode = @BilledCPT and OrderCodingSystem = 'CPT' 
					and requestDate = @DateOfService and updatedByNPI = @OrderingPhysicianID 
					and sourceName = @sourceName
				
				-- REQUEST
				if @parentOrderID = -1
				begin
					INSERT INTO MainLabRequest
					   (ICENUMBER
					   ,OrderID
					   ,OrderName
					   ,OrderCode
					   ,OrderCodingSystem
					   ,RequestDate
					   ,OrderingPhysicianFirstName
					   ,OrderingPhysicianLastName
					   ,OrderingPhysicianID

					   ,ProcedureName
					   ,ProcedureCode
					   ,ProcedureCodingSystem

					   ,CreatedBy
					   ,CreatedByOrganization
					   ,UpdatedBy
					   ,UpdatedByOrganization
					   ,UpdatedByContact
					   ,CreatedByNPI
					   ,UpdatedByNPI
					   ,SourceName)
					VALUES
						(@mvdid,
						@RecordID,
						@OrderName,
						@BilledCPT,
						'CPT',
						@DateOfService,
						@OrderingPhysicianFirstName,
						@OrderingPhysicianLastName,
						@OrderingPhysicianID,
						'',
						'',
						'',

						isnull(@TempProvFirstName,'') + isnull(' ' + @TempProvLastName,''),
						@ProviderName,
						isnull(@TempProvFirstName,'') + isnull(' ' + @TempProvLastName,''),
						@ProviderName,
						@TempProvPhone,
						@OrderingPhysicianID,
						@OrderingPhysicianID,
						@sourceName)
						
					set @parentOrderID = @RecordID
				end

				-- RESULT
				if not exists (select top 1 recordnumber from mainLabResult
					where ICENUMBER = @mvdid and code = @LOINC_Code and CodingSystem = 'L' and ReportedDate = @DateOfService
						and updatedByNPI = @OrderingPhysicianID and sourceName = @sourceName)
				begin

					select @resultName = left(Component,200) 
					from dbo.LookupLOINC 
					where LOINC_NUM = @LOINC_Code

					if(len(@TestResult) > 20)
					begin
						set @extraNote = @TestResult
						set @TestResult = 'See notes'
					end
						
					if(isnull(@resultName,'') <> '')
					begin
						INSERT INTO MainLabResult
						   (ICENUMBER
						   ,OrderID
						   ,ResultID
						   ,ResultName
						   ,Code
						   ,CodingSystem

						   ,ResultValue
						   ,ResultUnits
						   ,RangeLow
						   ,RangeHigh
						   ,RangeAlpha
						   ,AbnormalFlag
						   ,ReportedDate

						   ,CreatedBy
						   ,CreatedByOrganization
						   ,UpdatedBy
						   ,UpdatedByOrganization
						   ,UpdatedByContact
						   ,CreatedByNPI
						   ,UpdatedByNPI
						   ,SourceName)
						VALUES
							(@mvdid,
							@parentOrderID,
							@RecordID,
							@ResultName,
							@LOINC_Code,
							'L',

							@TestResult,
							@Units,
							@ReferenceLow,
							@ReferenceHigh,
							left(@ReferenceAlpha,50),

							'',

							@DateOfService,

							isnull(@TempProvFirstName,'') + isnull(' ' + @TempProvLastName,''),
							@ProviderName,
							isnull(@TempProvFirstName,'') + isnull(' ' + @TempProvLastName,''),
							@ProviderName,
							@TempProvPhone,
							@OrderingPhysicianID,
							@OrderingPhysicianID,
							@sourceName)
					end
				end

				-- EXTRA NOTE: Created as result of very long result value
				if not exists (select recordNumber from MainLabNote where icenumber = @mvdid 
					and resultID = @RecordID and note = @extraNote and sourceName = @sourceName) 
					AND isnull(@extraNote,'') <> ''
				begin
					INSERT INTO dbo.MainLabNote
					   (ICENUMBER
					   ,ResultID
					   ,Note
					   ,CreatedBy
					   ,CreatedByOrganization
					   ,UpdatedBy
					   ,UpdatedByOrganization
					   ,UpdatedByContact
					   ,CreatedByNPI
					   ,UpdatedByNPI
					   ,SourceName)
					VALUES
						(@mvdid,
						@RecordID,
						@extraNote,
						isnull(@TempProvFirstName,'') + isnull(' ' + @TempProvLastName,''),
						@ProviderName,
						isnull(@TempProvFirstName,'') + isnull(' ' + @TempProvLastName,''),
						@ProviderName,
						@TempProvPhone,
						@OrderingPhysicianID,
						@OrderingPhysicianID,
						@SourceName)
				end			

				-- NOTE
				if not exists (select recordNumber from MainLabNote where icenumber = @mvdid 
					and resultID = @RecordID and note = @ResultNote and sourceName = @sourceName) 
					AND @ResultNote <> ''
				begin
					INSERT INTO dbo.MainLabNote
					   (ICENUMBER
					   ,ResultID
					   ,Note
					   ,CreatedBy
					   ,CreatedByOrganization
					   ,UpdatedBy
					   ,UpdatedByOrganization
					   ,UpdatedByContact
					   ,CreatedByNPI
					   ,UpdatedByNPI
					   ,SourceName)
					VALUES
						(@mvdid,
						@RecordID,
						@ResultNote,
						isnull(@TempProvFirstName,'') + isnull(' ' + @TempProvLastName,''),
						@ProviderName,
						isnull(@TempProvFirstName,'') + isnull(' ' + @TempProvLastName,''),
						@ProviderName,
						@TempProvPhone,
						@OrderingPhysicianID,
						@OrderingPhysicianID,
						@SourceName)
				end

				set @ImportResult = 0

				declare @itr int, @tempDiagCode varchar(20)
				set @itr = 0

				-- DIAGNOSIS	
				while (@ImportResult = 0 AND @itr < 4)
				begin
					select @tempDiagCode = 
						case @itr
							when 0 then @DiagCode1
							when 1 then @DiagCode2
							when 2 then @DiagCode3
							when 3 then @DiagCode4
						end
		
					if(isnull(@tempDiagCode,'') <> '')
					begin				
						-- Use HL7 import since it uses same import logic
						EXEC Import_HL7_DG1_Diagnosis_Single
							@recordId = @recordId,
							@InsPolicyNumber = @ContractNumber,
							@MSH_ID = @recordId,
							@LabDataProviderName = @sourceName,
							@LabDataProviderID = NULL,
							@DiagReportDate = @DateOfService,
							@DG1_1_SetID = '',
							@DG1_2_DiagnosisCodingMethod = '',
							@DG1_3_DiagnosisCode_Identifier = @tempDiagCode,
							@DG1_3_Text = '',
							@DG1_3_CodingSystem = '',
							@DG1_3_AlternateIdentifier = '',
							@DG1_3_AlternateText = '',
							@DG1_3_AlternateCodingSystem = '',
							@OrderingPhysicianID = @OrderingPhysicianID,
							@OrderingPhysicianFirstname = @OrderingPhysicianFirstname,
							@OrderingPhysicianLastname = @OrderingPhysicianLastname,
							@OrderingOrganization = @ProviderName,
							@ImportResult = @ImportResult output
					end

					select @itr = @itr + 1
				end
			end
		end
		else
		begin
			set @ImportResult = -1
		end
	END TRY
	BEGIN CATCH
		DECLARE @addInfo nvarchar(MAX)
		SELECT	@ImportResult = -1,
				@addInfo = 
					'RecordId=' + CAST(@RecordId AS VARCHAR(16)) + ', @JVHLClaimNumber=' + ISNULL(@JVHLClaimNumber, 'NULL') + ', @DateOfService=' + ISNULL(@DateOfService, 'NULL') + 
					', @ContractNumber=' + ISNULL(@ContractNumber, 'NULL') + ', @PatientLastName=' + ISNULL(@PatientLastName, 'NULL') + ', @PatientFirstName=' + ISNULL(@PatientFirstName, 'NULL') + 
					', @Gender=' + ISNULL(@Gender, 'NULL') + ', @DOB=' + ISNULL(@DOB, 'NULL') + ', @OrderingPhysicianID=' + ISNULL(@OrderingPhysicianID, 'NULL') + 
					', @OrderingPhysicianFirstName=' + ISNULL(@OrderingPhysicianFirstName, 'NULL') + ', @OrderingPhysicianLastName=' + ISNULL(@OrderingPhysicianLastName, 'NULL') + ', @BilledCPT=' + ISNULL(@BilledCPT, 'NULL') + 
					', @ResultCPT=' + ISNULL(@ResultCPT, 'NULL') + ', @DiagCode1=' + ISNULL(@DiagCode1, 'NULL') + ', @DiagCode2=' + ISNULL(@DiagCode2, 'NULL') + ', @DiagCode3=' + ISNULL(@DiagCode3, 'NULL') + ', @DiagCode4=' + ISNULL(@DiagCode4, 'NULL') + 
					', @TestName=' + ISNULL(@TestName, 'NULL') + ', @TestResult=' + ISNULL(@TestResult, 'NULL') + ', @Units=' + ISNULL(@Units, 'NULL') + 
					', @ResultInterpretationFlag=' + ISNULL(@ResultInterpretationFlag, 'NULL') + ', @ReferenceLow=' + ISNULL(@ReferenceLow, 'NULL') + ', @ReferenceHigh=' + ISNULL(@ReferenceHigh, 'NULL') + ', @ReferenceAlpha=' + ISNULL(@ReferenceAlpha, 'NULL') +
					', @PayorClaimNumber=' + ISNULL(@PayorClaimNumber, 'NULL') + ', @LOINC_Code=' + ISNULL(@LOINC_Code, 'NULL') + ', @ResultType=' + ISNULL(@ResultType, 'NULL') + ', @QuantityBilled=' + ISNULL(@QuantityBilled, 'NULL') + ', @ProviderName=' + ISNULL(@ProviderName, 'NULL') + ', @ProviderID=' + ISNULL(@ProviderID, 'NULL') + ', @ResultNote=' + ISNULL(@ResultNote, 'NULL')

		EXEC ImportCatchError @addInfo
	END CATCH

--select @ImportResult as '@ImportResult'
END