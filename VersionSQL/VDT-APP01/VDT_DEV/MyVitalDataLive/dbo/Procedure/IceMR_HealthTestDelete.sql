/****** Object:  Procedure [dbo].[IceMR_HealthTestDelete]    Committed by VersionSQL https://www.versionsql.com ******/

create Procedure [dbo].[IceMR_HealthyTestDelete]  

@ICENUMBER varchar(15)
          
AS

SET NOCOUNT ON


DELETE MainHealthTest WHERE ICENUMBER = @ICENUMBER