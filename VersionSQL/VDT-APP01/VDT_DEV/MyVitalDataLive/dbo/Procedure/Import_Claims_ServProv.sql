/****** Object:  Procedure [dbo].[Import_Claims_ServProv]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		SW
-- Create date: 2/9/2009
-- Description:	Import Claims Service Provider info into MVD member record
--		Based on NPI ID determine whether it is Organization/Hospital or Specialist and retrieve 
--		relevant data
--		Return import status: 0 - success, -1 - failure		
-- =============================================
CREATE PROCEDURE [dbo].[Import_Claims_ServProv]
	@ClaimRecordId varchar(50),
	@HPAssignedRecordID varchar(50),
	@MVDId varchar(15),
	@ServProvNPI varchar(50),
	@ServProvType char(1),			-- 1 - individual, 2 - organization
	@ServProvName varchar(50),
	@ServProvLastName varchar(50),
	@ServProvFirstName varchar(50),
	@ServProvAddress1 varchar(50),
	@ServProvAddress2 varchar(50),
	@ServProvCity varchar(50),
	@ServProvState varchar(2), 
	@ServProvZip varchar(50),
	@ServProvPhone  varchar(50),
	@ServProvFax  varchar(50),
	@ServProvCredentials varchar(50),	-- prefix in the individual's name
	@Customer varchar(50) = 'Health Plan of Michigan',
	@Result int output

as
	SET NOCOUNT ON
	declare @MVDSpecialistRoleId int, @MVDPlaceTypeId int, @MVDUpdatedRecordId int
	-- Provider info
	declare @provName varchar(50),
		@provFirstName varchar(50),
		@provLastName varchar(50),
		@provAddress1 varchar(50),
		@provAddress2 varchar(50),
		@provCity varchar(50),
		@provState varchar(2), 
		@provZip varchar(50),
		@provPhone  varchar(50),
		@provFax  varchar(50),
		@provType char(1),			-- 1 - individual, 2 - organization
		@provCredentials varchar(50)	-- prefix in the individual's name

	SET @Result = 0

	-- Set initial values
	select @provName = '',
		@provFirstName = '',
		@provLastName = '',
		@provAddress1 = '',
		@provAddress2 = '',
		@provCity = '',
		@provState = null, 
		@provZip = '',
		@provPhone  = '',
		@provFax = '',
		@provType = '1'

	-- Get Secondary Specialist role ID
	select top 1 @MVDSpecialistRoleId = RoleId 
	from LookupRoleID
	where RoleName like 'Secondary%'

	-- Get Hospital place type ID
	select top 1 @MVDPlaceTypeId = PlacesTypeId 
	from LookupPlacesTypeID
	where PlacesTypeName like '%Hospital%'


--	if exists (select npi from [156465-APP1].[hpm_import].dbo.LookupNPI where len(isnull(@ServProvNPI,'')) > 0 and npi = @ServProvNPI)
	
	IF ISNULL(@ServProvNPI,'') != ''
	begin
		-- Get additional info if provider is registered in NPI (National Provider Identifier) database		
		select @provType = @ServProvType,
			@provName = @ServProvName,
			@provLastName = @ServProvLastName,
			@provFirstName = @ServProvFirstName,
			@provAddress1 = @ServProvAddress1,
			@provAddress2 = @ServProvAddress2,
			@provCity = @ServProvCity,
			@provState = @ServProvState,
			@provZip = @ServProvZip,
			@provPhone = @ServProvPhone,
			@provFax = @ServProvFax,
			@provCredentials = @ServProvCredentials

		-- In order to speed up import process query local table instead of remote
		--from [156465-APP1].[hpm_import].dbo.lookupNPI 		
	end

	IF	ISNULL(@ServProvNPI,'') != '' AND 
		ISNULL(@provName,'') = '' AND 
		ISNULL(@provLastName,'') = ''
	begin
		-- NPI was provided but hasn't been found in lookup table
		IF ISNULL(@ServProvLastName,'') != ''
		begin
			-- Use only info provided in claims data
			IF ISNULL(@ServProvFirstName,'') != ''
			begin
				-- Specialist
				select @provType = '1',
					@provLastName = @ServProvLastName,
					@provFirstName = @ServProvFirstName
			end
			else
			begin
				-- Hospital
				select @provType = '2',
					@provName = @ServProvLastName
			end
		end
	end

	IF ISNULL(@provName,'') != '' OR ISNULL(@provLastName,'') != ''
	begin
		BEGIN TRY		
			if(@provType = '1')
			begin
				-- SPECIALIST
				IF NOT EXISTS(SELECT TOP 1 LastName FROM MainSpecialist WHERE ICENUMBER = @MVDId 
					AND LastName = @provLastName and FirstName = @provFirstName)
				begin
					-- Create new instance
					INSERT INTO MainSpecialist (ICENUMBER, LastName, FirstName, Address1, Address2,
						City, State, Postal, Phone, PhoneCell, FaxPhone, RoleId, 
						CreationDate, ModifyDate, NPI) 
					VALUES (@MVDId, @provLastName, @provFirstName, @provAddress1, @provAddress2,
						@provCity, @provState, @provZip, @provPhone, '', @provFax, @MVDSpecialistRoleId,
						GETUTCDATE(), GETUTCDATE(),@ServProvNPI)

					select @MVDUpdatedRecordId = SCOPE_IDENTITY()

					-- Keep the history of changes
					EXEC Import_SetHistoryLog
						@MVDID = @MVDId,
						@ImportRecordID = @ClaimRecordID,
						@HPAssignedID = @HPAssignedRecordID,
						@MVDRecordID = @MVDUpdatedRecordId,
						@Action = 'A',
						@RecordType = 'SPECIALIST',
						@Customer = @Customer,
						@SourceName = 'CLAIMS'
				end		
			end
			else
			begin
				-- ORGANIZATION/HOSPITAL
				IF NOT EXISTS(SELECT TOP 1 Name FROM MainPlaces WHERE ICENUMBER = @MVDId AND Name = @provName)
				begin
					INSERT INTO MainPlaces
					(	ICENUMBER,Name,Address1,Address2,City,State,Postal,
						Phone,FaxPhone,WebSite,PlacesTypeID,
						RoomLoc,Direction,Note,CreationDate,ModifyDate)
					VALUES
					(	@MVDId,@provName,@provAddress1, @provAddress2,@provCity, @provState, @provZip, 
						@provPhone, @provFax,'', @MVDPlaceTypeId,'','','',
						GETUTCDATE(), GETUTCDATE())

					select @MVDUpdatedRecordId = SCOPE_IDENTITY()

					-- Keep the history of changes
					EXEC Import_SetHistoryLog
						@MVDID = @MVDId,
						@ImportRecordID = @ClaimRecordID,
						@HPAssignedID = @HPAssignedRecordID,
						@MVDRecordID = @MVDUpdatedRecordId,
						@Action = 'A',
						@RecordType = 'HOSPITAL',
						@Customer = @Customer,
						@SourceName = 'CLAIMS'
				end
			end

			SELECT @Result = 0
		END TRY
		BEGIN CATCH
			SELECT @Result = -1

			EXEC ImportCatchError	
		END CATCH
	end