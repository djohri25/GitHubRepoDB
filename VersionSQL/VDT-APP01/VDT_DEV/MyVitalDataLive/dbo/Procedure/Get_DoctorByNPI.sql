/****** Object:  Procedure [dbo].[Get_DoctorByNPI]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 7/23/2010
-- Description:	<Description,,>
-- 07/17/2017 Marc De Luca Removed Database.dbo.Tablename call to just dbo.TableName
-- =============================================
CREATE PROCEDURE [dbo].[Get_DoctorByNPI]
	@NPI varchar(50)
AS
BEGIN
	SET NOCOUNT ON;
	declare @languageList varchar(1000)
	set @languageList = ''

	if exists(select npi from LookupNPI_Custom where npi = @npi)
	begin
		select @languageList = @languageList + convert(varchar(10),LanguageID) + ','
		from dbo.PersonLanguagesSpoken 			
		where PersonID = @NPI and PersonCategory = 'Provider'

		if(len(isnull(@languageList,'')) > 2)
		begin
			set @languageList = substring(@languageList, 0, len(@languageList))
		end

		select NPI,
			dbo.InitCap(LEFT([Provider First Name],50)) as firstName,		
			dbo.InitCap(LEFT([Provider Last Name (Legal Name)],50)) AS LastName,
			[Provider Credential Text] as [Credential],
			LEFT([Provider First Line Business Practice Location Address],50) as Address1,
			LEFT([Provider Second Line Business Practice Location Address],50) as Address2,
			dbo.InitCap([Provider Business Practice Location Address City Name]) AS City,
			LEFT([Provider Business Practice Location Address State Name],2) as State,
			LEFT([Provider Business Practice Location Address Postal Code],5) as Zip,
			[Provider Gender Code] as Gender,
			[Provider Business Practice Location Address Telephone Number] as Phone,
			Substring([Provider Business Practice Location Address Telephone Number],1,3) As PhoneArea,
			Substring([Provider Business Practice Location Address Telephone Number],4,3) As PhonePrefix,
			Substring([Provider Business Practice Location Address Telephone Number],7,4) As PhoneSuffix,
			[Provider Business Practice Location Address Fax Number] as Fax,
			Substring([Provider Business Practice Location Address Fax Number],1,3) As FaxArea,
			Substring([Provider Business Practice Location Address Fax Number],4,3) As FaxPrefix,
			Substring([Provider Business Practice Location Address Fax Number],7,4) As FaxSuffix,
			MedicalGroup,
			OfficeHrMon as 'OfficeHrMon',
			OfficeHrTue as 'OfficeHrTue',
			OfficeHrWed as 'OfficeHrWed',
			OfficeHrThu as 'OfficeHrThu',
			OfficeHrFri as 'OfficeHrFri',
			OfficeHrSat as 'OfficeHrSat',
			OfficeHrSun as 'OfficeHrSun',
			Note,
			@languageList as 'Languages'
		from LookupNPI_Custom
		where npi = @npi
	end
	else
	begin
		select NPI,
			dbo.InitCap(LEFT([Provider First Name],50)) as firstName,		
			dbo.InitCap(LEFT([Provider Last Name (Legal Name)],50)) AS LastName,
			[Provider Credential Text] as [Credential],
			LEFT([Provider First Line Business Practice Location Address],50) as Address1,
			LEFT([Provider Second Line Business Practice Location Address],50) as Address2,
			dbo.InitCap([Provider Business Practice Location Address City Name]) AS City,
			LEFT([Provider Business Practice Location Address State Name],2) as State,
			LEFT([Provider Business Practice Location Address Postal Code],5) as Zip,
			[Provider Gender Code] as Gender,
			[Provider Business Practice Location Address Telephone Number] as Phone,
			Substring([Provider Business Practice Location Address Telephone Number],1,3) As PhoneArea,
			Substring([Provider Business Practice Location Address Telephone Number],4,3) As PhonePrefix,
			Substring([Provider Business Practice Location Address Telephone Number],7,4) As PhoneSuffix,
			[Provider Business Practice Location Address Fax Number] as Fax,
			Substring([Provider Business Practice Location Address Fax Number],1,3) As FaxArea,
			Substring([Provider Business Practice Location Address Fax Number],4,3) As FaxPrefix,
			Substring([Provider Business Practice Location Address Fax Number],7,4) As FaxSuffix,
			'' as MedicalGroup,
			'' as 'OfficeHrMon',
			'' as 'OfficeHrTue',
			'' as 'OfficeHrWed',
			'' as 'OfficeHrThu',
			'' as 'OfficeHrFri',
			'' as 'OfficeHrSat',
			'' as 'OfficeHrSun',
			'' as Note,
			''  as 'Languages'
		from dbo.LookupNPI
		where npi = @npi
	end

END