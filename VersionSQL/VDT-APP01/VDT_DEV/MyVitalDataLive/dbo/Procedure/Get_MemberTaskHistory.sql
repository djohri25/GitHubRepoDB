/****** Object:  Procedure [dbo].[Get_MemberTaskHistory]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[Get_MemberTaskHistory] 
	@CustomerId int,
	@ProductId int,
	@Mvdid varchar(20)
AS
/*

Modifications:

WHO			WHEN		WHAT
Spaitereddy 03/22/2019	Created
dpatel		03/29/2019	Updated Proc to return only most recent record from TaskActivityLog table.
dpatel		05/14/2019	Updated Proc to return only non-deleted records.
scott		06/18/2020	Updated to use denormalized columns for TaskActivity Log.  

exec Get_MemberTaskHistory 	16,	2, '168538EB24F1CA2A1F47'

*/
BEGIN
	SET NOCOUNT ON;

	 SELECT DISTINCT
			task.[Id]
			,task.[Title]
			,task.[Narrative]
			,task.[MVDID]
			,task.[CustomerId]
			,task.[ProductId]
			,task.[Author]
			,task.[Owner]
			,task.[CreatedDate]
			,task.[UpdatedDate]
			,task.[DueDate]
			,task.[ReminderDate]
			,task.[CompletedDate]
			,task.[PercentComplete]
			,task.[StatusId]
			,task.[PriorityId]
			,task.[TypeId]
			,task.[ParentTaskId]
			,task.[TaskLibraryId]
			,task.[AutomationProcId]
			,task.[SensitivityId]
			,task.[AccountingId]
			,task.[CaseId]
			,task.[UpdatedBy]
			,task.[IsDelete]
			,task.[GroupID]  
	  FROM [dbo].[Task] task
	 WHERE task.CustomerId = @CustomerId
	   AND task.ProductId = @ProductId 
	   AND task.MVDID= @Mvdid
	   AND (task.IsDelete = 0 or task.IsDelete is null)
	 ORDER BY Id DESC

END