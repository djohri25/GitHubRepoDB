/****** Object:  Procedure [dbo].[Get_AssistiveDeviceList]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[Get_AssistiveDeviceList]
	@ICENUMBER varchar(15),
	@DeviceId int
AS
SELECT	LD.DeviceName,c.CombinedDeviceID,
		DevImg = '../images/checked_grey.gif', l.DeviceLocationName 
FROM LookupDeviceLocationID l INNER JOIN 
CombinedLookupDeviceID c ON l.DeviceLocationId = c.DeviceLocationId
INNER JOIN MainAssistiveDevices m ON m.CombinedDeviceID = c.CombinedDeviceID
INNER JOIN LookupDeviceid ld ON ld.DeviceID = c.DeviceID
WHERE m.ICENUMBER = @ICENUMBER AND
c.DeviceId= @DeviceId
ORDER BY l.DeviceLocationName

--IF EXISTS (SELECT * FROM sysobjects WHERE name = 'Get_AssistiveDeviceList' and type = 'P')
--    DROP proc Get_AssistiveDeviceList;