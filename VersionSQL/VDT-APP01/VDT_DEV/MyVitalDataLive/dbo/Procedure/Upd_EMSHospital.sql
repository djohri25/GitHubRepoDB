/****** Object:  Procedure [dbo].[Upd_EMSHospital]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 7/27/2008
-- Description:	Updates hospital record
-- =============================================
CREATE Procedure [dbo].[Upd_EMSHospital]
	@Result int OUT,	
	@ID int,
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
	SET @Result = -1	-- default

	declare @isAllowedDomainList bit

	set @isAllowedDomainList = dbo.IsAllowedDomainList(@EmailDomains)	

	IF EXISTS (SELECT * FROM MainEMSHospital WHERE Name = @Name and ID != @ID)
		-- other hospital already has the same name
		SET @Result = -1
	ELSE if (@isAllowedDomainList = 0)
	begin
		-- One or more domains exists on forbidden domain list
		set @Result = -2
	end
	ELSE
	BEGIN
		declare @tempApprovedDate datetime

		select @tempApprovedDate=ApprovedDate from MainEMSHospital where ID=@ID

		IF @tempApprovedDate is null and @Active = 1
		begin
			-- the hospital became Active for the first time
			select @tempApprovedDate = getutcdate()
		end

		Update MainEMSHospital set Name=@Name, Address=@Address, City=@City, State=@State, Zip=@Zip, 
			ContactName=@Contactname, ContactEmail=@ContactEmail,
			ContactPhone=@ContactPhone, Website=@Website, IP=@IP, ApprovedDate = @tempApprovedDate,
			Active=@Active,CredentialsRequired=@CredentialsRequired, AutoApprove=@AutoApprove,
			Modified=getutcdate(), MinorsAge = @MinorsAge, RestrictedEmailDomains = @EmailDomains
		where ID = @ID

		if(isnull(@Category,'') <> '')
		begin
			update MainEMSHospital set Category = @Category
			where ID = @ID
		end

		SET @Result = 0
	END