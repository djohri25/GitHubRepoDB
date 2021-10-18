/****** Object:  Procedure [dbo].[Upd_CCRActors]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		sw
-- Create date: 5/4/2009
-- Description:	Fills in additional information about actor
--	based on NPI (if provided). If NPI is not provided, sets first name 
--	and last name base on full name when actor is a person
-- NOTE: only call within the scope of CCR Export stored procedure
-- =============================================
CREATE PROCEDURE [dbo].[Upd_CCRActors]
	@MVDId varchar(20)
AS
BEGIN
	SET NOCOUNT ON;

	create table #tempProviderInfo 
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
		Fax varchar(50)
	)

	declare @organizationName varchar(50),
		@lastName varchar(50),
		@firstName varchar(50),
		@credentials varchar(50),
		@address1 varchar(50),
		@address2 varchar(50),
		@city  varchar(50),
		@state  varchar(2),
		@zip	 varchar(50),
		@Phone varchar(10),
		@Fax varchar(50),
		@tempIDProvider int,						-- who provided NPI 

		@CustId int,						-- customer the member is mapped to
		@CustName varchar(50),
		@CustType int,
		@CustAddress1 varchar(50),
		@CustAddress2 varchar(50),
		@CustCity varchar(50),
		@CustState char(2),
		@CustZip varchar(10),
		@CustPhone varchar(10)		

	declare @id int, @fullname varchar(500), @NPI varchar(20), @actorType int, 
		@nameNoTitle varchar(500), @title varchar(50)

	update #tempActors set isProcessed = 0

	-- Set NPI providers
	-- Currently most records are provided by health plan or other institution
	-- In this case, set customer ID as NPI provider
	-- Otherwise, assume CCR owner provided that info.
	-- Same logic is applied to the provider of rest of the info about Actor
	select @CustId = Cust_ID 
	from dbo.Link_MemberId_MVD_Ins where mvdid = @MVDId

	if(@CustId is not null)
	begin
		select
			@CustName = [Name],
			@CustType = Type,
			@CustAddress1 = Address1,
			@CustAddress2 = Address2,
			@CustCity = City,
			@CustState = State,
			@CustZip = PostalCode,
			@CustPhone = Phone
		from HPCustomer 
		where cust_id = @CustId

		select @tempIDProvider = id 
		from #tempActors where organizationName = @CustName

		if(@tempIDProvider is null)
		begin
			-- Create new actor for customer
			select @tempIDProvider = isnull(max(id),0) + 1
			from #tempActors

			insert into #tempActors
			(
				id, 
				actorType,
				organizationName,	
				address1,
				address2,
				city,
				state,
				zip,
				Phone
			)
			values
			(
				@tempIDProvider,
				'2',		-- organization
				@CustName,
				@CustAddress1,
				@CustAddress2,
				@CustCity,
				@CustState,
				@CustZip,
				@CustPhone
			)
		end
	end
	else
	begin
		select @tempIDProvider = ID from #tempActors where actorRole = 'Patient'
	end

	while exists (select id from #tempActors where isProcessed is null or isProcessed = 0)
	begin
		select top 1 @id = id, @npi = npi, @fullname = fullname, @actorType = actorType
		from #tempActors where isProcessed is null or isProcessed = 0
		
		if(len(isnull(@NPI,'')) > 0)
		begin
			insert into #tempProviderInfo
				EXEC Get_ProviderByID @ID = @NPI
					
		end

		if exists (select NPI from #tempProviderInfo where len(isnull(@NPI,'')) > 0)
		begin
			select  @organizationName = organizationName,
				@lastName = lastName,
				@firstName = firstName,
				@credentials = credentials,
				@address1 = address1,
				@address2 = address2,
				@city = city,
				@state = state,
				@zip = zip,
				@Phone = Phone,
				@Fax = Fax
			from #tempProviderInfo
	
			update #tempActors set
				organizationName = @organizationName,
				lastName = @lastName,
				firstName = @firstName,
				credentials = @credentials,
				address1 = @address1,
				address2 = @address2,
				city = @city,
				state = @state,
				zip = @zip,
				Phone = @Phone,
				Fax = @Fax
			where id = @id	
		end 
		else if(@actorType = 1)
		begin
			if(CHARINDEX(',',@fullName) = 0)
			begin
				set @nameNoTitle = @fullName
			end
			else
			begin
				select @nameNoTitle = substring(@fullName,0,CHARINDEX(',',@fullName)),
					@title = substring(@fullName,CHARINDEX(',',@fullName) + 1, len(@fullName) - CHARINDEX(',',@fullName) + 1)
			end 

			update #tempActors set
				firstName = substring(@nameNoTitle,0,CHARINDEX(' ',@nameNoTitle)),
				lastName = substring(@nameNoTitle,CHARINDEX(' ',@nameNoTitle) + 1, len(@nameNoTitle) - CHARINDEX(' ',@nameNoTitle) + 1),
				title = @title
			where id = @id			
		end

		update #tempActors set
			isProcessed = 1
		where id = @id			
		
		delete from #tempProviderInfo
	end
	
	update #tempActors 
	set IDProvider = @tempIDProvider
	where npi is not null

	update #tempActors 
	set isProcessed = 0,
		DataProvider = @tempIDProvider

	drop table #tempProviderInfo
END