/****** Object:  Procedure [dbo].[IceMR_AllergiesDelete]    Committed by VersionSQL https://www.versionsql.com ******/

create Procedure [dbo].[IceMR_DeleteAllergies]  

@ICENUMBER varchar(15)
          
AS

SET NOCOUNT ON


DELETE MainAllergies WHERE ICENUMBER = @ICENUMBER