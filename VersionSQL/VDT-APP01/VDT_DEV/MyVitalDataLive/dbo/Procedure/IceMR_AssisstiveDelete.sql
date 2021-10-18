/****** Object:  Procedure [dbo].[IceMR_AssisstiveDelete]    Committed by VersionSQL https://www.versionsql.com ******/

create Procedure [dbo].[IceMR_AssisstiveDelete]  

@ICENUMBER varchar(15)
          
AS

SET NOCOUNT ON


DELETE MainAssistiveDevices WHERE ICENUMBER = @ICENUMBER