/****** Object:  Procedure [dbo].[usp_GetUserNameInfo]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		Sunil Nokku, JP , Noha
-- Create date: 08/02/2019
-- Description:	To get user details
-- Changes:		Added AgentID
-- Changes:13/11:Sunil:		Added condition to pick up records which have Signature and Agent.
-- =============================================

CREATE proc [dbo].[usp_GetUserNameInfo] @Cust_ID int, @UserName varchar(60)

as


Set NOCOUNT ON

--UserFullName
--UserFirstName
--UserLastName
--UserPhone
--UserPhoneExtension
--UserEmail
--UserDepartment
--UserGroups
--UserSupervisor
--UserSignature
--UserLicense
--AgentId

 Select Top 1
a.UserName
 ,dbo.fnInitCap(IsNULL(LTRIM(RTRIM(FirstName)),''))+' '+dbo.fnInitCap(IsNULL(LTRIM(RTRIM(LastName)),'')) as UserFullName
 ,dbo.fnInitCap(LastName) as UserLastName
 ,dbo.fnInitCap(FirstName) as UserFirstName
 ,ISNULL(PhoneNumber,'00000') as UserPhone
 ,Cast(NULL as varchar(50)) as UserPhoneExt
 ,Email as UserEmail
 ,Department as UserDeparment
 ,Groups as UserGroups
 ,Supervisor as UserSupervisor
 ,Signature as UserSignature
 ,Cast(NULL as varchar(50)) as UserLicense
 ,AgentId as AgentId --new column
 From AspNetUsers a Inner Join AspNetUserInfo b on a.ID = b.UserID
 Where a.UserName = @UserName
 Order by
CASE
WHEN b.Signature IS NOT NULL THEN 0
ELSE 1
END,
a.JoinDate Desc