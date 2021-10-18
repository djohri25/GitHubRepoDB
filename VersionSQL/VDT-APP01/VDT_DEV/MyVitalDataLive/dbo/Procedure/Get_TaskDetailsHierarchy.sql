/****** Object:  Procedure [dbo].[Get_TaskDetailsHierarchy]    Committed by VersionSQL https://www.versionsql.com ******/

--***************
----Get_TaskDetailsHierarchy
--***************

-- =============================================
-- Author:		Spaitereddy
-- Create date: 03/15/2019
-- Description:	Get user's tasks.
-- =============================================


CREATE procedure [dbo].[Get_TaskDetailsHierarchy]
	@CustomerId int,
	@ProductId int,
	@StatusId int = null,
	@PriorityId int = null,
	@User varchar(100),
	@Createdby varchar(100) = null

AS 
begin 

SET NOCOUNT ON;

select 
@StatusId= codeid 
from Lookup_Generic_Code 
where CodeTypeID =13 and Label='Completed'


select 
link.Insmemberid as MemberID, 
main.ICENUMBER as MVDID,	
main.FirstName as MemberFirstName,	
main.LastName as MemberLastName, 
isnull(ins.ProductType,'') as LOB ,
task.CreatedDate as TaskCreatedDT,
task.DueDate as DueDate,
task.StatusId as Status,
task.PriorityId as Priority,
task.ParentTaskId as ParentTaskId,
task.UpdatedBy as UpdatedBy
from task task
inner join  MainPersonalDetails main
	on main.ICENUMBER=task.MVDID
inner join [Link_MemberId_MVD_Ins] link
	on main.ICENUMBER= link.mvdid
inner join MainInsurance ins
	on ins.ICENUMBER= task.MVDID
inner join task task1
on task.Id=task1.ParentTaskId
where (task.Owner=@User or TASK.Author = @Createdby)
and task.StatusId<>@StatusId and task.customerid=@CustomerId
and task.ProductId=@ProductId

end