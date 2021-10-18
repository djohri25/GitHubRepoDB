/****** Object:  Procedure [dbo].[Import_HL7_OBR_Request_Single]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 6/24/2010
-- Description:	Import single HL7 Request record
-- =============================================
CREATE PROCEDURE [dbo].[Import_HL7_OBR_Request_Single] 
	@RecordID int,						-- MVD generated ID	
	@InsPolicyNumber varchar(50),		-- use as member identifier 
	@MSH_ID int,
	@LabDataProviderName varchar(50),
	@LabDataProviderID int,
	@OBR_1_SetID varchar(10),
	@OBR_2_PlacerOrderNumber varchar(50),
	@OBR_3_FilterOrderNumber_ID varchar(10),
	@OBR_4_UniversalServiceID_Identifier varchar(50),
	@OBR_4_Text varchar(50),
	@OBR_4_CodingSystem varchar(50),
	@OBR_4_AlternateIdentifier varchar(50),
	@OBR_4_AlternateText varchar(50),
	@OBR_4_AlternateCodingSystem varchar(50),
	@OBR_7_ObservationDate varchar(50),
	@OBR_8_ObservationEndDate varchar(50),
	@OBR_16_OrderingPhysician_ID varchar(50),
	@OBR_16_FamilyName varchar(50),
	@OBR_16_GivenName varchar(50),
	@OBR_16_MiddleName varchar(50),
	@OBR_16_Degree varchar(20),
	@OBR_16_SourceTable varchar(50),
	@OBR_20_LabCode varchar(50),
	@OBR_44_ProcedureCode_Identifier varchar(50),
	@OBR_44_Text varchar(50),
	@OBR_44_CodingSystem varchar(50),
	@SourceName varchar(50),
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

	if(isnull(@InsPolicyNumber,'') <> '')
	begin

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

		select @mvdid = mvdid 
		from dbo.Link_MemberId_MVD_Ins
		where insmemberID = dbo.RemoveLeadChars(@InsPolicyNumber,'0')

		if(isnull(@mvdid,'') <> '')
		begin
			if( isnull(@OBR_44_ProcedureCode_Identifier,'') <> '' AND isnull(@OBR_44_Text,'') = '')
			begin
				if(@OBR_44_CodingSystem = 'CPT')
				begin
					select @OBR_44_Text = left(Description1,200) 
					from LookupCPT 
					where Code = @OBR_44_ProcedureCode_Identifier
				end
				else if(@OBR_44_CodingSystem = 'HCPCS')
				begin
					select @OBR_44_Text = left(RTRIM(AbbreviatedDescription),200) 
					from LookupHCPCS 
					where Code = @OBR_44_ProcedureCode_Identifier
				end
	
			end

			-- Retrieved provider info if it could be located in lookup NPI table
			insert into @tempProv (npi, type, organizationName, lastName, firstName, credentials, 
					address1, address2,city, state, zip, Phone, Fax)
			exec Get_ProviderByID @ID = @OBR_16_OrderingPhysician_ID, @Name = @OBR_16_FamilyName

			SELECT	TOP 1
				@TempProvOrgName = organizationName,
				@TempProvLastName = lastName,
				@TempProvFirstName = firstName,
				@TempProvCredentials = credentials,
				@TempProvPhone = Phone,
				@TempProvType = type
			FROM	@tempProv

			-- TODO: check what kind of check in case of same duplicate requests
			

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
				@OBR_4_Text,
				@OBR_4_UniversalServiceID_Identifier,
				@OBR_4_CodingSystem,
				case len(isnull(@OBR_7_ObservationDate,''))				
					when 8 then convert(datetime, left(@OBR_7_ObservationDate,4) + '/' + substring(@OBR_7_ObservationDate,5,2) + '/' + substring(@OBR_7_ObservationDate,7,2))
					else NULL 
				end,
				@OBR_16_GivenName,
				@OBR_16_FamilyName,
				@OBR_16_OrderingPhysician_ID,
				@OBR_44_Text,
				@OBR_44_ProcedureCode_Identifier,
				@OBR_44_CodingSystem,

				isnull(@OBR_16_GivenName,'') + isnull(' ' + @OBR_16_FamilyName,''),
				@LabDataProviderName,
				isnull(@OBR_16_GivenName,'') + isnull(' ' + @OBR_16_FamilyName,''),
				@LabDataProviderName,
				@TempProvPhone,
				@OBR_16_OrderingPhysician_ID,
				@OBR_16_OrderingPhysician_ID,
				@SourceName)

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