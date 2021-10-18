/****** Object:  Procedure [dbo].[IceMR_ImmunDelete]    Committed by VersionSQL https://www.versionsql.com ******/

create Procedure [dbo].[IceMR_ImmunDelete]  

@ICENUMBER varchar(15)
          
AS

SET NOCOUNT ON


DELETE MainImmunization WHERE ICENUMBER = @ICENUMBER