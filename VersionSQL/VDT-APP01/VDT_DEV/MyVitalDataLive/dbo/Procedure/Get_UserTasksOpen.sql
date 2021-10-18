/****** Object:  Procedure [dbo].[Get_UserTasksOpen]    Committed by VersionSQL https://www.versionsql.com ******/

--***************
----[Get_UserTasksOpen]
--***************

-- =============================================
-- Author:		Spaitereddy
-- Create date: 03/15/2019
-- Description:	Get user's tasks.
-- =============================================

CREATE PROCEDURE [dbo].[Get_UserTasksOpen] 
	@UserId varchar(100),
	@CustomerId int,
	@ProductId int,
	@Mvdid varchar(20)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT [Id]
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
      --,[IsDelete]
  FROM [dbo].[Task]
    where [Owner] = @UserId
		and CustomerId = @CustomerId
		and ProductId = @ProductId  and MVDID= @Mvdid
		and StatusId in (select codeid 
from Lookup_Generic_Code 
where CodeTypeID in (13,14,15)  and Label<>'Completed')

End