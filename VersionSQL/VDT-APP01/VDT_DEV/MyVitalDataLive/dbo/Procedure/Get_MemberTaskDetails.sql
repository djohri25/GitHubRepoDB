/****** Object:  Procedure [dbo].[Get_MemberTaskDetails]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[Get_MemberTaskDetails] 
	@CustomerId int,
	@ProductId int,
	@TaskID int
AS
/*

Modifications:
WHO				WHEN		WHAT
Spaitereddy		03/22/2019	created
Spaitereddy		03/27/2019	added [TaskActivityLog] table 
Scott			2020-06-17	removed TaskActivityLog table due to denormalization in database.  
							Owner,DueDate,StatusID,PriorityID,GroupID all exist in tasks now.  Changes still stored in TaskActivityLog.

execution: 
EXEC Get_MemberTaskDetails 	10,	2, 217

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
		  ,task.[PriorityID]
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
	 AND task.ProductId = @ProductId AND task.[Id]=@TaskID

END