/****** Object:  Procedure [dbo].[IceMR_CreateProfile]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[IceMR_CreateProfile]
	@IceGroup varchar(10),
	@IceNumber varchar(15),	
	@Result int OUT
As

	SET NOCOUNT ON

	/*
		0 : OK
		1 : No group found		
		2 : Max number of accounts allocated		
		3 : IceNum found		
	*/

	DECLARE @Count int

	SELECT @Count = ISNULL(SUM(GroupMax),0) FROM MainICEGROUP WHERE ICEGROUP = @IceGroup
	IF @Count = 0
	BEGIN
		SET @Result = 1;
		RETURN
	END
	ELSE
	BEGIN
		SELECT @Result = COUNT(*) FROM MainICENUMBERGroups WHERE ICEGROUP = @IceGroup
		IF @Result >= @Count
		BEGIN
			SET @Result = 2
			RETURN
		END
		ELSE
		BEGIN						
			SELECT @Count = COUNT(*) FROM MainICENUMBERGroups WHERE ICENUMBER = @IceNumber
			IF @Count = 1
			BEGIN
				SET @Result = 3
				RETURN
			END
			ELSE
			BEGIN
				INSERT INTO MainICENUMBERGroups (ICEGROUP, ICENUMBER, CreationDate, ModifyDate) VALUES
				(@IceGroup, @IceNumber, GETUTCDATE(), GETUTCDATE())
				SET @Result = 0
			END
		END
	END