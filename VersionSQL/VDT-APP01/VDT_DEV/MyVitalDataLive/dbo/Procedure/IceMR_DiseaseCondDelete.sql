/****** Object:  Procedure [dbo].[IceMR_DiseaseCondDelete]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[IceMR_DiseaseCondDelete]  

@ICENUMBER varchar(15)
          
AS

SET NOCOUNT ON


DELETE MainDiseaseCond WHERE ICENUMBER = @ICENUMBER

DELETE MainSurgeries WHERE ICENUMBER = @ICENUMBER