/****** Object:  Procedure [dbo].[IceMR_MedicationDelete]    Committed by VersionSQL https://www.versionsql.com ******/

create Procedure [dbo].[IceMR_MedicationDelete]  

@ICENUMBER varchar(15)
          
AS

SET NOCOUNT ON


DELETE MainMedication WHERE ICENUMBER = @ICENUMBER