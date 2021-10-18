/****** Object:  Procedure [dbo].[Get_Task_Log]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[Get_Task_Log] (@TaskID bigint)
AS
/*

Modifications:
WHO		WHEN		WHAT
Scott	2020-08-17	Created for ticket #3309


EXEC Get_Task_Log @TaskID = 166

*/
BEGIN

	SELECT TaskID,
			[Owner],
			DueDate,
			StatusID,
			PriorityID,
			CreatedDate,
			CreatedBy,
			ReasonForUpdate,
			ID,
			GroupID 
	FROM	TaskActivityLog
	WHERE	TaskID = @TaskID 
	ORDER BY CreatedDate DESC

END