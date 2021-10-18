/****** Object:  Procedure [dbo].[Set_HPWorkflowRuleSetRunRules]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		Marc De Luca
-- Create date: 01/26/2017
-- Description:	Runs all the rules in the HPWorkflowRule table
-- Example:		EXEC dbo.Set_HPWorkflowRuleSetRunRules
-- 06/08/2017	Marc De Luca	Changed @recipients
-- 06/28/2017	Marc De Luca	Added Active flag
-- =============================================
CREATE PROCEDURE [dbo].[Set_HPWorkflowRuleSetRunRules]

AS
BEGIN

	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	-- Insert any rule not in HPWorkflowRuleSet
	INSERT INTO dbo.HPWorkflowRuleSet(RuleID,Frequency)
	SELECT Rule_ID, 'Daily'
	FROM dbo.HPWorkflowRule
	WHERE Rule_ID NOT IN (SELECT RuleID FROM dbo.HPWorkflowRuleSet)
	AND Rule_ID NOT IN (SELECT DISTINCT RuleId FROM dbo.CareFlowTask)

	DECLARE @RuleIDToRun INT, @LastRunDate DATETIME = GETUTCDATE()

	DECLARE Rule_Cursor CURSOR LOCAL FAST_FORWARD FOR
	SELECT data AS RuleIDToRun
	FROM dbo.HPWorkflowRuleSet W
	OUTER APPLY dbo.Split(W.RuleID,',')
	WHERE EXISTS (SELECT 1 FROM dbo.HPWorkflowRule R WHERE R.Active = 1 AND R.Rule_ID = W.RuleID)
	ORDER BY RuleIDToRun

	OPEN Rule_Cursor

	FETCH NEXT FROM Rule_Cursor
	INTO @RuleIDToRun

	WHILE @@FETCH_STATUS = 0
	BEGIN

		BEGIN TRY  
			EXEC dbo.Set_HPWorkflowRuleMemberList @RuleID = @RuleIDToRun

			UPDATE dbo.HPWorkflowRuleSet
			SET LastRunDate = @LastRunDate
			WHERE RuleID = @RuleIDToRun

		END TRY  
		BEGIN CATCH  

		DECLARE @MGS VARCHAR(1000), @Body VARCHAR(1000)
		
		SET @MGS = ERROR_MESSAGE()

		SET @Body =	'Rule '+CAST(@RuleIDToRun AS VARCHAR(10))+' had an error: '+@MGS+' '

		EXEC msdb.dbo.sp_send_dbmail 
		 @profile_name='VD-APP01'
		,@recipients='alerts@vitaldatatech.com'
		,@subject='WorkflowRule Error'
		,@body=@Body

--		THROW;  
		END CATCH;  

	   FETCH NEXT FROM Rule_Cursor
	   INTO @RuleIDToRun
	END

	CLOSE Rule_Cursor
	DEALLOCATE Rule_Cursor
	
END