/****** Object:  Procedure [dbo].[usp_GetUserInfoByUserId_20201221]    Committed by VersionSQL https://www.versionsql.com ******/

--exec [usp_GetUserInfoByUserId] 16,'4B7BD117-F86D-4C64-B554-252EFC7EC2E7'

--select * from aspnetidentity.dbo.aspnetusers where username='dcmorgan'

/*
select routine_name from INFORMATION_SCHEMA.routines where routine_definition like
'%aspnetuserinfo%' and routine_name not like '%bk%' and routine_name not like '%201%'
*/
CREATE proc [dbo].[usp_GetUserInfoByUserId_20201221] @Cust_ID int, @UserId varchar(128)

as


Set NOCOUNT ON

Select Top 1
 a.Id,
a.UserName
 ,dbo.fnInitCap(IsNULL(FirstName,''))+' '+dbo.fnInitCap(IsNULL(LastName,'')) as UserFullName
 ,dbo.fnInitCap(LastName) as LastName
 ,dbo.fnInitCap(FirstName) as FirstName
 ,PhoneNumber
 ,Email as Email
 ,Department as Department
 ,Groups as Groups
 ,Supervisor as Supervisor
 ,Signature as Signature
 ,AgentId as AgentId
 ,r.[Description]
 ,r.RoleID
-- ,Cast(NULL as varchar(50)) as License
 From AspNetUsers a
 LEFT JOIN [dbo].[UserRole] ur ON a.Id = ur.UserID
 LEFT JOIN [dbo].[Role] r ON ur.RoleID = r.RoleID
 Inner Join AspNetUserInfo b on a.ID = b.UserID
 Where a.Id = @UserId
 Order by a.JoinDate Desc