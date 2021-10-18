/****** Object:  Procedure [dbo].[Get_UserTaskQ_Hierarchy_EZ]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[Get_UserTaskQ_Hierarchy_EZ] 
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

EXEC Get_UserTaskQ_Hierarchy 16,2,NULL,'executive1'

exec Get_UserTaskQ_Hierarchy @User=N'amearnest',@CustomerId=16,@ProductId=2,@flg=1

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

DROP table if exists #Status

CREATE TABLE #Status
(
	StatusId int
)


INSERT into #Status
select 
	codeid 
from 
	Lookup_Generic_Code (readuncommitted)
where 
	CodeTypeID =13  and Label NOT IN ('Completed','Owner Changed')

--Create a Group table
DROP TABLE IF EXISTS #GroupNames

CREATE TABLE #GroupNames (
GroupID int	
)

CREATE INDEX IX_GroupNames ON #GroupNames ( GroupID )

INSERT into #GroupNames (
GroupID
)
select
	lhaga.Group_ID
from
	AspnetIdentity.dbo.AspnetUsers (readuncommitted) au
	join Link_HpAlertGroupAgent (readuncommitted) lhaga
		on au.Id = lhaga.Agent_ID
		and au.UserName = @v_user;

;WITH [cteTask] as (
select
	task.Id,
	task.MVDID,
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
	task.TypeId--,
FROM dbo.Task task (readuncommitted)
WHERE
	task.Owner = @v_user 
	AND task.customerid=@v_customer_id
	AND task.ProductId=@v_product_id
	AND ISNULL( task.IsDelete, 0 ) = 0
UNION
SELECT
	task.Id,
	task.MVDID,
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
	task.TypeId--,
FROM dbo.Task task (readuncommitted)
JOIN #GroupNames gn
	ON gn.GroupID = task.GroupID
WHERE
	task.customerid=@v_customer_id
	AND task.ProductId=@v_product_id
	AND ISNULL( task.IsDelete, 0 ) = 0

)--,
select --top 100 percent
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
	main.OpenCaseCount as NumOpenCases--,
	--gn.GroupID [GroupGroupID]
FROM [cteTask] task
	INNER JOIN [dbo].ComputedCareQueue main (readuncommitted)
		on main.MVDID=task.MVDID
			AND
			CASE -- Enforce privacy of employee members
				WHEN main.HealthPlanEmployeeFlag = 0 THEN 1
				WHEN @v_health_care_employee_override_yn = 1 THEN 1
				ELSE 0
			END = 1
	INNER JOIN #Status s ON s.StatusID = task.StatusID

--)
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