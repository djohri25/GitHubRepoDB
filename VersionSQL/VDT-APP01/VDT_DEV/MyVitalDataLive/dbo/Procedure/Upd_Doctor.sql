/****** Object:  Procedure [dbo].[Upd_Doctor]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 7/27/2010
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Upd_Doctor]
	@Result int OUT,
	@npi varchar(20),
	@LastName varchar(50),
	@FirstName varchar(50),
	@Address1 varchar(50),
	@Address2 varchar(50),
	@City varchar(50),
	@State varchar(5),
	@Zip varchar(10),	
	@Phone varchar(10),
	@Fax varchar(10),
	@MedicalGroup varchar(100),
	@Gender varchar(50) = null,
	@OfficeHrMon varchar(50),
	@OfficeHrTue varchar(50),
	@OfficeHrWed varchar(50),
	@OfficeHrThu varchar(50),
	@OfficeHrFri varchar(50),
	@OfficeHrSat varchar(50),
	@OfficeHrSun varchar(50),
	@Note varchar(4000),
	@Languages varchar(1000),
	@SimilarProviderNPIList varchar(1000)

AS
BEGIN
	SET NOCOUNT ON;

	set @Result = -1

	declare @otherNPIs table (npi varchar(20), isProcessed bit default(0))
	declare @tempNPI varchar(20)

	exec dbo.CopyNPIRecordToNPICustom @npi = @npi

	update lookupNPI_custom set
		[Provider First Name] = @firstName,		
		[Provider Last Name (Legal Name)] = @LastName,
		[Provider First Line Business Practice Location Address] =  @Address1,
		[Provider Second Line Business Practice Location Address] = @Address2,
		[Provider Business Practice Location Address City Name] = @City,
		[Provider Business Practice Location Address State Name] = @State,
		[Provider Business Practice Location Address Postal Code] = @Zip,
		[Provider Gender Code] = @Gender,
		[Provider Business Practice Location Address Telephone Number] = @Phone,
		[Provider Business Practice Location Address Fax Number] = @Fax,
		MedicalGroup = @MedicalGroup,
		OfficeHrMon = @OfficeHrMon,
		OfficeHrTue = @OfficeHrTue,
		OfficeHrWed = @OfficeHrWed,
		OfficeHrThu = @OfficeHrThu,
		OfficeHrFri = @OfficeHrFri,
		OfficeHrSat = @OfficeHrSat,
		OfficeHrSun = @OfficeHrSun,
		Note = @Note	
	where npi = @npi	

	DECLARE @TranName VARCHAR(20);
	set @TranName = 'SaveLanguages';

	begin transaction @TranName

	if(isnull(@languages,'') <> '')
	begin
		declare @langArr table(data varchar(20))

		delete from dbo.PersonLanguagesSpoken where personID = @npi and personcategory = 'provider'
		
		insert into @langArr(data)
		select data from dbo.Split(@languages,',')

		insert into PersonLanguagesSpoken(personID,PersonCategory,LanguageID)
		select @npi,'Provider',data
		from @langArr
	end

	commit transaction @TranName

	-- Update hours, etc for all other providers in the list
	if(isnull(@SimilarProviderNPIList,'') <> '')
	begin
		insert into @otherNPIs (npi)
		select * from dbo.split(@SimilarProviderNPIList,',')

		while exists (select top 1 npi from @otherNPIs where isProcessed = 0)
		begin
			select top 1 @tempNPI = npi from @otherNPIs where isProcessed = 0

			exec dbo.CopyNPIRecordToNPICustom @npi = @tempNPI

			update lookupNPI_custom set
				OfficeHrMon = @OfficeHrMon,
				OfficeHrTue = @OfficeHrTue,
				OfficeHrWed = @OfficeHrWed,
				OfficeHrThu = @OfficeHrThu,
				OfficeHrFri = @OfficeHrFri,
				OfficeHrSat = @OfficeHrSat,
				OfficeHrSun = @OfficeHrSun
			where npi = @tempNPI	

			update @otherNPIs set isProcessed = 1 where npi = @tempNPI
		end		
	end

	set @Result = 0
END