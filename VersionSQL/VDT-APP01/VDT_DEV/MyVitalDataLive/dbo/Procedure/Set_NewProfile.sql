/****** Object:  Procedure [dbo].[Set_NewProfile]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[Set_NewProfile]
	@IceGroup varchar(15),
	@IceNumber varchar(15),
	@FirstName varchar(50),
	@LastName varchar(50),
	@UserName nvarchar(50),
	@Result int OUT
As

	SET NOCOUNT ON
	
	/*
		Find Group, find Ice, insert new profile
		@Result = 1: No Group found
		@Result = 2: Ice# found
	*/

	DECLARE @Count int

	SELECT @Count = COUNT(*) FROM MainICEGROUP WHERE ICEGROUP = @IceGroup
	IF @Count = 0
	BEGIN
		SET @Result = 1;
		RETURN
	END
	ELSE
	BEGIN
		SELECT @Count = COUNT(*) FROM MainICENUMBERGroups WHERE ICENUMBER = @IceNumber
		IF @Count = 1
		BEGIN
			SET @Result = 2
			RETURN
		END
		ELSE
		BEGIN		
			INSERT INTO MainICENUMBERGroups (ICEGROUP, ICENUMBER, CreationDate, ModifyDate) VALUES
			(@IceGroup, @IceNumber, GETUTCDATE(), GETUTCDATE())

			INSERT INTO MainPersonalDetails	(ICENUMBER, FirstName, LastName, CreationDate, ModifyDate)
			VALUES (@IceNumber, @FirstName, @LastName, GETUTCDATE(), GETUTCDATE())

			INSERT INTO UserAdditionalInfo (MVDID,IsPackageSent) 
			VALUES (@IceNumber, '0')
			
			DECLARE @BillingEmail varchar(100)
			
			--Overriding @BillingEmail because MainUserName table should now have correct BillingEmail captured from storefront or Mendocino page.
			SELECT @BillingEmail = ISNULL(BillingEmail, @UserName)
			FROM MainUserName
			WHERE ICEGROUP = @ICEGROUP
			
			EXEC DecreaseAccountActivation @BillingEmail, 0, 1
			SET @Result = 0
		END
	END