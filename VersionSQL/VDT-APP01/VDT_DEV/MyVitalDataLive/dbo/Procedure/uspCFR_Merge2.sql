/****** Object:  Procedure [dbo].[uspCFR_Merge2]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[uspCFR_Merge2]	(@MVDProcedureName varchar(255), 
                                         @CustID int, 
										 @ProductID int, 
										 @OwnerGroup varchar(1000) = NULL
										 )
AS
/*

	This procedure accepts a stored procedure (by name) that only returns a list of MVDID varchar(50).  
	1)  It will	lookup the Rule_ID from the HPWorkflowRule by using the [body] field.  
	2)  It will use the @OwnerGroup as a comma delimited list to check the linkage between the Rule and 
	    the Groups it is registered to in Link_HPRuleAlertGroup.  It will add/remove linkage per the parameter.
	3)  It will use the CustID and ProductID as it adds members to the Care Flow Task queue for the RuleID.  GroupID
	    will be added as NULL and is not supported in the CareFlowTask table.
	4)  It will log the Group linkage in the CFR_JobHistory_Merge table.

Changes
WHO		WHEN		WHAT
Scott	20201020	Create as MERGE CFR only
Scott	20201102	Update history to record ModifiedDate as GETUTCDATE and ModifiedBy as 'MERGE' 
Scott	2020-11-21  Move to production
Scott	2020-11-24	Change Histoy insert to  [VD-ARCH].Archive_MyVitalDataLive.dbo.CareFlowTaskHistory.
Scott   2021-05-26  ADD ID to @History and OUTPUT to capture in CareFlowTaskHistory
Scott	2021-09-02	Add index to temp table
Scott	2021-10-26  Modify parameters and change logic to ensure proper Rule ID and Group linkage.

EXEC uspCFR_Merge2 @MVDProcedureName = 'uspCFR_Homelessness_MVDID', @CustID = 16, @ProductID = 2, @OwnerGroup = 'RulesReview'

SELECT * FROM CFR_JobHistory_Merge ORDER BY StartTime DESC --job log for task performance

SELECT * FROM CareFlowTaskHistory	--records removed from CareFlowTask queue

SELECT * FROM HPWorkFlowRule 
SELECT * FROM HPAlertGroup
SELECT * FROM CareFlowTask WHERE RuleID = 306
SELECT * FROM Link_HPRuleAlertGroup WHERE Rule_ID = 306
SELECT * FROM CFR_JobHistory_Merge ORDER BY StartTime DESC

*/

BEGIN
BEGIN TRY

SET NOCOUNT ON;

PRINT 'Processing '+@MVDProcedureName+' '+CAST(getdate() AS VARCHAR)

DECLARE @StartTime datetime
DECLARE @EndTime datetime 
DECLARE @Err_Msg varchar(1000) =''
DECLARE @Msg varchar(1000) = ''
DECLARE @Records int = 0
DECLARE @RuleID int 

	SET @StartTime = GETDATE()

GetRuleID:

	SELECT @RuleID = Rule_ID FROM HPWorkflowRule WHERE Cust_ID = @CustID AND Query = 'SP' AND Body = @MVDProcedureName

	IF @RuleID IS NULL
		BEGIN
			SET @Msg = 'The procedure named ' + @MVDProcedureName + ' is not registered in HPWorkflowRule.'
			GOTO SaveStatistics
		END

GetOwnerGroups:
		--SELECT Rule_ID, COUNT(*) FROM Link_HPRuleAlertGroup GROUP BY Rule_ID HAVING COUNT(*) > 1
		DECLARE @LinkGroup TABLE (ID int IDENTITY, Rule_ID int, AlertGroup_ID int)

		--get Link Group IDs for parameter
		INSERT INTO @LinkGroup (Rule_ID, AlertGroup_ID)
		SELECT @RuleID, ID  
		  FROM HPAlertGroup	ag	 
		 WHERE ag.[Name] IN (SELECT LTRIM(RTRIM(value)) FROM STRING_SPLIT(@OwnerGroup,','))

		 IF (SELECT 1 FROM @LinkGroup) IS NULL
			BEGIN
				SET @Msg = CHAR(9) + @MVDProcedureName + '(' + CAST(@RuleID AS varchar) + ') is missing group linkage in Link_HPRuleAlertGroup.'
				PRINT @Msg
				--If all the linkage is gone, should we remove the rule from the CareQueue?
				--DELETE FROM CareFlowTask WHERE RuleID = @RuleID
				GOTO SaveStatistics
			END

		 MERGE Link_HPRuleAlertGroup AS target
		 USING (SELECT Rule_ID,
		               AlertGroup_ID
				  FROM @LinkGroup ) AS source (Rule_ID, AlertGroup_ID)
			ON (Target.Rule_ID = Source.Rule_ID AND Target.AlertGroup_ID = Source.AlertGroup_ID) 
			--remove any group links not in the parameter
		  WHEN NOT MATCHED BY Source AND Target.Rule_ID = @RuleID THEN DELETE 
		    --add any group links in the parameter not in the table
          WHEN NOT MATCHED BY Target THEN
		INSERT (Rule_ID, AlertGroup_ID) VALUES (source.Rule_ID, source.AlertGroup_ID);

		SELECT @Msg += [Name] + ', ' 
		  FROM Link_HPRuleAlertGroup rag
		  JOIN HPAlertGroup ag ON rag.AlertGroup_ID = ag.ID
		 WHERE Rule_ID = @RuleID
		 ORDER BY [Name]

		 PRINT CHAR(9) + 'Link Group(s) for RuleID (' + CAST(@RuleID AS varchar) + ') = ' + LEFT(@Msg,LEN(@Msg)-1)

