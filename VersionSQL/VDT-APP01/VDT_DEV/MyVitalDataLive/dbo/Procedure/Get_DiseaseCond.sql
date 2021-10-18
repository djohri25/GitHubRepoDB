/****** Object:  Procedure [dbo].[Get_DiseaseCond]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[Get_DiseaseCond] 

	@ICENUMBER varchar(15)
As

Set Nocount On

SELECT DiseaseCondId, DiseaseName, DiseaseCondName
FROM LookupDisease INNER JOIN LookupDiaseseCond on
LookupDisease.DiseaseId = LookupDiaseseCond.DiseaseId