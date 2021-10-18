/****** Object:  Procedure [dbo].[Import_LabData_Single]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 3/14/2011
-- Description:	Import single Lab Data record
-- =============================================
CREATE PROCEDURE [dbo].[Import_LabData_Single] 
	@RecordID int,						
	@Member_ID varchar(50),
	@OrderDate varchar(50),
	@OrderingPhysicianID varchar(50),
	@OrderingPhysicianName varchar(50),
	@OrderName varchar(50),
	@OrderCode varchar(50),
	@OrderCodingSystem varchar(50),
	@TestDate varchar(50),
	@TestName varchar(50),
	@TestCode varchar(50),
	@TestResult varchar(50),
	@ResultUnit varchar(50),
	@ReferenceInterpretationFlag varchar(50),
	@ReferenceLow varchar(50),
	@ReferenceHigh varchar(50),
	@ResultNote varchar(max),
	@ProviderID varchar(50),
	@ProviderName varchar(50),
	@SourceName varchar(50),
	@Cust_ID int,
	@ImportResult int out			-- 0 - success, -1 - failure or unknown item found, -2 - item listed on "ignore list"
AS
BEGIN
	SET NOCOUNT ON;

	declare @extraNote varchar(max),@tempIndex tinyInt,
		@orderingPhysLName varchar(50), @orderingPhysFName varchar(50)


--select * from dbo.Link_MemberId_MVD_Ins

	select @ImportResult = -1
/*
	select 
		@RecordID = 236,						
		@Member_ID = '39056362',
		@OrderDate = '',
		@OrderingPhysicianID = '1457330029',
		@OrderingPhysicianName = 'NGUYEN,TUAN',
		@OrderName = 'CAT DANDER (E1) IGE',
		@OrderCode = '15609-1',
		@OrderCodingSystem = 'L',
		@TestDate = '11/26/2009',
		@TestName = 'VALPROIC ACID',
		@TestCode = '4086-5',
		@TestResult = '<0.35',
		@ResultUnit = 'kU/L',
		@ReferenceInterpretationFlag = '',
		@ReferenceLow = '0',
		@ReferenceHigh = '340000',
		@ResultNote = 'Sample test note 1',
		@ProviderID = '',
		@ProviderName = 'Quest',
		@Cust_ID  = 4
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
	where insmemberID = dbo.RemoveLeadChars(@Member_ID,'0')

	--select @mvdid as '@mvdid'

	if(ISNULL(@OrderCodingSystem,'') = '')
	begin
		set @OrderCodingSystem = 'L'
	end

	BEGIN TRY
		if(isnull(@mvdid,'') <> '')
		begin
			if(isnull(@OrderName,'') = '' AND isnull(@OrderCode,'') <> '')
			begin		
				select @orderName = left(Component,50) 
				from LookupLOINC 
				where LOINC_NUM = @OrderCode
			end

			if(isnull(@OrderName,'') = '' AND isnull(@TestCode,'') <> '')
			begin		
				select @orderName = left(Component,50),
					@OrderCode = @TestCode
				from LookupLOINC 
				where LOINC_NUM = @TestCode
			end
			
			if(isnull(@OrderName,'') = '')
			begin
				select @OrderName = @TestName, @OrderCode = @TestCode					
			end
			
			if(isnull(@OrderDate,'') = '')
			begin
				select @OrderDate = @TestDate					
			end
			
			if(isnull(@TestDate,'') = '')
			begin
				select @TestDate = @OrderDate				
			end
			
			if(isnull(@orderName,'') <> '')
			begin
				set @tempIndex = null
				set @tempIndex = charIndex(',',@OrderingPhysicianName)
				if(@tempIndex is not null AND @tempIndex <> 0)
				begin
					set @orderingPhysLName = ltrim(rtrim( left(@OrderingPhysicianName,@tempIndex - 1)))
					set @orderingPhysFName = ltrim(rtrim(substring (@OrderingPhysicianName,@tempIndex + 1,len(@OrderingPhysicianName) - @tempIndex)))
				end
			
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
					select @TempProvLastName = @orderingPhysLName,
						@TempProvFirstName = @orderingPhysFName
				end
				
				
				select top 1 @parentOrderID = OrderID 
				from mainLabRequest 
				where ICENUMBER = @mvdid and ordercode = @OrderCode and OrderCodingSystem = @OrderCodingSystem 
					and requestDate = @OrderDate and updatedByNPI = OrderingPhysicianID 
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
						@OrderCode,
						@OrderCodingSystem,
						@OrderDate,
						@orderingPhysFName,
						@OrderingPhysLName,
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
					where ICENUMBER = @mvdid and code = @TestCode and CodingSystem = @OrderCodingSystem and ReportedDate = @TestDate
						and sourceName = @sourceName)
				begin

					if(ISNULL(@testname,'') = '')
					begin
						select @testname = left(Component,50) 
						from dbo.LookupLOINC 
						where LOINC_NUM = @testcode
					end
					
					if(len(@TestResult) > 20)
					begin
						set @extraNote = @TestResult
						set @TestResult = 'See notes'
					end
						
					if(isnull(@testname,'') <> '')
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
							@TestName,
							@TestCode,
							@OrderCodingSystem,

							@TestResult,
							@resultUnit,
							@ReferenceLow,
							@ReferenceHigh,
							'',

							@ReferenceInterpretationFlag,

							@TestDate,

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
/*
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
*/				
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
					'RecordId=' + CAST(@RecordId AS VARCHAR(16)) + ', @Member_ID=' + ISNULL(@Member_ID, 'NULL') + ', @OrderDate=' + ISNULL(@OrderDate, 'NULL') + 
					', @OrderingPhysicianID=' + ISNULL(@OrderingPhysicianID, 'NULL') + ', @OrderingPhysicianName=' + ISNULL(@OrderingPhysicianName, 'NULL') +
					', @OrderName=' + ISNULL(@OrderName, 'NULL') + ', @OrderCode=' + ISNULL(@OrderCode, 'NULL') + ', @OrderCodingSystem=' + ISNULL(@OrderCodingSystem, 'NULL') + 
					', @TestDate=' + ISNULL(@TestDate, 'NULL') + ', @TestName=' + ISNULL(@TestName, 'NULL') + ', @TestCode=' + ISNULL(@TestCode, 'NULL') + 
					', @TestResult=' + ISNULL(@TestResult, 'NULL') + ', @ResultUnit=' + ISNULL(@ResultUnit, 'NULL') + ', @ReferenceInterpretationFlag=' + ISNULL(@ReferenceInterpretationFlag, 'NULL') + ', @ReferenceLow=' + ISNULL(@ReferenceLow, 'NULL') + ', @ReferenceHigh=' + ISNULL(@ReferenceHigh, 'NULL') + 
					', @ResultNote=' + ISNULL(@ResultNote, 'NULL') + ', @ProviderID=' + ISNULL(@ProviderID, 'NULL') + ', @ProviderName=' + ISNULL(@ProviderName, 'NULL') + 
					', @Cust_ID=' + ISNULL(CAST(@Cust_ID AS VARCHAR(16)), 'NULL') 

		EXEC ImportCatchError @addInfo
	END CATCH

--select @ImportResult as '@ImportResult'
END