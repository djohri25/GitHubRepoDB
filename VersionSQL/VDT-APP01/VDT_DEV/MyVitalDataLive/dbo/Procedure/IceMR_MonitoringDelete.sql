/****** Object:  Procedure [dbo].[IceMR_MonitoringDelete]    Committed by VersionSQL https://www.versionsql.com ******/

create Procedure [dbo].[IceMR_MonitoringDelete]  

@ICENUMBER varchar(15)
          
AS

SET NOCOUNT ON


DELETE MainMonitoring WHERE ICENUMBER = @ICENUMBER

DELETE SubMonitoring WHERE ICENUMBER = @ICENUMBER