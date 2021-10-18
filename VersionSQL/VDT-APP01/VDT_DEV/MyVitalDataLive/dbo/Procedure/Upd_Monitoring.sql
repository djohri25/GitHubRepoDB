/****** Object:  Procedure [dbo].[Upd_Monitoring]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[Upd_Monitoring]

@RecNum int,
@MonitoringDate datetime,
@MonitoringResult varchar(50)

as

SET NOCOUNT ON



UPDATE SubMonitoring
SET 
MonitoringDate = @MonitoringDate, 
MonitoringResult = @MonitoringResult,
ModifyDate = GETUTCDATE()
WHERE RecordNumber = @RecNum