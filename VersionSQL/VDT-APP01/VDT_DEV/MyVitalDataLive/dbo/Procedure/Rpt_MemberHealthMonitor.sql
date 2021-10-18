/****** Object:  Procedure [dbo].[Rpt_MemberHealthMonitor]    Committed by VersionSQL https://www.versionsql.com ******/

--Create
--
CREATE 
Procedure dbo.Rpt_MemberHealthMonitor 
@IceNumber varchar(15)
As

SELECT DISTINCT(MM.MonitoringID),LM.MonitoringName HealthMonitorName,MM.BaseLine, MM.Goal, dbo.ConcatenateHealthMonitoring(@IceNumber,MM.MonitoringID) HealthMonitorList
FROM MainMonitoring MM INNER JOIN LookupMonitoring LM ON MM.MonitoringID= LM.MonitoringID
WHERE MM.ICENUMBER = @IceNumber
ORDER BY HealthMonitorName