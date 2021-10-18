/****** Object:  Procedure [dbo].[GetMobileDeviceICEGROUP]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE dbo.GetMobileDeviceICEGROUP
	@deviceID varchar(50),
	@deviceKey uniqueidentifier
AS
	SELECT ICEGROUP
	FROM DeployedMobileDevices
	WHERE (DeviceID = @deviceID) AND 
	     (DeviceKey = @deviceKey) AND (Enabled = 1) 