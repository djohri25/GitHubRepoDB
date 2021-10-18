/****** Object:  Procedure [dbo].[IceMR_DiseaseCondUpdate]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[IceMR_DiseaseCondUpdate]  

@ICENUMBER varchar(15),
@DiseaseCondId int,
@DiseaseId int
AS

SET NOCOUNT ON

INSERT INTO MainDiseaseCond (ICENUMBER, DiseaseCondId, DiseaseId, CreationDate, ModifyDate)
VALUES (@ICENUMBER, @DiseaseCondId, @DiseaseId, GETUTCDATE(), GETUTCDATE())