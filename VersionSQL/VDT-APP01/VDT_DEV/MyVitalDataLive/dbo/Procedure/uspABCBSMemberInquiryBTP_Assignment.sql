/****** Object:  Procedure [dbo].[uspABCBSMemberInquiryBTP_Assignment]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[uspABCBSMemberInquiryBTP_Assignment] @MemberID varchar(30), @LOB varchar(30)

as 

SET NOCOUNT ON

-- =============================================
-- Author:		John Patrick "JP" Gregorio
-- Create date: 08/09/2019
-- Description: Inquire a specific member/lob and return the user info assigned to the member.
-- Exec uspABCBSMemberInquiryBTP_Assignment '50000215301', 'BX'
-- Exec uspABCBSMemberInquiryBTP_Assignment '60009018401', 'BH'
-- Exec uspABCBSMemberInquiryBTP_Assignment 'M6149260102', 'US'
-- https://vdt.visualstudio.com/SupportSite%204.5/_workitems/edit/1852/

-- chanages made 0923 Luna - to add middle inital
-- dpatel - 10/29/2019 - added condition in left join to check for CaseOwner to match for MemberOwner
-- =============================================

Declare @CustID int = 16
Declare @MonthID varchar(6) 


/*
Drop Table If Exists #FinalData

Select


From ComputedCareQueue a 
Inner Join LookupLOB c on a.LOB = c.source_code_name
Outer Apply (Select Top 1 * From ARBCBS_Contact_Form b Where a.MVDID = b.MVDID and b.q1ContactDate>=DATEADD(d,1,(EOMONTH(DATEADD(m,-13,GetDate())))) Order by q7ContactSuccess Desc ) b 
Where  a.MemberID = @MemberID and c.source_code = @LOB and a.MonthID = @MonthID

*/

IF NOT EXISTS (SELECT MVDID FROM ComputedCareQueue WHERE MemberID = @MemberID and LOB = @LOB)
BEGIN
	RAISERROR('Member ID not found.',16,1);
END



DROP TABLE  IF EXISTS #USERS
;
WITH CTE AS (
SELECT 
U.LastName
,UserName
,(select top 1.* from STRING_SPLIT(LTRIM(RTRIM(U.FirstName)),SPACE(1))) AS FirstName 
,SUBSTRING(LTRIM(U.FirstName),CHARINDEX(SPACE(1),LTRIM(U.FirstName))+1,LEN(LTRIM(U.FirstName))) AS MiddleInitial
FROM [AspNetIdentity].[dbo].[AspNetUsers]  U 
)


SELECT  
 UserName
,LastName
,FirstName
,CASE WHEN Firstname=MiddleInitial THEN '' ELSE MiddleInitial END AS MiddleInitial
INTO #USERS
FROM CTE 

CREATE CLUSTERED INDEX IC_Username ON #USERS(username)



select O.OwnerName	as NetworkUserName
, O.OwnerName		as NetworkID
, O.OwnerType		as Assignment
, IsNull(F.CaseProgram ,'Assignment') as Type_Case
, U.LastName
, U.FirstName
, U.MiddleInitial
--, (select top 1 * from STRING_SPLIT(LTRIM(U.FirstName),' ')) as FirstName
From ComputedCareQueue M 
left join Final_MemberOwner O 
	on O.MVDID = M.MVDID
--left join [AspNetIdentity].[dbo].[AspNetUsers] U 
--	on U.UserName = O.OwnerName
LEFT OUTER JOIN #USERS	U
	ON U.UserName = O.OwnerName

left join ABCBS_MemberManagement_Form F 
	on F.MVDID = O.MVDID 
	and IsNull(F.CaseID,'') > '' 
	and IsNull(F.q1CaseCloseDate,'1900-01-01') = '1900-01-01' and ISNULL(F.q1CaseOwner, '') = O.OwnerName
where 
M.MemberID = @MemberID 
and M.LOB = @LOB 
and O.IsDeactivated = 0