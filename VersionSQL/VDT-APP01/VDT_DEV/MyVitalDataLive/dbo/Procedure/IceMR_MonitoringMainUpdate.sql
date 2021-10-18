/****** Object:  Procedure [dbo].[IceMR_MonitoringMainUpdate]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[IceMR_MonitoringMainUpdate]  

@ICENUMBER varchar(15),
@MonitoringId int,
@BaseLine varchar(50),
@Goal varchar(50)

AS


SET NOCOUNT ON

INSERT INTO MainMonitoring(ICENUMBER, MonitoringId, BaseLine, Goal,
CreationDate, ModifyDate) VALUES (@ICENUMBER, @MonitoringId, @BaseLine, @Goal,
GETUTCDATE(), GETUTCDATE())