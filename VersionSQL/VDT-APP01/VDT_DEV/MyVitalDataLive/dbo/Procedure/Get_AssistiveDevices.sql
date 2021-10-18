/****** Object:  Procedure [dbo].[Get_AssistiveDevices]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[Get_AssistiveDevices] 
	@Language BIT = 1
As

Set Nocount On
IF(@Language = 1)
	BEGIN -- 1 = english
		Select DeviceID, DeviceName From LookUpDeviceID
		Order By DeviceId
	END
ELSE
	BEGIN -- 0 = spanish
		Select DeviceID, DeviceNameSpanish DeviceName From LookUpDeviceID
		Order By DeviceId
	END