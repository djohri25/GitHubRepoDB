/****** Object:  Function [dbo].[ContactLenses]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE FUNCTION [dbo].[ContactLenses](@IceNumber varchar(15))
RETURNS bit
AS
BEGIN
	DECLARE @Count int
	
	SELECT @Count = COUNT(*) FROM dbo.MainAssistiveDevices WHERE
	CombinedDeviceID IN (10, 11) AND ICENUMBER = @IceNumber

	RETURN CONVERT(bit, @COUNT)
END