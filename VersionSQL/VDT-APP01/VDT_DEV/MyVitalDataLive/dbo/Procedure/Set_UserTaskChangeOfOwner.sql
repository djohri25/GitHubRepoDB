/****** Object:  Procedure [dbo].[Set_UserTaskChangeOfOwner]    Committed by VersionSQL https://www.versionsql.com ******/

--***************
----[Set_UserTaskChangeOfOwner]
--***************

-- =============================================
-- Author:		Spaitereddy
-- Create date: 03/15/2019
-- Description:	Get user's tasks.
-- =============================================

CREATE procedure [dbo].[Set_UserTaskChangeOfOwner]
@Json nvarchar(max),
@UserId varchar(100),
@CustomerId int,
@ProductId int

AS 
BEGIN 

set nocount on;

declare @statusid int

select @statusid =  
codeid 
from Lookup_Generic_Code 
where CodeTypeID =13  and Label='Owner Changed'



if (@Json is not null )

Begin

DROP TABLE IF EXISTS #UserTaskNew

create table #UserTaskNew
(	Id bigint,
	Owner varchar(100),
	Updatedby varchar(100))

INSERT INTO #UserTaskNew
    SELECT * FROM OPENJSON(@Json)
    WITH (Id bigint,
	Owner varchar(100),
	Updatedby varchar(100))

DROP TABLE IF EXISTS #UserTaskNewFullSet

create table #UserTaskNewFullSet 
(	[Id] [bigint] NOT NULL,
	[Title] [nvarchar](100) NOT NULL,
	[Narrative] [nvarchar](max) NOT NULL,
	[MVDID] [varchar](20) NOT NULL,
	[CustomerId] [int] NOT NULL,
	[ProductId] [int] NOT NULL,
	[Author] [varchar](100) NULL,
	[Owner] [varchar](100) NULL,
	[CreatedDate] [datetime] NOT NULL,
	[UpdatedDate] [datetime] NULL,
	[DueDate] [datetime] NULL,
	[ReminderDate] [datetime] NULL,
	[CompletedDate] [datetime] NULL,
	[PercentComplete] [tinyint] NULL,
	[StatusId] [int] NOT NULL,
	[PriorityId] [int] NOT NULL,
	[TypeId] [int] NOT NULL,
	[ParentTaskId] [bigint] NULL,
	[TaskLibraryId] [int] NULL,
	[AutomationProcId] [int] NULL,
	[SensitivityId] [int] NULL,
	[AccountingId] [int] NULL,
	[CaseId] [varchar](50) NULL,
	[UpdatedBy] [varchar](100) NULL,
	[IsDelete] [bit] NULL)

insert into #UserTaskNewFullSet (
	   [Id]
      ,[Title]
      ,[Narrative]
      ,[MVDID]
      ,[CustomerId]
      ,[ProductId]
      ,[Author]
      ,[Owner]
      ,[CreatedDate]
      ,[UpdatedDate]
      ,[DueDate]
      ,[ReminderDate]
      ,[CompletedDate]
      ,[PercentComplete]
      ,[StatusId]
      ,[PriorityId]
      ,[TypeId]
      ,[ParentTaskId]
      ,[TaskLibraryId]
      ,[AutomationProcId]
      ,[SensitivityId]
      ,[AccountingId]
      ,[CaseId]
      ,[UpdatedBy]
      ,[IsDelete])

SELECT Task.[Id]
      ,Task.[Title]
      ,Task.[Narrative]
      ,Task.[MVDID]
      ,Task.[CustomerId]
      ,Task.[ProductId]
      ,Task.[Author]
      ,Task.[Owner]
      ,Task.[CreatedDate]
      ,Task.[UpdatedDate]
      ,Task.[DueDate]
      ,Task.[ReminderDate]
      ,Task.[CompletedDate]
      ,Task.[PercentComplete]
      ,Task.[StatusId]
      ,Task.[PriorityId]
      ,Task.[TypeId]
      ,Task.[ParentTaskId]
      ,Task.[TaskLibraryId]
      ,Task.[AutomationProcId]
      ,Task.[SensitivityId]
      ,Task.[AccountingId]
      ,Task.[CaseId]
      ,Task.[UpdatedBy]
      ,Task.[IsDelete]
  FROM [dbo].[Task] Task
  inner join #UserTaskNew new 
  on new.Id= task.Id and task.Owner=new.Owner

--UPDATE THE STATUS

update #UserTaskNewFullSet
set [StatusId]=@statusid,
	[ParentTaskId]=[id]

--CHANGE THE OWNER 
update t
set t.Owner= u.Owner,
	t.UpdatedBy=u.Updatedby,
	t.UpdatedDate=GETUTCDATE()
from [Task] t 
inner join #UserTaskNew u
on t.id=u.Id and t.Owner=u.Owner

--INSERT THE NEW RECORDS FOR POPULATED LIST FOR THE CHANGED STATUS

insert into [Task] 
	(  [Title]
      ,[Narrative]
      ,[MVDID]
      ,[CustomerId]
      ,[ProductId]
      ,[Author]
      ,[Owner]
      ,[CreatedDate]
      ,[UpdatedDate]
      ,[DueDate]
      ,[ReminderDate]
      ,[CompletedDate]
      ,[PercentComplete]
      ,[StatusId]
      ,[PriorityId]
      ,[TypeId]
      ,[ParentTaskId]
      ,[TaskLibraryId]
      ,[AutomationProcId]
      ,[SensitivityId]
      ,[AccountingId]
      ,[CaseId]
      ,[UpdatedBy]
      ,[IsDelete])

select 
	   [Title]
      ,[Narrative]
      ,[MVDID]
      ,[CustomerId]
      ,[ProductId]
      ,[Author]
      ,[Owner]
      ,[CreatedDate]
      ,[UpdatedDate]
      ,[DueDate]
      ,[ReminderDate]
      ,[CompletedDate]
      ,[PercentComplete]
      ,[StatusId]
      ,[PriorityId]
      ,[TypeId]
      ,[ParentTaskId]
      ,[TaskLibraryId]
      ,[AutomationProcId]
      ,[SensitivityId]
      ,[AccountingId]
      ,[CaseId]
      ,[UpdatedBy]
      ,[IsDelete]
from 
#UserTaskNewFullSet
END

END 