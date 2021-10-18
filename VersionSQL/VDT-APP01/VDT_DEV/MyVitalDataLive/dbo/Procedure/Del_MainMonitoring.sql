/****** Object:  Procedure [dbo].[Del_MainMonitoring]    Committed by VersionSQL https://www.versionsql.com ******/

create Procedure [dbo].[Del_MainMonitoring]

@MonId int,
@IceNumber varchar(15)

as

SET NOCOUNT ON

DELETE MainMonitoring WHERE MonitoringId = @MonId AND ICENUMBER = @IceNumber

DELETE SubMonitoring WHERE MonitoringId = @MonId AND ICENUMBER = @IceNumber