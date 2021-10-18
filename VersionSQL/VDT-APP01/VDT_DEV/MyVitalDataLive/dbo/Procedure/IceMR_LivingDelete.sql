/****** Object:  Procedure [dbo].[IceMR_LivingDelete]    Committed by VersionSQL https://www.versionsql.com ******/

create Procedure [dbo].[IceMR_LivingDelete]  

@ICENUMBER varchar(15)
          
AS

SET NOCOUNT ON


DELETE  MainLivingArrangements WHERE ICENUMBER = @ICENUMBER