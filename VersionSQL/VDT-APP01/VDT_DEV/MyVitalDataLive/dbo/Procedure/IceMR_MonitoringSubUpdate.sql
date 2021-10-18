/****** Object:  Procedure [dbo].[IceMR_MonitoringSubUpdate]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[IceMR_MonitoringSubUpdate]  

@ICENUMBER varchar(15),
@MonitoringId int,
@MonDate datetime,
@Result varchar(50)

AS


SET NOCOUNT ON

INSERT INTO SubMonitoring(ICENUMBER, MonitoringId, MonitoringDate,
MonitoringResult, CreationDate, ModifyDate) VALUES (@ICENUMBER, @MonitoringId, 
@MonDate, @Result, GETUTCDATE(), GETUTCDATE())