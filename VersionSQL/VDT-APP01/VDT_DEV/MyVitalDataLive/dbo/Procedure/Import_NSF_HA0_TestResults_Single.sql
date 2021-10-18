/****** Object:  Procedure [dbo].[Import_NSF_HA0_TestResults_Single]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 11/24/2010
-- Description:	Import single Labcorp lab data record
-- =============================================
CREATE PROCEDURE [dbo].[Import_NSF_HA0_TestResults_Single] 
	@RecordID int,						
	@DateOfService varchar(20),
	@InsMemberID varchar(50),
	@Cust_ID int,
	@OrderingPhysicianID varchar(50),
	@OrderingPhysicianFirstName varchar(50),
	@OrderingPhysicianLastName varchar(50),
	@AA0_ID int,
	@HA0_SegmentType nchar(3),
	@HA0_1_SequenceNo nchar(2),
	@HA0_2_PatControlNo nchar(17),
	@HA0_3_LineItemControlNo nchar(17),
	@HA0_4_TestNumber nchar(6),
	@HA0_5_TestName nchar(30),
	@HA0_6_LOINCCode nchar(7),
	@HA0_7_SMCCPTCODE nchar(10),
	@HA0_8_NormalsDecimalLow numeric(15, 4),
	@HA0_9_NormalsDecimalHigh numeric(15, 4),
	@HA0_10_Result nchar(12),
	@HA0_11_ResultAbnormalCode nchar(1),
	@HA0_12_Abbreviation_Result_NoteComment nchar(75),
	@HA0_13_AbbreviationExpansionIndicator nchar(1),
	@HA0_14_ResultCommentIndicator nchar(1),
	@HA0_15_NotesExpansionIndicator nchar(1),
	@HA0_16_Abbreviation_Comment_NotesSequence_Number int,
	@HA0_17_Filler nchar(109),
	@ProviderName varchar(50),
	@SourceName varchar(50),
	@ImportResult int out			-- 0 - success, -1 - failure or unknown item found, -2 - item listed on "ignore list"
AS
BEGIN
	SET NOCOUNT ON;

	declare @orderName varchar(200), @resultName varchar(200), @OrderCodingSystem varchar(50)

	select @OrderCodingSystem = 'L'		-- LOINC

	select @ImportResult = -1


/*
	select 
		@RecordID = 53876,
		@InsMemberID = '00388964               ',
		@Cust_ID = 5,
		@OrderingPhysicianID = '1427018571',
		@OrderingPhysicianFirstName = 'PRESTON',
		@OrderingPhysicianLastName = 'HTHOMAS',
		@DateOfService = '20100602',
		@AA0_ID = 88,
		@HA0_SegmentType ='HA0',
		@HA0_1_SequenceNo =20,
		@HA0_2_PatControlNo = '015308741090     ',
		@HA0_3_LineItemControlNo = '',
		@HA0_4_TestNumber = '015180',
		@HA0_5_TestName = 'Hematology Comments:',
		@HA0_6_LOINCCode = '18314-5',
		@HA0_7_SMCCPTCODE = '',
		@HA0_8_NormalsDecimalLow = '0.0000',
		@HA0_9_NormalsDecimalHigh = '0.0000',
		@HA0_10_Result = '22.000',
		@HA0_11_ResultAbnormalCode = 'L',
		@HA0_12_Abbreviation_Result_NoteComment ='',
		@HA0_13_AbbreviationExpansionIndicator = 'Y',
		@HA0_14_ResultCommentIndicator = 'N',
		@HA0_15_NotesExpansionIndicator = 'N',
		@HA0_16_Abbreviation_Comment_NotesSequence_Number = 1,
		@HA0_17_Filler = '',
		@SourceName = 'Labcorp'
*/

	declare @mvdid varchar(20),
		@parentOrderID int,
		@parentResultID int,
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

	select @parentOrderID = -1,
		@parentResultID = -1
	
	select @mvdid = mvdid 
	from dbo.Link_MemberId_MVD_Ins
	where insmemberID = dbo.RemoveLeadChars(@insmemberID,'0') and Cust_ID=@Cust_ID

	BEGIN TRY
		if(isnull(@mvdid,'') <> '')
		begin

			select @resultName = left(Component,200) 
			from dbo.LookupLOINC 
			where LOINC_NUM = @HA0_6_LOINCCode

			if(isnull(@resultName,'') = '')
			begin
				set @resultName = @HA0_5_TestName
			end

			select @orderName = @resultName 

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
						@TempProvFirstName = @OrderingPhysicianFirstName,
						@TempProvOrgName = @ProviderName
				end
				
				-- REQUEST
				
				select top 1 @parentOrderID = OrderID from mainLabRequest 
				where ICENUMBER = @mvdid and ordercode = @HA0_6_LOINCCode and OrderCodingSystem = @OrderCodingSystem 
						and requestDate = @DateOfService
						and updatedByNPI = @OrderingPhysicianID and sourceName = @sourceName
									
				--if not exists (select top 1 recordnumber from mainLabRequest 
				--	where ordercode = @HA0_6_LOINCCode and OrderCodingSystem = @OrderCodingSystem 
				--		and requestDate = @DateOfService
				--		and updatedByNPI = @OrderingPhysicianID and sourceName = @sourceName)
				
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
						@HA0_6_LOINCCode,
						@OrderCodingSystem,
						@DateOfService,
						@TempProvFirstName,
						@TempProvLastName,
						@OrderingPhysicianID,
						'',
						'',
						'',

						isnull(@TempProvFirstName,'') + isnull(' ' + @TempProvLastName,''),
						@TempProvOrgName,
						isnull(@TempProvFirstName,'') + isnull(' ' + @TempProvLastName,''),
						@TempProvOrgName,
						@TempProvPhone,
						@OrderingPhysicianID,
						@OrderingPhysicianID,
						@sourceName)
						
					set @parentOrderID = @RecordID						
				end

				select top 1 @parentResultID = ResultID 
				from mainLabResult
					where ICENUMBER = @mvdid and code = @HA0_6_LOINCCode and CodingSystem = @OrderCodingSystem 
						and ResultValue = @HA0_10_Result
						and ReportedDate = @DateOfService
						and updatedByNPI = @OrderingPhysicianID and sourceName = @sourceName

				-- RESULT
				if @parentResultID = -1
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
						@HA0_6_LOINCCode,
						@OrderCodingSystem,

						@HA0_10_Result,
						'',
						@HA0_8_NormalsDecimalLow,
						@HA0_9_NormalsDecimalHigh,
						'',

						@HA0_11_ResultAbnormalCode,

						@DateOfService,

						isnull(@TempProvFirstName,'') + isnull(' ' + @TempProvLastName,''),
						@TempProvOrgName,
						isnull(@TempProvFirstName,'') + isnull(' ' + @TempProvLastName,''),
						@TempProvOrgName,
						@TempProvPhone,
						@OrderingPhysicianID,
						@OrderingPhysicianID,
						@sourceName)
						
					set @parentResultID = @RecordID	
				end


				-- NOTE
				if @HA0_12_Abbreviation_Result_NoteComment <> '' 
					AND not exists (select recordNumber from MainLabNote where icenumber = @mvdid 
						and resultID = @parentResultID and note = @HA0_12_Abbreviation_Result_NoteComment and sourceName = @sourceName
						AND SequenceNum = @HA0_16_Abbreviation_Comment_NotesSequence_Number) 					 
				begin
					INSERT INTO dbo.MainLabNote
					   (ICENUMBER
					   ,ResultID
					   ,Note
					   ,SequenceNum
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
						@parentResultID,
						@HA0_12_Abbreviation_Result_NoteComment,
						@HA0_16_Abbreviation_Comment_NotesSequence_Number,
						isnull(@TempProvFirstName,'') + isnull(' ' + @TempProvLastName,''),
						@TempProvOrgName,
						isnull(@TempProvFirstName,'') + isnull(' ' + @TempProvLastName,''),
						@TempProvOrgName,
						@TempProvPhone,
						@OrderingPhysicianID,
						@OrderingPhysicianID,
						@SourceName)
				end

				set @ImportResult = 0
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
					'RecordId=' + CAST(@RecordId AS VARCHAR(16)) + ', @DateOfService=' + ISNULL(@DateOfService, 'NULL') + ', @AA0_ID=' + CAST(ISNULL(@AA0_ID , 'NULL') AS VARCHAR(16)) + 
					', @HA0_SegmentType=' + ISNULL(@HA0_SegmentType, 'NULL') + ', @HA0_1_SequenceNo=' + ISNULL(@HA0_1_SequenceNo, 'NULL') + 
					', @HA0_2_PatControlNo=' + ISNULL(@HA0_2_PatControlNo, 'NULL') + ', @HA0_3_LineItemControlNo=' + ISNULL(@HA0_3_LineItemControlNo, 'NULL') + ', @OrderingPhysicianID=' + ISNULL(@OrderingPhysicianID, 'NULL') + 
					', @OrderingPhysicianFirstName=' + ISNULL(@OrderingPhysicianFirstName, 'NULL') + ', @OrderingPhysicianLastName=' + ISNULL(@OrderingPhysicianLastName, 'NULL') + ', @HA0_4_TestNumber=' + ISNULL(@HA0_4_TestNumber, 'NULL') + 
					', @HA0_5_TestName=' + ISNULL(@HA0_5_TestName, 'NULL') + ', @HA0_6_LOINCCode=' + ISNULL(@HA0_6_LOINCCode, 'NULL') + ', @HA0_7_SMCCPTCODE=' + ISNULL(@HA0_7_SMCCPTCODE, 'NULL') + ', @HA0_8_NormalsDecimalLow=' + CAST(ISNULL(@HA0_8_NormalsDecimalLow, 'NULL') AS VARCHAR(16)) + ', @HA0_9_NormalsDecimalHigh=' + CAST(ISNULL(@HA0_9_NormalsDecimalHigh, 'NULL') AS VARCHAR(16)) + 
					', @HA0_10_Result=' + ISNULL(@HA0_10_Result, 'NULL') + ', @HA0_11_ResultAbnormalCode=' + ISNULL(@HA0_11_ResultAbnormalCode, 'NULL') + ', @HA0_12_Abbreviation_Result_NoteComment=' + ISNULL(@HA0_12_Abbreviation_Result_NoteComment, 'NULL') + 
					', @HA0_16_Abbreviation_Comment_NotesSequence_Number=' + CAST(ISNULL(@HA0_16_Abbreviation_Comment_NotesSequence_Number, 'NULL') AS VARCHAR(16)) 

		EXEC ImportCatchError @addInfo
	END CATCH
END