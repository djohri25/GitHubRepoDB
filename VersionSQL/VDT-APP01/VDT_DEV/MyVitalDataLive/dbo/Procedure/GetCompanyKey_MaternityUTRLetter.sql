/****** Object:  Procedure [dbo].[GetCompanyKey_MaternityUTRLetter]    Committed by VersionSQL https://www.versionsql.com ******/

/*
Name : Sunil N
date: 05/11/2020
*/

CREATE PROCEDURE [dbo].[GetCompanyKey_MaternityUTRLetter] ( 
	@ID		INT)
AS
BEGIN

SET NOCOUNT ON;

SELECT c.Company_Key
FROM
LookupCompanyName c
INNER JOIN FinalMember f on f.CompanyKey = c.company_key
INNER JOIN LetterMembers l on l.MemberID = f.MemberID
WHERE 
	L.[LetterType] IN (15,16)
	AND L.ID = @ID
END