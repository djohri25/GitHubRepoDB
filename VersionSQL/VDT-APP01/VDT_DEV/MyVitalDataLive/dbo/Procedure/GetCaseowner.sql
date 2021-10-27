/****** Object:  Procedure [dbo].[GetCaseowner]    Committed by VersionSQL https://www.versionsql.com ******/

--CREATEd by : Sunil N
--Date: 04/23/2019
--EXEC [GetCaseowner] 'Case Management,Chronic Condition Management,Clinical Support,Maternity,Social Work' 

CREATE PROCEDURE [dbo].[GetCaseowner] ( @p_caseprogram varchar(max))
AS
BEGIN

SET NOCOUNT ON;
DECLARE @SQL varchar(max)
DECLARE @SqlCaseProgram varchar(max)

SET @SQL = '
SELECT DISTINCT  REPLACE(mmf.q1caseowner, ''.'','' '') q1caseowner, mmf.q1caseowner caseownervalue, anu.FirstName, anu.LastName
FROM 
ABCBS_MemberManagement_Form mmf
INNER JOIN [AspNetIdentity].[dbo].[AspNetUsers] anu ON mmf.q1caseowner = anu.UserName
WHERE caseprogram IN ' 

SET @SqlCaseProgram = ' (select VALUE from [dbo].[SplitStringVal]('''+@p_caseprogram+''','',''))'

SET @SQL = @SQL + @SqlCaseProgram + '
AND q1caseowner IS NOT NULL 
AND q1caseowner <>'''' Order By 1'

PRINT(@SQL)
EXEC(@SQL)


END