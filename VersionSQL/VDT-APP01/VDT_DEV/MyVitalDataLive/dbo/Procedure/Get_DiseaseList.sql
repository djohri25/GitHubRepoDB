/****** Object:  Procedure [dbo].[Get_DiseaseList]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[Get_DiseaseList] 

@IceNumber varchar(15)
As

Set Nocount On

SELECT DiseaseId, (SELECT DiseaseName FROM LookupDisease
WHERE LookupDisease.DiseaseId = MainDiseaseCond.DiseaseId) AS DiseaseName
FROM MainDiseaseCond WHERE ICENUMBER = @ICeNumber GROUP BY DiseaseId