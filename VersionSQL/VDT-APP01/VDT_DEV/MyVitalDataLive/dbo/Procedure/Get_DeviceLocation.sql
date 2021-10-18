/****** Object:  Procedure [dbo].[Get_DeviceLocation]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[Get_DeviceLocation] 
	@ICENUMBER varchar(15),
	@DeviceId int,
	@Language BIT = 1
as

Set Nocount On

create table #TmpDevice (CombinedDeviceID int, IsCheck int, DevImg varchar(50), DeviceLocationName varchar(50))

IF(@Language = 1)
	BEGIN -- 1 = english
		insert into #TmpDevice
		SELECT  CombinedDeviceID, IsCheck = 0, DevImg = '../images/unchecked.gif',
		(SELECT DeviceLocationName FROM LookupDeviceLocationID 
		WHERE DeviceLocationId = CombinedLookupDeviceID.DeviceLocationId) AS DeviceLocationName
		FROM CombinedLookupDeviceID WHERE DeviceId = @DeviceId
	END
ELSE
	BEGIN -- 0 = spanish
		insert into #TmpDevice
		SELECT  CombinedDeviceID, IsCheck = 0, DevImg = '../images/unchecked.gif',
		(SELECT DeviceLocationNameSpanish FROM LookupDeviceLocationID 
		WHERE DeviceLocationId = CombinedLookupDeviceID.DeviceLocationId) AS DeviceLocationName
		FROM CombinedLookupDeviceID WHERE DeviceId = @DeviceId
	END
UPDATE #TmpDevice
SET isCheck = 1,
DevImg = '../images/checked_grey.gif'
FROM MainAssistiveDevices
WHERE MainAssistiveDevices.CombinedDeviceId = #TmpDevice.CombinedDeviceId
AND ICENUMBER = @ICENUMBER

SELECT * FROM #TmpDevice

DROP TABLE #TmpDevice