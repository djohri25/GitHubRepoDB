/****** Object:  Procedure [dbo].[Get_UserTaskQ_Hierarchy3]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[Get_UserTaskQ_Hierarchy3] 
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
Ed/Jose/Sunil	2021-01-29	Hot fix to change EXISTS to INNER/OUTER JOINs
Ed				2021-02-01	Added indexes on #Status and #GroupNames
Jose			2021-02-01	Replace temp table with table variables

EXEC Get_UserTaskQ_Hierarchy 16,2,NULL,'cahansen'

*/

BEGIN 

--DECLARE 
--	@CustomerId int = 16,
--	@ProductId int = 2,
--	@flg int = 1,
--	--@StatusId int = null,
--	--@PriorityId int = null,
--	@User varchar(100) = 'clflowers',
--	@Createdby varchar(100) = null



	DECLARE @v_customer_id int = @CustomerID;
	DECLARE @v_product_id int = @ProductID;
	DECLARE @v_user varchar(100) = @User;

	declare @v_start_time datetime = getDate();
	declare @v_end_time datetime;

-- By default, users can not see employee member data
	DECLARE @v_health_care_employee_override_yn bit = 0;

SET NOCOUNT ON;

	SELECT @v_health_care_employee_override_yn = dbo.fnABCBSUserMemberCheck( @v_user );


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


--DROP table if exists #Status

	--CREATE TABLE #Status
	--(
	--	StatusId int
	--)

Declare @Status TABLE(
StatusId int
)


--INSERT into #Status
Insert into @Status
select 
codeid 
from Lookup_Generic_Code 
where CodeTypeID =13  and Label NOT IN ('Completed','Owner Changed')

--CREATE INDEX IX_Status ON #Status( StatusId );

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
--DROP TABLE IF EXISTS #GroupNames

Declare @GroupNames TABLE (
GroupID int
)

	--CREATE TABLE #GroupNames
	--(
	--   GroupID int	)

--INSERT into #GroupNames(
Insert into @GroupNames (
GroupID
)
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


		--CREATE INDEX IX_GroupNames ON #GroupNames( GroupID );

		--DROP TABLE IF EXISTS
		--#Task;

		--CREATE TABLE #Task (
		DECLARE @Task TABLE (
			ID bigint,
			MemberID varchar(100),
			MVDID varchar(200),
			MemberFirstName varchar(200),
			MemberLastName varchar(200),
			LOB varchar(100),
			CMOrgRegion varchar(50),
			CompanyKey int,
			CompanyName varchar(100),
			County varchar(100),
			State varchar(2),
			Region varchar(100),
			Title varchar(100),
			CreatedDate datetime,
			ReminderDate datetime,
			DueDate datetime,
			StatusID int,
			PriorityID int,
			ParentTaskID bigint,
			Owner varchar(100),
			UpdatedBy varchar(100),
			GroupID int,
			TypeID int,
			RiskScore int,
			IsHealthPlanEmployee bit,
			GrpInitvCd varchar(30),
			NumOpenCases int
		);

			--INSERT INTO #Task (
			Insert into @Task (
				ID,
				MemberID,
				MVDID,
				MemberFirstName,
				MemberLastName,
				LOB,
				CMOrgRegion,
				CompanyKey,
				CompanyName,
				County,
				State,
				Region,
				Title,
				CreatedDate,
				ReminderDate,
				DueDate,
				StatusID,
				PriorityID,
				ParentTaskID,
				Owner,
				UpdatedBy,
				GroupID,
				TypeID,
				RiskScore,
				IsHealthPlanEmployee,
				GrpInitvCd,
				NumOpenCases
			)
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
			--INNER JOIN #Status s
			INNER JOIN @Status s
			ON s.StatusID = task.StatusID
			WHERE
--			(task.Owner = @v_user OR EXISTS ( SELECT 1 FROM #GroupNames WHERE GroupID = task.GroupID ))
			task.Owner = @v_user
--			AND EXISTS ( SELECT 1 FROM #Status WHERE StatusID = task.StatusID )  --act.StatusId not in (select StatusId from #Status) 
			AND task.customerid=@v_customer_id
			AND task.ProductId=@v_product_id
--			AND ( task.IsDelete = 0 or task.IsDelete is null )
			AND ISNULL( task.IsDelete, 0 ) = 0;

			--INSERT INTO #Task (
			INSERT INTO @Task (
				ID,
				MemberID,
				MVDID,
				MemberFirstName,
				MemberLastName,
				LOB,
				CMOrgRegion,
				CompanyKey,
				CompanyName,
				County,
				State,
				Region,
				Title,
				CreatedDate,
				ReminderDate,
				DueDate,
				StatusID,
				PriorityID,
				ParentTaskID,
				Owner,
				UpdatedBy,
				GroupID,
				TypeID,
				RiskScore,
				IsHealthPlanEmployee,
				GrpInitvCd,
				NumOpenCases
			)
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
			--INNER JOIN #Status s
			INNER JOIN @Status s
			ON s.StatusID = task.StatusID
			--INNER JOIN #GroupNames gn
			INNER JOIN @GroupNames gn
			ON gn.GroupID = task.GroupID
			WHERE
--			(task.Owner = @v_user OR EXISTS ( SELECT 1 FROM #GroupNames WHERE GroupID = task.GroupID ))
--			AND EXISTS ( SELECT 1 FROM #Status WHERE StatusID = task.StatusID )  --act.StatusId not in (select StatusId from #Status) 
			task.customerid=@v_customer_id
			AND task.ProductId=@v_product_id
--			AND ( task.IsDelete = 0 or task.IsDelete is null )
			AND ISNULL( task.IsDelete, 0 ) = 0;

			SELECT *
			--FROM #Task
			FROM @Task
			ORDER BY ReminderDate;

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