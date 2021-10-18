/****** Object:  Procedure [dbo].[Get_DiseaseCondList]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[Get_DiseaseCondList] 
	@ICENUMBER varchar(15),
	@DiseaseId int
As

SET NOCOUNT ON

SELECT DiseaseCondId, (SELECT DiseaseCondName FROM LookupDiseaseCond WHERE
LookupDiseaseCond.DiseaseCondId = MainDiseaseCond.DiseaseCondId) AS DiseaseCondName , 
ChkImg = '../images/checked_grey.gif',
IsCheck = CONVERT(bit, 1)
FROM MainDiseaseCond WHERE DiseaseId = @DiseaseId
AND ICENUMBER = @ICENUMBER