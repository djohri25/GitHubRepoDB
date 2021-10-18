/****** Object:  Procedure [dbo].[Get_DeviceList]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[Get_DeviceList]
	@ICENUMBER varchar(15),
	@Language BIT = 1
AS
IF(@Language = 1)
	BEGIN -- 1 = english
		SELECT DISTINCT l.DeviceName, l.DeviceId FROM LookupDeviceID l 
		INNER JOIN CombinedLookupDeviceID c ON l.DeviceId = c.DeviceId
		INNER JOIN MainAssistiveDevices m ON m.CombinedDeviceID = c.CombinedDeviceID
		WHERE m.ICENUMBER = @ICENUMBER
		ORDER BY l.DeviceName
	END
ELSE
	BEGIN -- 0 = spanish
		SELECT DISTINCT l.DeviceNameSpanish DeviceName, l.DeviceId FROM LookupDeviceID l 
		INNER JOIN CombinedLookupDeviceID c ON l.DeviceId = c.DeviceId
		INNER JOIN MainAssistiveDevices m ON m.CombinedDeviceID = c.CombinedDeviceID
		WHERE m.ICENUMBER = @ICENUMBER
		ORDER BY l.DeviceNameSpanish
	END