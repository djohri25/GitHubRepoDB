/****** Object:  Procedure [dbo].[Upd_AssistiveDevices]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[Upd_AssistiveDevices]

@ICENUMBER varchar(15),
@CombinedDeviceID int,
@IsChecked bit

As

Set Nocount On

DECLARE @Count int

IF @IsChecked = 0
	DELETE MainAssistiveDevices WHERE
	ICENUMBER = @ICENUMBER AND CombinedDeviceId = @CombinedDeviceId 
ELSE
BEGIN
	SELECT @Count = COUNT(*) FROM MainAssistiveDevices
	WHERE ICENUMBER = @ICENUMBER AND CombinedDeviceId = @CombinedDeviceId 
	IF @Count = 0
		INSERT INTO MainAssistiveDevices (ICENUMBER, CombinedDeviceId, CreationDate,
		ModifyDate) VALUES (@ICENUMBER, @CombinedDeviceId , GETUTCDATE(), GETUTCDATE())
	ELSE
		UPDATE MainAssistiveDevices
		SET ModifyDate = GETUTCDATE()
		WHERE ICENUMBER = @ICENUMBER AND CombinedDeviceId = @CombinedDeviceId 
END