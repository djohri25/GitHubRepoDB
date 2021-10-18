/****** Object:  Procedure [dbo].[IceMR_CreateAccount]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[IceMR_CreateAccount]
	@IceGroup varchar(10),
	@IceNumber varchar(10),
	@SoftwareKey varchar(50),
	@LastName varchar(50),
	@FirstName varchar(50),
	@Password varchar(50),
	@Email varchar(50),
	@IsNewAccount bit,
	@Result int OUT
As

SET NOCOUNT ON

DECLARE @Count int

SELECT @Result = COUNT(*) FROM MainICEGROUP WHERE ICEGROUP = @IceGroup

---------------
-- Part 1
---------------

IF @IsNewAccount = 1
BEGIN	
	IF @Result = 1
	-- Group existed, regenerate new #
	RETURN
	-- Move down to part 2
END
ELSE	
BEGIN
	IF @Result = 0
	-- Group not existed, new profile requires existing group
	BEGIN
		SET @Result = 3
		RETURN
	END
	ELSE
	BEGIN
		SELECT @Count = ISNULL(SUM(GroupMax),0) FROM MainICEGROUP WHERE ICEGROUP = @IceGroup
		SELECT @Result = COUNT(*) FROM MainICENUMBERGroups WHERE ICEGROUP = @IceGroup
		IF @Result >= @Count
		BEGIN
			-- Maximum profiles found
			SET @Result = 4
			RETURN
		END
		-- Move down to part 2
	END	
END

-------------
-- Part 2
-------------

SELECT @Result = COUNT(*) FROM MainICENUMBERGroups WHERE ICENUMBER = @IceNumber

IF @Result = 1
	-- IceNumber existed, regenerate new #
	RETURN
ELSE
BEGIN
	IF @IsNewAccount = 1	
	BEGIN
		SELECT @Result = COUNT(*) FROM MainUserName WHERE UserName = @Email
		IF @Result = 1
		-- Email existed
		BEGIN
			SET @Result = 2
			RETURN
		END
		ELSE
		BEGIN
			INSERT INTO MainICEGROUP (ICEGROUP, GroupName, SoftwareKey, GroupMax, CreationDate, 
			ModifyDate) VALUES (@IceGroup, 'GOODCARE', @SoftwareKey, 3, GETUTCDATE(), GETUTCDATE())			

			INSERT INTO MainUserName (ICEGROUP, UserName, Password, isReadOnly, Active,
			CreationDate, ModifyDate)
			VALUES (@IceGroup, @Email, @Password, 1, 1, GETUTCDATE(), GETUTCDATE())

		END
	END
	-- Move down to part 3
END

-------------
-- Part 3
-------------
		
INSERT INTO MainICENUMBERGroups (ICEGROUP, ICENUMBER, MainAccount, CreationDate, ModifyDate) VALUES
(@IceGroup, @IceNumber, @IsNewAccount, GETUTCDATE(), GETUTCDATE())

INSERT INTO MainPersonalDetails (ICENUMBER, LastName, FirstName, Email, CreationDate, ModifyDate)
VALUES (@IceNumber, @LastName, @FirstName, @Email, GETUTCDATE(), GETUTCDATE())

SET @Result = 0