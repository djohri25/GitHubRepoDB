/****** Object:  Procedure [dbo].[Rpt_Monitoring]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[Rpt_Monitoring] 

	@ICENUMBER varchar(15)
As

SET NOCOUNT ON

SELECT MonitoringId, (SELECT MonitoringName FROM LookupMonitoring 
WHERE LookupMonitoring.MonitoringId = MainMonitoring.MonitoringId) AS MonitoringName,
BaseLine, Goal, SumDetail = (SELECT COUNT(*) FROM SubMonitoring WHERE 
ICENUMBER = @IceNumber AND SubMonitoring.MonitoringId = MainMonitoring.MonitoringId)
FROM MainMonitoring WHERE IceNumber = @IceNumber