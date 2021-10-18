/****** Object:  Procedure [dbo].[Get_DiseaseIdList]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[Get_DiseaseIdList] 
As

SET NOCOUNT ON

SELECT DiseaseId, DiseaseName FROM LookupDisease ORDER BY DiseaseName