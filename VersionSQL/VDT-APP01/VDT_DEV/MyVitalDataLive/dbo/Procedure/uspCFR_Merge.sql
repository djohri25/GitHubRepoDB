/****** Object:  Procedure [dbo].[uspCFR_Merge]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[uspCFR_Merge]	(@MVDProcedureName varchar(255), 
                                         @CustID int, 
										 @RuleID int, 
										 @ProductID int, 
										 @OwnerGroup int)
AS
/*

	This procedure accepts a stored procedure (by name) that only returns a list of MVDID varchar(50).  It will
	use the CustID, RuleID, ProductID, and Owner Group to add these members to the Care Flow Task queue for the RuleID.

Changes
WHO		WHEN		WHAT
Scott	20201020	Create as MERGE CFR only
Scott	20201102	Update history to record ModifiedDate as GETUTCDATE and ModifiedBy as 'MERGE' 
Scott	2020-11-21  Move to production
Scott	2020-11-24	Change Histoy insert to  [VD-ARCH].Archive_MyVitalDataLive.dbo.CareFlowTaskHistory.
Scott   2021-05-26  ADD ID to @History and OUTPUT to capture in CareFlowTaskHistory
Scott	2021-09-02	Add index to temp table

EXEC uspCFR_Merge @MVDProcedureName = 'uspCFR_Cancer_MVDID', @CustID = 16, @RuleID = 209, @ProductID = 2, @OwnerGroup = 162

SELECT * FROM CFR_JobHistory_Merge --job log for task performance

SELECT * FROM CareFlowTaskHistory	--records removed from CareFlowTask queue

*/

BEGIN
BEGIN TRY

SET NOCOUNT ON;

PRINT 'Processing '+@MVDProcedureName+' '+CAST(getdate() AS VARCHAR)

DECLARE @StartTime datetime, @EndTime datetime, @Err_Msg varchar(1000), @Records int = 0

DROP TABLE IF EXISTS #MVDID
CREATE TABLE #MVDID (MVDID varchar(50))

	SET @StartTime = GETDATE()
	--Get the MVDIDs from the procedure that was passed in the parameters.
	INSERT #MVDID (MVDID)
	EXEC(@MVDProcedureName) 

	CREATE INDEX IX_MVDID ON #MVDID (MVDID)

	SET @EndTime = GETDATE()

CheckResultsAgainstExisitng:

	DECLARE @CurrentRecordCount float, @NewRecordCount float

	SELECT @NewRecordCount = COUNT(*), @Records = COUNT(*) FROM #MVDID
	--SELECT @CurrentRecordCount = COUNT(*) FROM CareFlowTask WHERE RuleID = @RuleID AND CustomerID = @CustID
	
	--IF @CurrentRecordCount <> 0 AND ABS(1 - @NewRecordCount/@CurrentRecordCount) > .15 
	--BEGIN
	--	GOTO ProcedureEnd
	--END

DECLARE @History TABLE (ID bigint, MVDID varchar(50), RuleId smallint, ExpirationDate datetime, CreatedDate datetime, CreatedBy varchar(20), 
						UpdatedDate datetime, UpdatedBy varchar(20), ProductID int, CustomerID int, StatusId int , OwnerGroup smallint)

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
						  @CustID CustomerID, 
						  278 AS StatusID, 
						  @OwnerGroup AS OwnerGroup
					 FROM #MVDID m
				   ) AS Source (MVDID, RuleId, ExpirationDate, CreatedDate, CreatedBy, UpdatedDate, UpdatedBy, ProductID, CustomerID, StatusID, OwnerGroup)  
				ON (Target.MVDID = Source.MVDID AND Target.RuleID = Source.RuleID)   
              WHEN NOT MATCHED BY Source AND Target.RuleID = @RuleID THEN DELETE  --If the rule no longer applies then delete them
              WHEN NOT MATCHED BY Target THEN		 --This is a new rule not in the task queue.  Add it.
			       INSERT (MVDID, RuleId, ExpirationDate, CreatedDate, CreatedBy, UpdatedDate, UpdatedBy, ProductId, CustomerId, StatusId, OwnerGroup)
			       VALUES (Source.MVDID, 
					       Source.RuleId, 
					       Source.ExpirationDate, 
					       Source.CreatedDate, 
					       Source.CreatedBy, 
					       Source.UpdatedDate, 
					       Source.UpdatedBy, 
					       Source.ProductID, 
					       Source.CustomerID, 
					       Source.StatusID, 
					       Source.OwnerGroup)
		    OUTPUT Deleted.ID, Deleted.MVDID, Deleted.RuleID, Deleted.ExpirationDate, Deleted.CreatedDate, Deleted.CreatedBy, Deleted.UpdatedDate, Deleted.UpdatedBy, Deleted.ProductID, Deleted.CustomerID, Deleted.StatusID, Deleted.OwnerGroup INTO @History;

SaveHistory:

    --INSERT [VD-ARCH].Archive_MyVitalDataLive.dbo.CareFlowTaskHistory (MVDID,RuleID,ExpirationDate,CreatedDate,CreatedBy,UpdatedDate,UpdatedBy, ProductID, CustomerID,StatusID, OwnerGroup)
	INSERT CareFlowTaskHistory (ID, MVDID, RuleID, ExpirationDate, CreatedDate, CreatedBy, UpdatedDate, UpdatedBy, ProductID, CustomerID, StatusID, OwnerGroup)
	SELECT ID, MVDID, RuleID, ExpirationDate, CreatedDate, CreatedBy, GETUTCDATE(), 'MERGE', ProductID, CustomerID, StatusID, OwnerGroup FROM @History WHERE MVDID IS NOT NULL

SaveStatistics:

	INSERT CFR_JobHistory_Merge (ProcedureName, CustID, RuleID, ProductID, OwnerGroup, StartTime, EndTime, Records)
	SELECT @MVDProcedureName, @CustID, @RuleID, @ProductID, @OwnerGroup, @StartTime, @EndTime, @Records

ProcedureEnd:

	RETURN

END TRY
BEGIN CATCH

    SET @Err_Msg = ERROR_MESSAGE()
	SET @EndTime = GETDATE()

	INSERT CFR_JobHistory_Merge (ProcedureName, CustID, RuleID, ProductID, OwnerGroup, StartTime, EndTime, Records, Comment)
	SELECT @MVDProcedureName, @CustID, @RuleID, @ProductID, @OwnerGroup, @StartTime, @EndTime, @Records, @Err_Msg

END CATCH

END