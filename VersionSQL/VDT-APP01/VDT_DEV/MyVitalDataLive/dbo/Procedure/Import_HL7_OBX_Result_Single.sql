/****** Object:  Procedure [dbo].[Import_HL7_OBX_Result_Single]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 6/24/2010
-- Description:	Import single HL7 Result record
-- =============================================
CREATE PROCEDURE [dbo].[Import_HL7_OBX_Result_Single] 
	@RecordID int,						-- MVD generated ID
	@InsPolicyNumber varchar(50),		-- use as member identifier 
	@MSH_ID int,
	@LabDataProviderName varchar(50),
	@LabDataProviderID int,
	@OBR_Ref_ID int,
	@OBX_1_SetID varchar(10),
	@OBX_2_ValueType varchar(50),
	@OBX_3_ObservationIdentifier varchar(50),
	@OBX_3_Text varchar(50),
	@OBX_3_CodingSystem varchar(50),
	@OBX_3_AlternateIdentifier varchar(50),
	@OBX_3_AlternateText varchar(50),
	@OBX_3_AlternateCodingSystem varchar(50),
	@OBX_4_ObservationSubID varchar(50),
	@OBX_5_ObservationValue varchar(50),
	@OBX_6_Units_Indentifier varchar(50),
	@OBX_6_Text varchar(50),
	@OBX_6_CodingSystem varchar(50),
	@OBX_6_AlternateIdentifier varchar(50),
	@OBX_6_AlternateText varchar(50),
	@OBX_6_AlternateCodingSystem varchar(50),
	@OBX_7_ReferencesRange varchar(60),
	@OBX_7_RangeLow varchar(50),
	@OBX_7_RangeHigh varchar(50),
	@OBX_7_RangeAlpha varchar(50),
	@OBX_8_AbnormalFlags varchar(50),
	@OBX_9_Probability varchar(50),
	@OBX_10_NatureOfAbnormalTest varchar(50),
	@OBX_11_ObservResultStatus char(1),
	@OBX_12_DateLastObsNormalValues varchar(50),
	@OBX_13_UserDefinedAccessChecks varchar(50),
	@OBX_14_ObservationDate varchar(50),
	@OBX_15_ProducerID varchar(50),
	@OBX_16_ResponsibleObserver varchar(50),
	@OBX_17_ObservationMethod varchar(50),
	@OrderingPhysicianID varchar(50),
	@OrderingPhysicianFirstname varchar(50),
	@OrderingPhysicianLastname varchar(50),
	@OrderingOrganization varchar(50),
	@ImportResult int	out			-- 0 - success, -1 - failure or unknown item found, -2 - item listed on "ignore list"
AS
BEGIN
	SET NOCOUNT ON;

	declare @mvdid varchar(20),
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

	if(isnull(@InsPolicyNumber,'') <> '')
	begin
		select @mvdid = mvdid 
		from dbo.Link_MemberId_MVD_Ins
		where insmemberID = dbo.RemoveLeadChars(@InsPolicyNumber,'0')

		if(isnull(@mvdid,'') <> '')
		begin			
			if( isnull(@OBX_3_ObservationIdentifier,'') <> '' AND isnull(@OBX_3_Text,'') = '')
			begin
				if(@OBX_3_CodingSystem = 'LOINC')
				begin
					select @OBX_3_Text = left(Component,200) 
					from dbo.LookupLOINC 
					where LOINC_NUM = @OBX_3_ObservationIdentifier
				end
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

			-- TODO: check what kind of check in case of same duplicate result
			-- e.g. result not found in lookup table

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
				@OBR_Ref_ID,
				@RecordID,
				@OBX_3_Text,
				@OBX_3_ObservationIdentifier,
				@OBX_3_CodingSystem,

				@OBX_5_ObservationValue,
				@OBX_6_Units_Indentifier,
				@OBX_7_RangeLow,
				@OBX_7_RangeHigh,
				@OBX_7_RangeAlpha,

				@OBX_8_AbnormalFlags,

				case len(isnull(@OBX_14_ObservationDate,''))				
					when 12 then convert(datetime, left(@OBX_14_ObservationDate,4) + '/' + substring(@OBX_14_ObservationDate,5,2) 
						+ '/' + substring(@OBX_14_ObservationDate,7,2) + ' ' 
						+ substring(@OBX_14_ObservationDate,9,2) + ':' + substring(@OBX_14_ObservationDate,11,2))
					else NULL 
				end,

				@OrderingPhysicianFirstname + ' ' + @OrderingPhysicianLastname,
				@OrderingOrganization,
				@OrderingPhysicianFirstname + ' ' + @OrderingPhysicianLastname,
				@OrderingOrganization,
				@TempProvPhone,
				@OrderingPhysicianID,
				@OrderingPhysicianID,
				@LabDataProviderName)

			set @ImportResult = 0
		end
		else
		begin
			set @ImportResult = -1
		end
	end
	else
	begin
		set @ImportResult = -1
	end
END