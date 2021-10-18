/****** Object:  Procedure [dbo].[Get_UserTaskQ_Hierarchy_20210129]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[Get_UserTaskQ_Hierarchy_20210129] 
	@CustomerId int,
	@ProductId int,
	@flg int = null,
	--@StatusId int = null,
	--@PriorityId int = null,
	@User varchar(100),
	@Createdby varchar(100) = null
AS 
/*

Modifications:
WHO				WHEN		WHAT
Deep			2020-06-17  removed TaskActivityLog from query to use denormalized columns
Scott			2020-06-17	Check for TaskActivityLog.
Deep			2020-06-20	Added task.TypeId column in resultset to return TaskType to front-end
Mike			2020-12-18  Trim Region in support of filtering.
Ed/Jose/Sunil	2021-01-29	Hot fix to implement parameter sniffing patch; and, use readuncommitted hint for #GroupNames query

EXEC Get_UserTaskQ_Hierarchy 

*/

begin 
	DECLARE @v_customer_id int = @CustomerID;
	DECLARE @v_product_id int = @ProductID;
	DECLARE @v_user varchar(100) = @User;

	declare @v_start_time datetime = getDate();
	declare @v_end_time datetime;

-- By default, users can not see employee member data
	DECLARE @v_health_care_employee_override_yn bit = 0;

SET NOCOUNT ON;

	SELECT @v_health_care_employee_override_yn = dbo.fnABCBSUserMemberCheck( @User );


/* Added for the future, when there is supervisor information and department info use this , join the department table to this query
*/

/*
DROP table if exists #UserTaskChart

CREATE TABLE #UserTaskChart(
	[ID] nvarchar(100)  NULL,
	[FirstName] [varchar](50) NULL,
	[LastName] [varchar](50) NULL,
	[UserName] [nvarchar](100) NULL,
	[DeptID] [int] NULL,
	[ReportToID] nvarchar(100) NULL,
	[IsSupervisorFLG] [bit] NULL)

Insert into #UserTaskChart (ID,UserName,DeptID,ReportToID,IsSupervisorFLG)
select 
m.Id, 
m.UserName,
1 as DeptID  --keeping a placeHolder -->Add when DeptID information is available
--, m.department, 
--,m.Supervisor
,aspuI.UserId as ReportToID, 
aspuI.IsSupervisorFLG as IsSupervisorFLG
from 

(select 
V.Id, 
V.UserName, 
V.department, 
V.Supervisor
from (select aspU.Id, 
aspU.UserName, 
aspuI.department, 
aspuI.UserId as SupID,
aspuI.Supervisor
 from AspNetIdentity.[dbo].[AspNetUsers] aspU
left join  AspNetIdentity.dbo.AspNetUserInfo aspuI
on aspU.Id=aspuI.UserId

) V
group by V.Id, 
V.UserName, 
V.department, 
V.Supervisor)  M
left join 
 (select UserId,Supervisor, 1 as IsSupervisorFLG from AspNetIdentity.dbo.AspNetUserInfo) aspuI
on m.UserName=aspuI.Supervisor

group by 
m.Id, m.UserName, m.department, m.Supervisor, aspuI.UserId , aspuI.IsSupervisorFLG
*/

--*/

--Keeping a placeholder for department table, Use AspNetIdentity.dbo.AspNetDepartments when data is available
--**********************************************************************************************************
/*
DROP table if exists #UserTaskDept

CREATE TABLE #UserTaskDept(
	[ID] [int] NULL,
	[DeptName] [varchar](50) NULL
) 

insert into #UserTaskDept (ID, DeptName)
select 1,'Abcbs'
*/

--**********************************************************************************************************


DROP table if exists #Status

	CREATE TABLE #Status
	(
		StatusId int
	)

INSERT into #Status
select 
codeid 
from Lookup_Generic_Code 
where CodeTypeID =13  and Label NOT IN ('Completed','Owner Changed')

/*
DROP TABLE IF EXISTS #Usernames

	CREATE TABLE #Usernames
	(
		Username varchar(100)
		, IsSupervisorFLG bit
	)

--Populate all users who do not have any reportees 

	INSERT into #Usernames
	select u.UserName as UserName, u.IsSupervisorFLG   from #UserTaskChart u
	left join #UserTaskChart c
	on u.ID=isnull(c.ReportToID,0)
	where c.ReportToId is  null and u.IsSupervisorFLG=0
*/

