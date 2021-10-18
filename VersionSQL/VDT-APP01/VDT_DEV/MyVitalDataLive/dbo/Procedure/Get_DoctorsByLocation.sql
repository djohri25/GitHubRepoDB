/****** Object:  Procedure [dbo].[Get_DoctorsByLocation]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 7/26/2010
-- Description:	Get list of doctors with the same address
--	as address of the provider specified by NPI
-- 07/17/2017 Marc De Luca Removed Database.dbo.Tablename call to just dbo.TableName
-- =============================================
CREATE PROCEDURE [dbo].[Get_DoctorsByLocation]
	@NPI varchar(20)
AS
BEGIN
	SET NOCOUNT ON;

	declare @address1 varchar(100), @address2  varchar(100), @city varchar(100), @state  varchar(2), @zip  varchar(20)

	if exists(select npi from LookupNPI_Custom where npi = @npi)
	begin
		select 
			@address1 = [Provider First Line Business Practice Location Address],
			@address2 = [Provider Second Line Business Practice Location Address],
			@city = [Provider Business Practice Location Address City Name],
			@state = [Provider Business Practice Location Address State Name],
			@zip = left([Provider Business Practice Location Address Postal Code],5)
		from LookupNPI_Custom
		where npi = @npi
	end
	else
	begin
		select 
			@address1 = [Provider First Line Business Practice Location Address],
			@address2 = [Provider Second Line Business Practice Location Address],
			@city = [Provider Business Practice Location Address City Name],
			@state = [Provider Business Practice Location Address State Name],
			@zip = left([Provider Business Practice Location Address Postal Code],5)
		from dbo.LookupNPI
		where npi = @npi
	end

	select NPI,
		dbo.InitCap(LEFT([Provider First Name],50)) as firstName,		
		dbo.InitCap(LEFT([Provider Last Name (Legal Name)],50)) AS LastName,
		dbo.FormatPhone([Provider Business Practice Location Address Telephone Number]) as Phone
	from dbo.LookupNPI
	where npi <> @npi
		and [Entity Type Code] = 1			-- only physicians
		and [Provider First Line Business Practice Location Address] = @address1
		and [Provider Second Line Business Practice Location Address] = @address2
		and [Provider Business Practice Location Address City Name] = @city
		and [Provider Business Practice Location Address State Name] = @state
		and left([Provider Business Practice Location Address Postal Code],5) = @zip	

END