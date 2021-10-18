/****** Object:  Procedure [dbo].[Report_UserLoad]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[Report_UserLoad]   @CaseManager		varchar(MAX) = 'ALL'
AS
/*
Author:			Mike Grover
Create date:	2021-03-15
Description:	Generate data for ABCBS dashboard widget and report 
				called User Load Report
Ticket:			4865

Changes
WHO		WHEN		WHAT
Mike	20210315	Created
Scott	20210521	Add TaskCountByReferral and OverdueTaskCountByReferral 

exec [dbo].Report_UserLoad @CaseManager = 'ALL'

SELECT * FROM Dash_Taskage

*/

BEGIN

	DROP TABLE IF EXISTS #users
	DROP TABLE IF EXISTS #userInfo
	
	select distinct ID, UserName, FirstName, LastName into #users from [AspNetIdentity].[dbo].AspNetUsers
	select distinct UserID,Department,Supervisor into #userInfo from [AspNetIdentity].[dbo].AspNetUserInfo

	select Department
		,LOB
		,CmOrgRegion
		,Supervisor
		,username
		,LastName
		,FirstName
		,sum(CaseCount) as CaseCount
		,sum(FollowCount) as FollowCount
		,sum(TaskCount ) as TaskCount
		,sum(OverDueTask) as OverDueTaskCount
		,sum(Referral) AS TaskCountByReferral 
		,sum(ReferralOverdue) AS OverdueTaskCountByReferral 
	from (
	select 
		ANI.Department
		,CA.LOB
		,CA.CmOrgRegion
		,CA.Company_Name
		,ANI.Supervisor
		,AN.username
		,AN.LastName
		,AN.FirstName
		,count(CA.ID) as CaseCount
		,0 as FollowCount
		,0 as TaskCount
		,0 as OverDueTask
		,0 Referral
		,0 ReferralOverdue
	from #users AN
	join #userInfo ANI on AN.ID = ANI.UserID
	join [dbo].[dash_caseage] CA on CA.CaseOwner = AN.UserName
	where CA.FollowMember = 'No'
	group by ANI.Department, CA.LOB, CA.CmOrgRegion, CA.company_name, ANI.Supervisor, AN.username, AN.LastName, AN.FirstName
	union
	select 
		ANI.Department
		,CA.LOB
		,CA.CmOrgRegion
		,CA.Company_Name
		,ANI.Supervisor
		,AN.username
		,AN.LastName
		,AN.FirstName
		,0 as CaseCount
		,count(CA.ID) as FollowCount
		,0 as TaskCount
		,0 as OverDueTask
		,0 Referral
		,0 ReferralOverdue
	from #users AN
	join #userInfo ANI on AN.ID = ANI.UserID
	join [dbo].[dash_caseage] CA on CA.CaseOwner = AN.UserName
	where CA.FollowMember = 'Yes'
	group by ANI.Department, CA.LOB, CA.CmOrgRegion, CA.company_name, ANI.Supervisor, AN.username, AN.LastName, AN.FirstName
	union
	select 
		ANI.Department
		,TA.LOB
		,TA.CmOrgRegion
		,TA.Company_Name
		,ANI.Supervisor
		,AN.username
		,AN.LastName
		,AN.FirstName
		,0 as CaseCount
		,0 as FollowCount
		,count(TA.ID) as TaskCount 
		,sum(case when TA.DaysPastDue > 0 then 1 else 0 end) as OverDueTask
		,SUM(CASE WHEN ta.Referral = 1 THEN 1 ELSE 0 END) Referral
        ,SUM(CASE WHEN ta.DaysPastDue > 0 AND ta.Referral = 1 THEN 1 ELSE 0 END) ReferralOverdue
	from #users AN
	join #userInfo ANI on AN.ID = ANI.UserID
	join [dbo].[dash_taskage] TA on TA.Owner = AN.UserName
	group by ANI.Department, TA.LOB, TA.CmOrgRegion, TA.company_name, ANI.Supervisor,AN.username, AN.LastName, AN.FirstName
	) a
	WHERE @CaseManager = 'ALL' or a.Supervisor = @CaseManager
	group by LOB, CmOrgRegion,Department, Supervisor, username, LastName, FirstName
	order by LOB, CmOrgRegion,Department, Supervisor, username, LastName, FirstName
END