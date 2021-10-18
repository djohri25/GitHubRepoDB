/****** Object:  Procedure [dbo].[Set_Monitoring]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[Set_Monitoring]

@ICENUMBER varchar(15),
@MonitoringId int,
@MonitoringDate datetime,
@MonitoringResult varchar(50)

as

SET NOCOUNT ON

DECLARE @Count int

INSERT INTO SubMonitoring (ICENUMBER, MonitoringId, MonitoringDate, MonitoringResult,
CreationDate, ModifyDate) Values (@ICENUMBER, @MonitoringId, @MonitoringDate, @MonitoringResult,
GETUTCDATE(), GETUTCDATE())

SELECT @Count = COUNT(*) FROM MainMonitoring WHERE IceNumber = @IceNumber
AND MonitoringId = @MonitoringId

IF @Count = 0

	INSERT INTO MainMonitoring (ICENUMBER, MonitoringId, CreationDate, ModifyDate) 
	VALUES (@IceNumber, @MonitoringId, GETUTCDATE(), GETUTCDATE())