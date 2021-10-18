/****** Object:  Procedure [dbo].[Get_SubMonitoring]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[Get_SubMonitoring] 

	@ICENUMBER varchar(15),
	@MonitoringId int
As

SET NOCOUNT ON

SELECT RecordNumber, MonitoringDate, MonitoringResult, MonitoringId,
Month(MonitoringDate) As MonMonth, Year(MonitoringDate) As MonYear, Day(MonitoringDate) As MonDay
FROM SubMonitoring WHERE IceNumber = @IceNumber AND MonitoringId = @MonitoringId
ORDER BY MonitoringDate