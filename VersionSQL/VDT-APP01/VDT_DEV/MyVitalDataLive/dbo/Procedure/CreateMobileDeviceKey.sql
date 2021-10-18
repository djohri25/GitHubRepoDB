/****** Object:  Procedure [dbo].[CreateMobileDeviceKey]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE dbo.CreateMobileDeviceKey
	@DeviceID varchar(50),
	@IceGrp varchar(15)
AS
	DECLARE @DeviceKey uniqueidentifier
	SET @DeviceKey = NewID()
	
	INSERT INTO DeployedMobileDevices (DeviceID, DeviceKey, ICEGROUP)
	VALUES (@DeviceID, @DeviceKey, @IceGrp)

	SELECT @DeviceKey 'DeviceKey'