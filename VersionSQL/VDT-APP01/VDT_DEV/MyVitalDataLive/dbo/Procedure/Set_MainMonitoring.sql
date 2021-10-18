/****** Object:  Procedure [dbo].[Set_MainMonitoring]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[Set_MainMonitoring]

@ICENUMBER varchar(15),
@MonitoringId int,
@BaseLine varchar(50),
@Goal varchar(50)

as

SET NOCOUNT ON

DECLARE @Count int

SELECT @Count = COUNT(*) FROM MainMonitoring WHERE ICENUMBER = @ICENUMBER AND MonitoringId = @MonitoringId

IF @Count = 1

	UPDATE MainMonitoring SET
	BaseLine = @BaseLine,
	Goal = @Goal,
	ModifyDate = GETUTCDATE()
	WHERE ICENUMBER = @IceNumber AND MonitoringId = @MonitoringId

ELSE

	INSERT INTO MainMonitoring (ICENUMBER, MonitoringId, BaseLine, Goal, CreationDate, ModifyDate) 
	VALUES (@ICENUMBER, @MonitoringId, @BaseLine, @Goal, GETUTCDATE(), GETUTCDATE())