/****** Object:  Procedure [dbo].[Ems_AddNew]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	Creates new record of EMS user
--	Note: the call can come from the registration
--		page where active flag is not provided. 
--		That's why null value for Active is acceptable
-- =============================================
CREATE PROCEDURE [dbo].[Ems_AddNew]
	@Result int OUT,
	@Username varchar(50),
	@Email varchar(50),
	@Password varchar(50),
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
	@WebUrl varchar(100) = null,
	@StateLicense varchar(50),
	@DriversLicense varchar(10),
	@SSN varchar(10),
	@SecurityQ1 int,
	@SecurityA1 varchar(50),
	@SecurityQ2 int,
	@SecurityA2 varchar(50),
	@SecurityQ3 int,
	@SecurityA3 varchar(50),
	@Active bit = null
AS
	SET NOCOUNT ON

	DECLARE @CompanyID int

	-- find ID of the corresponding company
	-- TODO: Read the id from the dropdown instead
	SELECT @CompanyID = ID FROM mainEmsHospital WHERE name = @Company	

	IF EXISTS (SELECT TOP 1 * FROM MainEMS WHERE Username = @Username AND CompanyID = @CompanyID)
		-- username found
		SET @Result = -1
	ELSE
	BEGIN
		IF @Active IS NULL
			-- set to default 0
			SET @Active = 0

		INSERT INTO MainEMS (Username, Email, Password, LastName, FirstName, Company, CompanyID, Phone,
			Fax, Address1, Address2, City, State, Zip, WebUrl, StateLicense, 
			DriversLicense, SSN, SecurityQ1, SecurityA1, SecurityQ2, SecurityA2, SecurityQ3, SecurityA3, Active)
		VALUES (LOWER(@Username), LOWER(@Email), @Password, dbo.InitCap(@LastName), dbo.InitCap(@FirstName), @Company, @CompanyID, @Phone,
			@Fax, @Address1, @Address2, @City, @State, @Zip, @WebUrl, @StateLicense, 
			@DriversLicense, @SSN, @SecurityQ1, @SecurityA1, @SecurityQ2, @SecurityA2, @SecurityQ3, @SecurityA3, @Active)
		SET @Result = @@ROWCOUNT	
	END