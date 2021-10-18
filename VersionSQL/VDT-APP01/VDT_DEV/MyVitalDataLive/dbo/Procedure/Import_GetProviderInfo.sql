/****** Object:  Procedure [dbo].[Import_GetProviderInfo]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		SW
-- Create date: 4/9/2009
-- Description:	Retrieves the provider information based on 
--	the input information: ID (e.g. NPI), first name and last name.
--	When provider is successfully looked up by ID, the output values are set
--	based on that info. Otherwise, provided first and last name are used to set
--	output values
-- =============================================
CREATE PROCEDURE [dbo].[Import_GetProviderInfo]
	@provID varchar(20),
	@provFirstName varchar(50),
	@provLastName varchar(50),
	@OutProviderType char(1) out,					-- 1 - individual, 2 - organization
	@OutProviderFullName varchar(100) out,			-- includes credentials e.g. John Doe, Dr.
	@OutProviderFirstName varchar(100) out,			
	@OutProviderLastName varchar(100) out,			
	@OutProviderOrganization varchar(50) out,
	@OutProviderContact varchar(50) out
AS

	-- provider info from LookupNPI table
	create table #tempProv 
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

	declare 
		-- provider info from LookupNPI table
		@TempNPI varchar(20),
		@TempProvOrgName varchar(50),
		@TempProvLastName varchar(50),
		@TempProvFirstName varchar(50),
		@TempProvCredentials varchar(50),	-- prefix in the individual's name
		@TempProvPhone varchar(50)

	-- Set prescriber as data provider
	-- Retrieved provider info if it could be located in lookup NPI table
	insert into #tempProv (npi, type, organizationName, lastName, firstName, credentials, 
			address1, address2,city, state, zip, Phone, Fax)
	exec Get_ProviderByID @ID = @provID, @Name = @provLastName

	SELECT	TOP 1
			@TempNPI = npi,
			@TempProvOrgName = organizationName,
			@TempProvLastName = lastName,
			@TempProvFirstName = firstName,
			@TempProvCredentials = credentials,
			@TempProvPhone = Phone,
			@OutProviderType = type
	FROM	#tempProv
	
	IF @TempNPI IS NOT NULL
	begin
		-- Info was successfully retrieved from lookup
		If(@OutProviderType = '1')
		begin
			-- Person (e.g. a doctor format: John Smith, Dr.)
			select	@OutProviderFullName = isnull(@TempProvFirstName+ ' ','')  + isnull(@TempProvLastName,'') + isnull(', ' + @TempProvCredentials,''),
					@OutProviderFirstName = @TempProvFirstName,
					@OutProviderLastName = @TempProvLastName,
					@OutProviderContact = @TempProvPhone,
					@OutProviderOrganization = ''
		end
		else
		begin
			-- Organization
			select	@OutProviderFullName = '',
					@OutProviderFirstName = '',
					@OutProviderLastName = '',
					@OutProviderContact = @TempProvPhone,
					@OutProviderOrganization = @TempProvOrgName
		end
	end
	else
	begin
		IF ISNULL(@provLastName,'') != '' AND ISNULL(@provFirstName,'') != ''
		begin
			-- Person (e.g. a doctor)
			select	@OutProviderFullName = @provFirstName + ' ' + @provLastName,
					@OutProviderFirstName = @provFirstName,
					@OutProviderLastName = @provLastName,
					@OutProviderContact = '',
					@OutProviderOrganization = '',
					@OutProviderType = '1'

		end
		ELSE IF ISNULL(@provLastName,'') != ''
		begin
			-- Currently there is no first name set in the import file
			-- Check if there are spaces in the name, if not assume it's individual
			if(CHARINDEX(' ', @provLastName) = 0 
				AND CHARINDEX(' ', @provLastName) <> len(@provLastName))
			begin
				select	@OutProviderFullName = @provLastName, 
					@OutProviderFirstName = '',
					@OutProviderLastName = @provLastName,
					@OutProviderContact = '',
					@OutProviderOrganization = '',
					@OutProviderType = '1'
			end
			else
			begin
				 -- Organization
				 select	@OutProviderFullName = '', 
					@OutProviderFirstName = '',
					@OutProviderLastName = '',
					@OutProviderContact = '',
					@OutProviderOrganization = @provLastName,
					@OutProviderType = '2'
			end
		end
		else 
		begin
			-- Default Organization
			select	@OutProviderFullName = '', 
					@OutProviderFirstName = '',
					@OutProviderLastName = '',
					@OutProviderContact = '',
					@OutProviderOrganization = '',
					@OutProviderType = '2'
		end
	end