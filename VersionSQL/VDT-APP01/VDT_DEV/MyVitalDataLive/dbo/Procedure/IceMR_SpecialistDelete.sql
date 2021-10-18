/****** Object:  Procedure [dbo].[IceMR_SpecialistDelete]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[IceMR_SpecialistDelete]  

@ICENUMBER varchar(15)
          
AS

SET NOCOUNT ON


DELETE MainSpecialist WHERE ICENUMBER = @ICENUMBER

DELETE MainPlaces WHERE ICENUMBER = @ICENUMBER