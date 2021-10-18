/****** Object:  Procedure [dbo].[Create_NewAccount]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[Create_NewAccount]
	@IceGroup varchar(10),
	@IceNumber varchar(15),
	@Valet varchar(15),
	@Username varchar(50),
	@Result int OUT
As

	SET NOCOUNT ON

	SELECT @Result = COUNT(*) FROM MainUserName WHERE UserName = @Username
	IF @Result = 1
	BEGIN
		-- Account existed
		SET @Result = 2
		RETURN
	END

	SELECT @Result = COUNT(*) FROM MainICEGROUP WHERE ICEGROUP = @IceGroup
	IF @Result = 1
		RETURN
	ELSE
	BEGIN
		SELECT @Result = COUNT(*) FROM MainICENUMBERGroups WHERE ICENUMBER = @IceNumber
		IF @Result = 1
			RETURN
		ELSE
		BEGIN
			INSERT INTO MainICEGROUP (ICEGROUP, GroupName, GroupMax, CreationDate, ModifyDate) 
			VALUES (@IceGroup, 'VDT', 1, GETUTCDATE(), GETUTCDATE())			
			INSERT INTO MainICENUMBERGroups (ICEGROUP, ICENUMBER, MainAccount, 
			SecondaryICENUMBER, CreationDate, ModifyDate) VALUES
			(@IceGroup, @IceNumber, 1, @Valet, GETUTCDATE(), GETUTCDATE())
			SET @Result = 0
		END
	END