/****** Object:  Procedure [dbo].[Get_HealthTest]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[Get_HealthTest] 
	@ICENUMBER varchar(15),
	@Language BIT = 1
As

SET NOCOUNT ON

SELECT TestId, 
(
SELECT TOP 1 
	CASE @Language
		WHEN  1 
			THEN TestName
		WHEN 0 
			THEN TestNameSpanish 
	END 
FROM LookupHealthTest WHERE
LookupHealthTest.TestId = MainHealthTest.TestId) AS TestName
FROM MainHealthTest
WHERE ICENUMBER = @ICENUMBER
GROUP BY TestId