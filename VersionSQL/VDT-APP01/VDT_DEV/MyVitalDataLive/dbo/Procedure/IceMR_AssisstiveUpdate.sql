/****** Object:  Procedure [dbo].[IceMR_AssisstiveUpdate]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[IceMR_AssisstiveUpdate]  

@ICENUMBER varchar(15),
@CombinedDeviceID int

AS

SET NOCOUNT ON

INSERT INTO MainAssistiveDevices
(ICENUMBER, CombinedDeviceID, CreationDate, ModifyDate)
VALUES (@ICENUMBER, @CombinedDeviceID, GETUTCDATE(), GETUTCDATE())