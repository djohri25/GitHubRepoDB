/****** Object:  Procedure [dbo].[Create_UserProfiles]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[Create_UserProfiles]
	@UserName varchar(50),
	@FirstName varchar(50),
	@LastName varchar(50),
	@Email varchar(50),
	@Password varchar(20),
	@HomePhone varchar(10),
	@SecQue int,
	@SecAns varchar(50),
	@DOB datetime,	
	@NewIce varchar(10),
	@NewGroup varchar(10),
	@BillingEmail nvarchar(100),
	@Address1 varchar(50) = null,
	@Address2 varchar(50) = null,
	@City varchar(50) = null,
	@State varchar(2) = null,
	@PostalCode varchar(5) = null,
	@CreatedBy nvarchar(250) = null,
	@UpdatedBy nvarchar(250) = null,
	@UpdatedByContact nvarchar(256) = NULL,
	@Organization nvarchar(64) = NULL,
	@Result int OUT
As

SET NOCOUNT ON

DECLARE @Count int


-- @Result = 1: email existed
SELECT @Result = COUNT(*) FROM MainUserName WHERE UserName = @UserName 

IF @Result = 0
BEGIN
	-- @Result = 3: new user	
			
	INSERT INTO MainPersonalDetails (ICENUMBER, LastName, FirstName, DOB, Address1, 
	Address2, City, state, PostalCode, HomePhone, Email, CreationDate, ModifyDate,CreatedBy,
	UpdatedBy,UpdatedByContact,Organization)
	VALUES (@NewIce, @LastName, @FirstName, @DOB, @Address1, @Address2, @City, 
	@State, @PostalCode, @HomePhone, @Email, GETUTCDATE(), GETUTCDATE(),@CreatedBy,
	@UpdatedBy,@UpdatedByContact,@Organization)

	DECLARE @Accounts int, @Profiles int
	EXEC GetAccountActivation @BillingEmail, @Accounts output, @Profiles output
	
	INSERT INTO MainUserName (UserName, Password, ICEGROUP, SecQuestion, SecAnswer, MaxAttachment, BillingEmail, CreationDate, ModifyDate)
	VALUES (@UserName, @Password, @NewGroup, @SecQue, @SecAns, (@Accounts + @Profiles) * 10240, @BillingEmail, GETUTCDATE(), GETUTCDATE())

	INSERT INTO UserAdditionalInfo (MVDID, IsPackageSent) 
	VALUES (@NewIce, '0')
 	
	EXEC DecreaseAccountActivation @BillingEmail, 1, 0

	SET @Result = 3
END