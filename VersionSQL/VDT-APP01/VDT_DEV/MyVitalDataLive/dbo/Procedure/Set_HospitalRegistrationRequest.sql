/****** Object:  Procedure [dbo].[Set_HospitalRegistrationRequest]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[Set_HospitalRegistrationRequest]	
	@Result int OUT,
	@Name varchar(50),
	@Address varchar(50),
	@City varchar(50),
	@State varchar(50),
	@Zip varchar(10),
	@ContactName varchar(50),
	@ContactEmail varchar(50),
	@ContactPhone varchar(10),
	@Website varchar(50),
	@IP varchar(20),
	@EmailDomains varchar(500)

AS

	SET NOCOUNT ON


	declare @isAllowedDomainList bit

	set @isAllowedDomainList = dbo.IsAllowedDomainList(@EmailDomains)	

	IF EXISTS (SELECT * FROM MainEMSHospital WHERE Name = @Name and IP = @IP)
		-- hospital already registered
		SET @Result = -1
	ELSE if (@isAllowedDomainList = 0)
	begin
		-- One or more domains exists on forbidden domain list
		set @Result = -2
	end
	ELSE
	BEGIN
		INSERT INTO MainEMSHospital (Name, Address, City, State, Zip, ContactName, ContactEmail,
			ContactPhone, Website, IP, RestrictedEmailDomains)
		VALUES (@Name, @Address, @City, @State, @Zip, @ContactName, @ContactEmail,
			@ContactPhone, @Website, @IP, @EmailDomains)
		SET @Result = @@ROWCOUNT	
	END