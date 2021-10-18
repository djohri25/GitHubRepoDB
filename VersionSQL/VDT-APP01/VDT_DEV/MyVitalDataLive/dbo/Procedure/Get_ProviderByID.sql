/****** Object:  Procedure [dbo].[Get_ProviderByID]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		SW
-- Create date: 3/20/2009
-- Description:	Return Care Provider Info based on ID.
--	Search first by NPI, if not found search other identifiers
--	issued by different states
--  Don't allow multiple matches
-- 07/17/2017	Marc De Luca	Removed Database.dbo.Tablename call to just dbo.TableName
-- =============================================
CREATE PROCEDURE [dbo].[Get_ProviderByID]
	@ID varchar(50),
	@Name varchar(50) = null,	-- If provided, both ID and Name must match
	@IsExtendedInfo bit = 0
AS
BEGIN
	SET NOCOUNT ON;

	--SELECT @ID = '1003000142'--, @Name = 'sayed'

	CREATE TABLE #tempResult 
	(	npi varchar(50),
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
		Fax varchar(50),
		fullName varchar(100),
		fullMailingAddress varchar(500),
		fullBusinessAddress varchar(500)
	)

	DECLARE @count int

	IF ISNULL(@ID,'') != ''
	BEGIN
		-- IF first character is not digit the ID is not NPI
		IF SUBSTRING(@ID,1,1) BETWEEN '0' AND '9'
		BEGIN
			INSERT INTO #tempResult (npi, type, organizationName, lastName, firstName, credentials, 
					address1, address2,city, state, zip, Phone, Fax, fullName, fullMailingAddress, fullBusinessAddress )
			SELECT	NPI,
					[Entity Type Code] AS Type,
					LEFT([Provider Organization Name (Legal Business Name)],50) AS OrganizationName,
					LEFT([Provider Last Name (Legal Name)],50) AS LastName,
					[Provider First Name] AS FirstName,
					[Provider Credential Text] AS Credentials,
					LEFT([Provider First Line Business Practice Location Address],50) AS Address1,
					LEFT([Provider Second Line Business Practice Location Address],50) AS Address2,
					[Provider Business Practice Location Address City Name] AS City,
					LEFT([Provider Business Practice Location Address State Name],2) AS State,
					LEFT([Provider Business Practice Location Address Postal Code],5) AS Zip,
					LEFT([Provider Business Practice Location Address Telephone Number],10) AS Phone,
					LEFT([Provider Business Practice Location Address Fax Number],10) AS Fax,
					dbo.FullName(LEFT([Provider Last Name (Legal Name)],50),
						[Provider First Name],
						[Provider Middle Name]),
					dbo.FormatAddress(
						[Provider First Line Business Mailing Address],
						[Provider Second Line Business Mailing Address],
						[Provider Business Mailing Address City Name],
						[Provider Business Mailing Address State Name],
						LEFT([Provider Business Mailing Address Postal Code],5)
					),
					dbo.FormatAddress(
						LEFT([Provider First Line Business Practice Location Address],50),
						LEFT([Provider Second Line Business Practice Location Address],50),
						[Provider Business Practice Location Address City Name],
						LEFT([Provider Business Practice Location Address State Name],2),
						LEFT([Provider Business Practice Location Address Telephone Number],5)
					)
			FROM	dbo.lookupNPI 
			WHERE	NPI = @ID	
		END

		IF NOT EXISTS (SELECT npi FROM #tempResult)
		BEGIN
			-- Search other identifier fields in lookup table
			-- LookupNPI_Used has only record with one of the 50 identifies existing in current RX table
			-- NOTE: repopulate that table every time new RX data is imported (ask Sly)
			INSERT INTO #tempResult (npi, type, organizationName, lastName, firstName, credentials, 
					address1, address2,city, state, zip, Phone, Fax, fullName, fullMailingAddress, fullBusinessAddress )
			SELECT	NPI,
					[Entity Type Code] AS Type,
					LEFT([Provider Organization Name (Legal Business Name)],50) AS OrganizationName,
					LEFT([Provider Last Name (Legal Name)],50) AS LastName,
					[Provider First Name] AS FirstName,
					[Provider Credential Text] AS Credentials,
					[Provider First Line Business Practice Location Address] AS Address1,
					[Provider Second Line Business Practice Location Address] AS Address2,
					[Provider Business Practice Location Address City Name] AS City,
					[Provider Business Practice Location Address State Name] AS State,
					LEFT([Provider Business Practice Location Address Postal Code],5) AS Zip,
					LEFT([Provider Business Practice Location Address Telephone Number],10) AS Phone,
					LEFT([Provider Business Practice Location Address Fax Number],10) AS Fax,
					dbo.FullName(LEFT([Provider Last Name (Legal Name)],50),
						[Provider First Name],
						''),
					'',''
			FROM	dbo.lookupNPI_Used
			WHERE	@ID IN
					(   NPI,
						[Other Provider Identifier_1], [Other Provider Identifier_2], [Other Provider Identifier_3], [Other Provider Identifier_4], [Other Provider Identifier_5],
						[Other Provider Identifier_6], [Other Provider Identifier_7], [Other Provider Identifier_8], [Other Provider Identifier_9], [Other Provider Identifier_10],
						[Other Provider Identifier_11], [Other Provider Identifier_12], [Other Provider Identifier_13], [Other Provider Identifier_14], [Other Provider Identifier_15],
						[Other Provider Identifier_16], [Other Provider Identifier_17], [Other Provider Identifier_18], [Other Provider Identifier_19], [Other Provider Identifier_20],
						[Other Provider Identifier_21], [Other Provider Identifier_22], [Other Provider Identifier_23], [Other Provider Identifier_24], [Other Provider Identifier_25],
						[Other Provider Identifier_26], [Other Provider Identifier_27], [Other Provider Identifier_28], [Other Provider Identifier_29], [Other Provider Identifier_30],
						[Other Provider Identifier_31], [Other Provider Identifier_32], [Other Provider Identifier_33], [Other Provider Identifier_34], [Other Provider Identifier_35],
						[Other Provider Identifier_36], [Other Provider Identifier_37], [Other Provider Identifier_38], [Other Provider Identifier_39], [Other Provider Identifier_40],
						[Other Provider Identifier_41], [Other Provider Identifier_42], [Other Provider Identifier_43], [Other Provider Identifier_44], [Other Provider Identifier_45],
						[Other Provider Identifier_46], [Other Provider Identifier_47], [Other Provider Identifier_48], [Other Provider Identifier_49], [Other Provider Identifier_50]
					)
		END
	END

	SELECT @count = COUNT(npi) FROM #tempResult 

	IF @count > 1 AND ISNULL(@Name,'') != ''
	BEGIN
		-- name has to match
		DELETE FROM #tempResult 
		WHERE organizationName != @Name AND lastName != @Name

		-- recalculate counter
		SELECT @count = COUNT(npi) FROM #tempResult 
	END	

	IF @count > 1
		-- multiple match found, DELETE all
		DELETE FROM #tempResult

	if( @IsExtendedInfo = 0)
	begin
		IF @count = 1
			SELECT	npi, type, organizationName, dbo.initCap(lastName) AS lastName, dbo.initCap(firstName) AS firstName, credentials, 
					address1, address2,city, state, zip, Phone, Fax
			FROM	#tempResult
		ELSE IF ISNULL(@Name,'') != ''
			-- name has to match
			SELECT	npi, type, organizationName, dbo.initCap(lastName) AS lastName, dbo.initCap(firstName) AS firstName, credentials, 
					address1, address2,city, state, zip, Phone, Fax
			FROM	#tempResult
			WHERE	organizationName = @Name OR lastName = @Name
		ELSE
			SELECT	npi, type, organizationName, dbo.initCap(lastName) AS lastName, dbo.initCap(firstName) AS firstName, credentials, 
					address1, address2,city, state, zip, Phone, Fax
			FROM	#tempResult	
	end
	else
	begin

		IF @count = 1
			SELECT	npi, type, organizationName, dbo.initCap(lastName) AS lastName, dbo.initCap(firstName) AS firstName, credentials, 
					address1, address2,city, state, zip, Phone, Fax,fullName, fullMailingAddress, fullBusinessAddress 
			FROM	#tempResult
		ELSE IF ISNULL(@Name,'') != ''
			-- name has to match
			SELECT	npi, type, organizationName, dbo.initCap(lastName) AS lastName, dbo.initCap(firstName) AS firstName, credentials, 
					address1, address2,city, state, zip, Phone, Fax, fullName, fullMailingAddress, fullBusinessAddress 
			FROM	#tempResult
			WHERE	organizationName = @Name OR lastName = @Name
		ELSE
			SELECT	npi, type, organizationName, dbo.initCap(lastName) AS lastName, dbo.initCap(firstName) AS firstName, credentials, 
					address1, address2,city, state, zip, Phone, Fax,fullName, fullMailingAddress, fullBusinessAddress 
			FROM	#tempResult
	end
	
	DROP TABLE #tempResult
END