GetMembers:

DROP TABLE IF EXISTS #MVDID
CREATE TABLE #MVDID (MVDID varchar(50))

	--Get the MVDIDs from the procedure that was passed in the parameters.
	INSERT #MVDID (MVDID)
	EXEC(@MVDProcedureName) 

	CREATE INDEX IX_MVDID ON #MVDID (MVDID)

CheckResultsAgainstExisitng:
	--this section will prevent the dramatic removal of members from the queue in the event of a computed table 
	--that doesn't complete well.  It will terminate the procedure in the event of an unexpected 25% drop in volume.
	DECLARE @CurrentRecordCount float, @NewRecordCount float

	SELECT @NewRecordCount = COUNT(*), @Records = COUNT(*) FROM #MVDID
	--currently disabled
	--SELECT @CurrentRecordCount = COUNT(*) FROM CareFlowTask WHERE RuleID = @RuleID AND CustomerID = @CustID
	
	--IF @CurrentRecordCount <> 0 AND ABS(1 - @NewRecordCount/@CurrentRecordCount) > .25 
	--BEGIN
	--  SET @Msg = 'Procedure aborted due to calculated drop in volumne of more than 25%.'
	--	GOTO ProcedureEnd
	--END

DECLARE @History TABLE (ID bigint, MVDID varchar(50), RuleId smallint, ExpirationDate datetime, CreatedDate datetime, CreatedBy varchar(20), 
						UpdatedDate datetime, UpdatedBy varchar(20), ProductID int, OwnerGroup int, CustomerID int, StatusId int)

MergeMembersWithCareflowTask:	

			MERGE CareflowTask AS Target  
			USING (SELECT DISTINCT m.MVDID, 
			              @RuleID AS RuleID,
						  '99991231' ExpirationDate,
						  GETDATE() AS CreatedDate,
						  'WORKFLOW' AS CreatedBy,
						  GETDATE() AS UpdatedDate,
						  'WORKFLOW' AS UpdatedBy,
						  @ProductID AS ProductID,
						  NULL AS OwnerGroup,
						  @CustID CustomerID, 
						  278 AS StatusID
					 FROM #MVDID m
				   ) AS Source (MVDID, RuleId, ExpirationDate, CreatedDate, CreatedBy, UpdatedDate, UpdatedBy, ProductID,OwnerGroup,CustomerID, StatusID)  
				ON (Target.MVDID = Source.MVDID AND Target.RuleID = Source.RuleID)   
              WHEN NOT MATCHED BY Source AND Target.RuleID = @RuleID THEN DELETE  --If the rule no longer applies then delete them
              WHEN NOT MATCHED BY Target THEN		 --This is a new rule not in the task queue.  Add it.
			       INSERT (MVDID, RuleId, ExpirationDate, CreatedDate, CreatedBy, UpdatedDate, UpdatedBy, ProductId, OwnerGroup, CustomerId, StatusId)
			       VALUES (Source.MVDID, 
					       Source.RuleId, 
					       Source.ExpirationDate, 
					       Source.CreatedDate, 
					       Source.CreatedBy, 
					       Source.UpdatedDate, 
					       Source.UpdatedBy, 
					       Source.ProductID, 
					       Source.OwnerGroup,
						   Source.CustomerID, 
					       Source.StatusID
						   )
		    OUTPUT Deleted.ID, Deleted.MVDID, Deleted.RuleID, Deleted.ExpirationDate, Deleted.CreatedDate, Deleted.CreatedBy, Deleted.UpdatedDate, 
			       Deleted.UpdatedBy, Deleted.ProductID, Deleted.OwnerGroup, Deleted.CustomerID, Deleted.StatusID INTO @History;

SaveHistory:
	--the archive to a cloud table times out and is disabled.  History is logged locally.	
    --INSERT [VD-ARCH].Archive_MyVitalDataLive.dbo.CareFlowTaskHistory (MVDID,RuleID,ExpirationDate,CreatedDate,CreatedBy,UpdatedDate,UpdatedBy, ProductID, CustomerID,StatusID, OwnerGroup)

	INSERT CareFlowTaskHistory (ID, MVDID, RuleID, ExpirationDate, CreatedDate, CreatedBy, UpdatedDate, UpdatedBy, ProductID, OwnerGroup, CustomerID, StatusID)
	SELECT ID, MVDID, RuleID, ExpirationDate, CreatedDate, CreatedBy, GETUTCDATE(), 'MERGE', ProductID, OwnerGroup, CustomerID, StatusID FROM @History WHERE MVDID IS NOT NULL

SaveStatistics:

	SET @EndTime = GETDATE()

	INSERT CFR_JobHistory_Merge (ProcedureName, CustID, RuleID, ProductID, OwnerGroup, StartTime, EndTime, Records, Comment)
	SELECT @MVDProcedureName, @CustID, @RuleID, @ProductID, NULL AS OwnerGroup, @StartTime, @EndTime, @Records, @Msg

	--SELECT * FROM CFR_JobHistory_Merge WHERE RuleID = 306 ORDER BY StartTime DESC

ProcedureEnd:

	RETURN

END TRY
BEGIN CATCH

    SET @Err_Msg = ERROR_MESSAGE()
	SET @EndTime = GETDATE()

	INSERT CFR_JobHistory_Merge (ProcedureName, CustID, RuleID, ProductID, OwnerGroup, StartTime, EndTime, Records, Comment)
	SELECT @MVDProcedureName, @CustID, @RuleID, @ProductID, NULL AS OwnerGroup, @StartTime, @EndTime, @Records, @Err_Msg

END CATCH

END