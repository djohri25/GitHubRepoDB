/****** Object:  Procedure [dbo].[Ems_Update]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 
-- Description:	Updates EMS user record
--		If @Password parameter is valued, update by record ID 
--		because email field is also updatable
--		Otherwise update by email which is unique identifier of a record
-- =============================================
CREATE Procedure [dbo].[Ems_Update]	
	@Result int OUT,
	@RecordID int = null,
	@Username varchar(50),
	@Email varchar(50),
	@LastName varchar(50),
	@FirstName varchar(50),
	@Company varchar(50),
	@Phone varchar(10) = null,
	@Fax varchar(10) = null,
	@Address1 varchar(50),
	@Address2 varchar(50) = null,
	@City varchar(50),
	@State varchar(5),
	@Zip varchar(10),	
	@StateLicense varchar(50),
	@DriversLicense varchar(10),
	@SSN varchar(10),
	@Password varchar(50),
	@SecurityQuestion1 int,
	@SecurityAnswer1 varchar(50),
	@SecurityQuestion2 int,
	@SecurityAnswer2 varchar(50),
	@SecurityQuestion3 int,
	@SecurityAnswer3 varchar(50),
	@Active bit
AS
	SET NOCOUNT ON

	DECLARE @CompanyID int

	-- find ID of the corresponding company
	-- TODO: Read the id from the dropdown instead
	SELECT @CompanyID = ID FROM mainEmsHospital WHERE name = @Company		

	IF ISNULL(@Password, '') = ''
		UPDATE	MainEMS 
		SET		LastName = dbo.InitCap(@LastName), 
				FirstName = dbo.InitCap(@FirstName), Phone = @Phone,
				Fax = @Fax, Address1 = @Address1, Address2 = @Address2,
				City = @City, State = @State, Zip = @Zip, 
				StateLicense = @StateLicense, DriversLicense = @DriversLicense,
				SSN = @SSN, Active = @Active
		WHERE	Username = @Username AND Company = @Company
	ELSE
	BEGIN
		IF EXISTS (SELECT TOP 1 * FROM MainEMS WHERE Username = @Username AND Company = @Company AND PrimaryKey != @RecordID)
			-- other ems user already has the same email
			SET @Result = -1
		ELSE
		BEGIN		
			UPDATE	MainEMS 
			SET		LastName = dbo.InitCap(@LastName), 
					FirstName = dbo.InitCap(@FirstName), Company = @Company, CompanyID = @CompanyID, Address1 = @Address1, 
					City = @City, State = @State, Zip = @Zip, 
					StateLicense = @StateLicense, DriversLicense = @DriversLicense,
					SSN = @SSN, Username = @Username, Password = @Password, Email = LOWER(@Email), Active = @Active,
					SecurityQ1 = @SecurityQuestion1, SecurityA1 = @SecurityAnswer1, 
					SecurityQ2 = @SecurityQuestion2, SecurityA2 = @SecurityAnswer2, 
					SecurityQ3 = @SecurityQuestion3, SecurityA3 = @SecurityAnswer3
			WHERE	PrimaryKey = @RecordID

			SET @Result = 1
		END
	END