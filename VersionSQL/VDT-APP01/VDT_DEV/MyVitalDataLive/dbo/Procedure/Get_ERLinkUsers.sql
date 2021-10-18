/****** Object:  Procedure [dbo].[Get_ERLinkUsers]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[Get_ERLinkUsers]
AS
SELECT	Company, FirstName, LastName, FirstName + ' ' + LastName + ' <' + Email + '>' AS NameAndEmail
FROM	MainEMS
WHERE	Email NOT LIKE '%vitaldatatech%' AND Company NOT IN('vital data technology', 'QA Hospital', 'Hospital X') AND Active = 1
ORDER BY Company, FirstName, LastName