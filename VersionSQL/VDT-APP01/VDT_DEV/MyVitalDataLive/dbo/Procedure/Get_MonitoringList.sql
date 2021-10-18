/****** Object:  Procedure [dbo].[Get_MonitoringList]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[Get_MonitoringList] 

As

SET NOCOUNT ON

SELECT MonitoringId, MonitoringName FROM LookupMonitoring
ORDER BY MonitoringName