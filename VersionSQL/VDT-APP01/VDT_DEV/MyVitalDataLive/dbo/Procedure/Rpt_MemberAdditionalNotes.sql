/****** Object:  Procedure [dbo].[Rpt_MemberAdditionalNotes]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[Rpt_MemberAdditionalNotes]
(
	@ICENUMBER varchar(15)
)
AS
BEGIN 

SELECT CASE WHEN ISNUMERIC(P.Language) = 1 THEN L.Name ELSE P.Language END AS [Language], D.migrant as [Migrant]
FROM [dbo].[Driscoll_EligibilityAdditionalInfo] D LEFT JOIN MainPersonalDetails P ON D.ICENUMBER = P.ICENUMBER
LEFT JOIN [dbo].[LookupLanguage] L ON L.ID = CASE WHEN ISNUMERIC(P.Language) = 1 then CAST(P.Language as INT) ELSE '' END
WHERE D.ICENUMBER = @ICENUMBER 

END 