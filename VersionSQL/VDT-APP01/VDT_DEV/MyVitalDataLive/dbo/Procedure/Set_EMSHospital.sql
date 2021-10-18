/****** Object:  Procedure [dbo].[Set_EMSHospital]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 7/27/2008
-- Description:	Inserts hospital record
-- =============================================
CREATE Procedure [dbo].[Set_EMSHospital]	
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
	@Active bit,
	@CredentialsRequired bit,
	@AutoApprove bit,
	@MinorsAge int,
	@EmailDomains varchar(100),
	@Category varchar(50) = null

AS

	SET NOCOUNT ON

	declare @tempApprovedDate datetime, @isAllowedDomainList bit

	set @isAllowedDomainList = dbo.IsAllowedDomainList(@EmailDomains)		

	IF EXISTS (SELECT ID FROM MainEMSHospital WHERE Name = @Name)
		-- hospital already registered
		SET @Result = -1
	ELSE if (@isAllowedDomainList = 0)
	begin
		-- One or more domains exists on forbidden domain list
		set @Result = -2
	end
	else
	BEGIN

		IF @Active = 1
		begin
			-- the hospital became Active for the first time
			select @tempApprovedDate = getutcdate()
		end

		Insert MainEMSHospital (Name, Address, City, State, Zip, ContactName, ContactEmail,
			ContactPhone, Website, IP, Active,ApprovedDate, CredentialsRequired, AutoApprove, Modified, MinorsAge, RestrictedEmailDomains, Category)
		values( @Name,@Address,@City,@State,@Zip,@Contactname,@ContactEmail,@ContactPhone, 
			@Website,@IP,@Active,@tempApprovedDate,@CredentialsRequired, @AutoApprove,
			getutcdate(),@MinorsAge,@EmailDomains, @Category
		)
		SET @Result = @@ROWCOUNT	

	END