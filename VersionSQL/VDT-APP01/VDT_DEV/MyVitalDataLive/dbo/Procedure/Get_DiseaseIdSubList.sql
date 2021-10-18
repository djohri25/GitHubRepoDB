/****** Object:  Procedure [dbo].[Get_DiseaseIdSubList]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- Example:		EXEC dbo.Get_DiseaseIdSubList @CondId = 17, @IceNumber = 'L27JX35FQ6'
-- Changes:		04/24/2017	Marc De Luca	Changes the old style joins to normal joins.  The SQL Server data migration assistant pointed this out.

CREATE PROCEDURE [dbo].[Get_DiseaseIdSubList] 
	@CondId int,
	@IceNumber varchar(15)
AS

BEGIN

SET NOCOUNT ON

	SELECT DiseaseCondId, DiseaseCondName, CONVERT(bit, 0) AS isChecked
	INTO #DiseaseCond
	FROM dbo.LookupDiseaseCond 
	WHERE DiseaseId = @CondId 

	UPDATE D 
	SET isChecked = 1 
	FROM #DiseaseCond D
	JOIN dbo.MainDiseaseCond M ON D.DiseaseCondId = M.DiseaseCondId
	AND ICENUMBER = @IceNumber

	SELECT DiseaseCondId, DiseaseCondName, isChecked
	FROM #DiseaseCond 
	ORDER BY DiseaseCondName

END