/****** Object:  Procedure [dbo].[Import_HL7_DG1_Diagnosis_Single]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 6/24/2010
-- Description:	Import single HL7 diagnosis record
-- =============================================
CREATE PROCEDURE [dbo].[Import_HL7_DG1_Diagnosis_Single] 
	@RecordID int,						-- MVD generated ID
	@InsPolicyNumber varchar(50),		-- use as member identifier 
	@MSH_ID int,
	@LabDataProviderName varchar(50),
	@LabDataProviderID int,
	@DiagReportDate varchar(50),
	@DG1_1_SetID varchar(10),
	@DG1_2_DiagnosisCodingMethod varchar(50),
	@DG1_3_DiagnosisCode_Identifier varchar(50),
	@DG1_3_Text varchar(50),
	@DG1_3_CodingSystem varchar(50),
	@DG1_3_AlternateIdentifier varchar(50),
	@DG1_3_AlternateText varchar(50),
	@DG1_3_AlternateCodingSystem varchar(50),
	@OrderingPhysicianID varchar(50),
	@OrderingPhysicianFirstname varchar(50),
	@OrderingPhysicianLastname varchar(50),
	@OrderingOrganization varchar(50),
	@ImportResult int	out			-- 0 - success, -1 - failure or unknown item found, -2 - item listed on "ignore list"
AS
BEGIN
	SET NOCOUNT ON;

	declare @mvdid varchar(20),
		@Description varchar(400),
		@CodingSystem varchar(50),
		@Type varchar(50),
		@MVDUpdatedRecordId int,
		@ExistingConditionDate datetime,
		@Action char(1),
		@ReportDate datetime,

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

	set @ImportResult = -1

	if(isnull(@InsPolicyNumber,'') <> '')
	begin
		select @mvdid = mvdid 
		from dbo.Link_MemberId_MVD_Ins
		where insmemberID = dbo.RemoveLeadChars(@InsPolicyNumber,'0')

		if(isnull(@mvdid,'') <> '')
		begin			

			-- TODO: check what kind of check in case of same duplicate result
			-- e.g. result not found in lookup table

			IF ISNULL(@DG1_3_DiagnosisCode_Identifier,'') != ''
			begin
				EXEC dbo.Get_Diag_Description
					@OriginalCode = @DG1_3_DiagnosisCode_Identifier,
					@Description = @Description output,
					@CodingSystem = @CodingSystem output,
					@Type = @Type output

				IF ISNULL(@Description,'') != '' AND @Type = 'Diseases/Conditions'
				begin
					-- MVD support 50 characters for description
					set @Description = left(@Description,50)

					select @ReportDate = 
						case len(isnull(@DiagReportDate,''))				
							when 8 then convert(datetime, left(@DiagReportDate,4) + '/' + substring(@DiagReportDate,5,2) + '/' + substring(@DiagReportDate,7,2))
							else NULL 
						end
				
					-- Retrieved provider info if it could be located in lookup NPI table
					insert into @tempProv (npi, type, organizationName, lastName, firstName, credentials, 
							address1, address2,city, state, zip, Phone, Fax)
					exec Get_ProviderByID @ID = @OrderingPhysicianID, @Name = @OrderingPhysicianLastname

					SELECT	TOP 1
						--@TempProvOrgName = organizationName,
						--@TempProvLastName = lastName,
						--@TempProvFirstName = firstName,
						--@TempProvCredentials = credentials,
						@TempProvPhone = Phone
						--@TempProvType = type
					FROM	@tempProv

					-- Check if condition already exists on record
					SET @MVDUpdatedRecordId = NULL
					SELECT	TOP 1 @MVDUpdatedRecordId = RecordNumber, @ExistingConditionDate = ReportDate
					FROM	MainCondition
					WHERE ICENUMBER = @MVDId and OtherName = @Description
					IF @MVDUpdatedRecordId IS NULL
					begin
						insert into MainCondition (ICENUMBER, OtherName, Code, CodingSystem,
							ReportDate,
							CreationDate,CreatedBy,CreatedByOrganization,CreatedByNPI,UpdatedBy,UpdatedByOrganization,
							UpdatedByNPI,UpdatedByContact,LabDataRefID,LabDataSourceName)
						values(@MVDId, @Description, @DG1_3_DiagnosisCode_Identifier, @CodingSystem, 
							@ReportDate, 
							getutcdate(), @OrderingPhysicianFirstname + ' ' + @OrderingPhysicianLastname, @OrderingOrganization, @OrderingPhysicianID, @OrderingPhysicianFirstname + ' ' + @OrderingPhysicianLastname, @OrderingOrganization, 
							@OrderingPhysicianID, @TempProvPhone, @MSH_ID, @LabDataProviderName)

						select @Action = 'A', @MVDUpdatedRecordId = SCOPE_IDENTITY()
					end
					else
					begin
						-- Check if incoming record is newer than the existing one
						-- Get ID of updated record
						IF @ExistingConditionDate IS NULL OR (@ReportDate IS NOT NULL AND @ExistingConditionDate <= @ReportDate)
						begin
							-- Set UpdatedBy and Organization as the most recent data provider
							UPDATE	MainCondition
							SET		ReportDate  = @ReportDate,
									UpdatedBy = @OrderingPhysicianFirstname + ' ' + @OrderingPhysicianLastname,
									UpdatedByContact = @TempProvPhone, 
									UpdatedByOrganization = @OrderingOrganization,
									UpdatedByNPI = @OrderingPhysicianID,
									LabDataRefID = @MSH_ID,
									LabDataSourceName = @LabDataProviderName
							WHERE	RecordNumber = @MVDUpdatedRecordId
	 
							set @Action = 'U'
						end
						else
						begin
							select @Action = 'I'
						end		
					end

					set @ImportResult = 0
				end
			end
		end
	end
END