--Create a Group table
DROP TABLE IF EXISTS #GroupNames

	CREATE TABLE #GroupNames
	(
	   GroupID int	)


--Set the Flg to 1 as default 
/*
IF EXISTS (SELECT 1 FROM #Usernames WHERE Username =@User) 

BEGIN
SET @flg=1
END
*/


--CASE1: OWNED BY ME 
-- WORKS FOR LAST NODE AND HE IS NOT A SUPERVISOR
/*
if (@flg is null or @flg =1)

BEGIN 
*/

		INSERT into
		#GroupNames
		(GroupID)
		/*
		select
		Group_ID
		from
		Link_HPAlertGroupAgent Link
		inner join #UserTaskChart usr
		on link.Agent_ID=usr.ID
		and UserName=@User
		group by Group_ID
		*/
		select
		lhaga.Group_ID
		from
		AspnetIdentity.dbo.AspnetUsers (readuncommitted) au
		join Link_HpAlertGroupAgent (readuncommitted) lhaga
		on au.Id = lhaga.Agent_ID
		and au.UserName = @v_user;

			select 
			task.Id,
			main.memberid as MemberID, 
			main.MVDID as MVDID,	
			main.FirstName as MemberFirstName,	
			main.LastName as MemberLastName, 
			isnull(main.LOB,'') as LOB ,
			main.CmOrgRegion,
			main.CompanyKey,
			main.CompanyName,
			main.County,
			main.State,
			rtrim(main.Region) as Region,
			task.Title as Title,
			task.CreatedDate as CreatedDate,
			task.ReminderDate as ReminderDate,
			task.DueDate as DueDate,
			task.StatusId as StatusId,
			task.PriorityId as PriorityId,
			task.ParentTaskId as ParentTaskId,
			task.Owner,
			task.UpdatedBy as UpdatedBy,
			task.GroupID,
			task.TypeId,
			ISNULL(main.RiskGroupID, 0 ) as RiskScore,
			CONVERT(bit, ISNULL(main.HealthPlanEmployeeFlag, '0')) as IsHealthPlanEmployee,
			main.GrpInitvCd,
			main.OpenCaseCount as NumOpenCases
			FROM dbo.Task task (readuncommitted)
			INNER JOIN [dbo].ComputedCareQueue main (readuncommitted)
				on main.MVDID=task.MVDID
				AND
				CASE -- Enforce privacy of employee members
					WHEN main.HealthPlanEmployeeFlag = 0 THEN 1
					WHEN @v_health_care_employee_override_yn = 1 THEN 1
					ELSE 0
				END = 1
			WHERE (task.Owner = @v_user OR EXISTS ( SELECT 1 FROM #GroupNames WHERE GroupID = task.GroupID ))
			AND EXISTS ( SELECT 1 FROM #Status WHERE StatusID = task.StatusID )  --act.StatusId not in (select StatusId from #Status) 
			AND task.customerid=@v_customer_id
			AND task.ProductId=@v_product_id
--			AND ( task.IsDelete = 0 or task.IsDelete is null )
			AND ISNULL( task.IsDelete, 0 ) = 0
          ORDER BY task.ReminderDate  
/*
END
*/

--CASE2: OWNED BY ME AND PEOPLE REPORTING TO ME 

/*
IF (@FLG=2)

BEGIN

DROP TABLE IF exists #Hierarchy

--CREATE VERTICAL HIERARCHY  

		;WITH Hierarchy AS
			(
			SELECT ID,firstname,lastname,username,DeptID,reporttoid
			FROM #UserTaskChart WHERE UserName=@User -- filter by user
			UNION ALL
			SELECT a.ID,a.firstname,a.lastname,a.username,a.DeptID,a.reporttoid
			FROM #UserTaskChart a
			INNER JOIN Hierarchy b ON a.ReportToID=b.Id
			),Hierarchy1 AS 
			(
			SELECT Hierarchy.iD AS UserTaskChartId
				,e.Id AS ManagerId
				,Hierarchy.FirstName AS UserTaskChartFirstName
				,Hierarchy.LastName AS UserTaskChartLastName
				,e.FirstName AS ManagerFirstName
				,e.LastName AS ManagerLastName
				,Hierarchy.username as owner
				,e.username as ManagerOwner
				,Hierarchy.DeptID  AS EmpDepId--Emp
				,e.DeptID AS MgrDepId-- Mgr
			FROM Hierarchy
				CROSS APPLY #UserTaskChart e
			WHERE Hierarchy.Reporttoid=e.ID
			),Hierarchy2 AS 
			(
			SELECT Hierarchy.*
				,d1.DeptName AS UserTaskChartDeptName
			FROM Hierarchy1 AS Hierarchy
				LEFT JOIN #UserTaskDept AS d1
					ON Hierarchy.EmpDepId=d1.ID
			)
			SELECT Hierarchy2.UserTaskChartId
				,Hierarchy2.ManagerId
				--,Hierarchy2.UserTaskChartFirstName
				--,Hierarchy2.UserTaskChartLastName
				--,Hierarchy2.ManagerFirstName
				--,Hierarchy2.ManagerLastName
				--,Hierarchy2.UserTaskChartDeptName
				,Hierarchy2.Owner
				,Hierarchy2.ManagerOwner
				,d2.DeptName AS ManagerDeptName
	into #Hierarchy
				FROM Hierarchy2		
				LEFT JOIN #UserTaskDept AS d2
				ON Hierarchy2.MgrDepId=d2.Id
 

 --USE VERTICAL HIERARCHY IN THE EXISTING SELECT LIST 

			select 
			task.Id,
			link.Insmemberid as MemberID, 
			main.MVDID as MVDID,	
			main.FirstName as MemberFirstName,	
			main.LastName as MemberLastName, 
			isnull(ins.ProductType,'') as LOB ,
			task.Title as Title,
			task.CreatedDate as CreatedDate,
			task.ReminderDate as ReminderDate,
			act.DueDate as DueDate,
			act.StatusId as StatusId,
			act.PriorityId as PriorityId,
			task.ParentTaskId as ParentTaskId,
			act.Owner,
			task.UpdatedBy as UpdatedBy,
			act.GroupID
			from dbo.Task task
				inner join (
								select TaskId, MAX(CreatedDate) as MaxCreatedDate
								from TaskActivityLog
								Group By TaskId
							) mtd on task.Id = mtd.TaskId
				inner join [dbo].[TaskActivityLog] act on mtd.TaskId = act.TaskId and mtd.MaxCreatedDate = act.CreatedDate
				--inner join  [dbo].MainPersonalDetails main
				inner join [dbo].[ComputedCareQueue] main
					on main.MVDID=task.MVDID
					AND
-- Enforce privacy of employee members
					CASE
					WHEN main.HealthPlanEmployeeFlag = 0 THEN 1
					WHEN @v_health_care_employee_override_yn = 1 THEN 1
					ELSE 0
					END = 1
				inner join [dbo].[Link_MemberId_MVD_Ins] link
					on main.MVDID= link.mvdid
				inner join [dbo].MainInsurance ins
					on ins.ICENUMBER= task.MVDID
				where act.Owner in (select Owner from #Hierarchy) --or task.Author = @Createdby)
				and act.StatusId not in (select StatusId from #Status) and task.customerid=@CustomerId
				and task.ProductId=@ProductId
				and (task.IsDelete = 0 or task.IsDelete is null)
			order by task.ReminderDate 

END 
 
--CASE3: OWNED BY ME AND PEOPLE REPORTING TO ME + MY SUBORDINATES AND THEIR REPORTEES

IF (@FLG=3)

BEGIN 

DROP TABLE IF exists #Hierarchy_vh


--CREATE VERTICAL & HORIZONTAL HIERARCHY 
;WITH Hierarchy_vh AS
			(
			SELECT ID,firstname,lastname,username,DeptID,reporttoid
			FROM #UserTaskChart WHERE ReportToID
			in (select isnull(ReportToID,ID) from #UserTaskChart WHERE UserName=@User ) -- FILTER HERE 
			UNION ALL
			SELECT a.ID,a.firstname,a.lastname,a.username,a.DeptID,a.reporttoid
			FROM #UserTaskChart a
			INNER JOIN Hierarchy_vh b ON a.ReportToID=b.Id
			),Hierarchy_vh1 AS 
			(
			SELECT Hierarchy_vh.iD AS UserTaskChartId
				,e.Id AS ManagerId
				,Hierarchy_vh.FirstName AS UserTaskChartFirstName
				,Hierarchy_vh.LastName AS UserTaskChartLastName
				,e.FirstName AS ManagerFirstName
				,e.LastName AS ManagerLastName
				,Hierarchy_vh.username as owner
				,e.username as ManagerOwner
				,Hierarchy_vh.DeptID  AS EmpDepId--Emp
				,e.DeptID AS MgrDepId-- Mgr
			FROM Hierarchy_vh
				CROSS APPLY #UserTaskChart e
			WHERE Hierarchy_vh.Reporttoid=e.ID
			),Hierarchy_vh2 AS 
			(
			SELECT Hierarchy_vh.*
				,d1.DeptName AS UserTaskChartDeptName
			FROM Hierarchy_vh1 AS Hierarchy_vh
				LEFT JOIN #UserTaskDept AS d1
					ON Hierarchy_vh.EmpDepId=d1.ID
			)
			SELECT Hierarchy_vh2.UserTaskChartId
				,Hierarchy_vh2.ManagerId
				--,Hierarchy_vh2.UserTaskChartFirstName
				--,Hierarchy_vh2.UserTaskChartLastName
				--,Hierarchy_vh2.ManagerFirstName
				--,Hierarchy_vh2.ManagerLastName
				--,Hierarchy_vh2.UserTaskChartDeptName
				,Hierarchy_vh2.Owner
				,Hierarchy_vh2.ManagerOwner
				,d2.DeptName AS ManagerDeptName
	into #Hierarchy_vh
			FROM Hierarchy_vh2		
				LEFT JOIN #UserTaskDept AS d2
					ON Hierarchy_vh2.MgrDepId=d2.Id

 --USE VERTICAL & HORIZONTAL HIERARCHY IN THE EXISTING SELECT LIST 
	
	select 
			task.Id,
			link.Insmemberid as MemberID, 
			main.MVDID as MVDID,	
			main.FirstName as MemberFirstName,	
			main.LastName as MemberLastName, 
			isnull(ins.ProductType,'') as LOB ,
			task.Title as Title,
			task.CreatedDate as CreatedDate,
			task.ReminderDate as ReminderDate,
			act.DueDate as DueDate,
			act.StatusId as StatusId,
			act.PriorityId as PriorityId,
			task.ParentTaskId as ParentTaskId,
			act.Owner,
			task.UpdatedBy as UpdatedBy,
			act.GroupID
			from dbo.Task task
				inner join (
								select TaskId, MAX(CreatedDate) as MaxCreatedDate
								from TaskActivityLog
								Group By TaskId
							) mtd on task.Id = mtd.TaskId
				inner join [dbo].[TaskActivityLog] act on mtd.TaskId = act.TaskId and mtd.MaxCreatedDate = act.CreatedDate
				--inner join  [dbo].MainPersonalDetails main
				inner join [dbo].[ComputedCareQueue] main
					on main.MVDID=task.MVDID
					AND
-- Enforce privacy of employee members
					CASE
					WHEN main.HealthPlanEmployeeFlag = 0 THEN 1
					WHEN @v_health_care_employee_override_yn = 1 THEN 1
					ELSE 0
					END = 1
				inner join [dbo].[Link_MemberId_MVD_Ins] link
					on main.MVDID= link.mvdid
				inner join [dbo].MainInsurance ins
					on ins.ICENUMBER= task.MVDID
				where act.Owner in (select Owner from #Hierarchy_vh) --or task.Author = @Createdby)
				and act.StatusId not in (select StatusId from #Status) and task.customerid=@CustomerId
				and task.ProductId=@ProductId
				and (task.IsDelete = 0 or task.IsDelete is null)
			order by task.ReminderDate 


END
*/
	set @v_end_time = getDate();
	DECLARE @ProcName varchar(255) = OBJECT_ID(@@PROCID)
	--EXEC Set_mvdProcedureExecutionLog @ProcName,@User,NULL,@CustomerID,@ProductID,@v_start_time,@v_end_time 

	insert into mvdSProcExecutionInfo 
	(
		name,
		userid,
		username,
		customerid,
		productid,
		start_time,
		end_time
	)
	values
	(
		'Get_UserTaskQ_Hierarchy',
		NULL,
		@user,
		@customerid,
		@productid,
		@v_start_time,
		@v_end_time
	);

END