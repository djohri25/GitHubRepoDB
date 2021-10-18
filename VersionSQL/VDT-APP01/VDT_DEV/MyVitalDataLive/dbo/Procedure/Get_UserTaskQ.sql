/****** Object:  Procedure [dbo].[Get_UserTaskQ]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		Spaitereddy
-- Create date: 03/21/2019
-- MODIFIED: Spaitereddy, 03/27/2019, added [dbo].[TaskActivityLog] table
-- Description:	Insert/Update user created task.
-- Execution: exec [Get_UserTaskQ] 10, 2,'dpatel'  
------------------------------------------------
--	Updates:
------------------------------------------------
--	Author		Date		Update
------------------------------------------------
--	dpatel		03/29/2019	Updated Proc to return only max record from TaskActivityLog table.
-- =============================================

CREATE procedure [dbo].[Get_UserTaskQ] 
	@CustomerId int,
	@ProductId int,
	--@StatusId int = null,
	--@PriorityId int = null,
	@User varchar(100),
	@Createdby varchar(100) = null

AS 
begin 

SET NOCOUNT ON;

drop table if exists #Status

	CREATE TABLE #Status
	(
		StatusId int
	)

insert into #Status
select 
codeid 
from Lookup_Generic_Code 
where CodeTypeID =13  and Label in ('Completed','Owner Changed')


select 
task.Id,
link.Insmemberid as MemberID, 
main.ICENUMBER as MVDID,	
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
task.UpdatedBy as UpdatedBy
from dbo.Task task
	inner join (
					select TaskId, MAX(CreatedDate) as MaxCreatedDate
					from TaskActivityLog
					Group By TaskId
				) mtd on task.Id = mtd.TaskId
	inner join [dbo].[TaskActivityLog] act on mtd.TaskId = act.TaskId and mtd.MaxCreatedDate = act.CreatedDate
	inner join  [dbo].MainPersonalDetails main
		on main.ICENUMBER=task.MVDID
	inner join [dbo].[Link_MemberId_MVD_Ins] link
		on main.ICENUMBER= link.mvdid
	inner join [dbo].MainInsurance ins
		on ins.ICENUMBER= task.MVDID
	where (act.Owner=@User or task.Author = @Createdby)
	and act.StatusId not in (select StatusId from #Status) and task.customerid=@CustomerId
	and task.ProductId=@ProductId
order by task.ReminderDate 

end