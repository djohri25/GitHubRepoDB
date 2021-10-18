/****** Object:  Procedure [dbo].[Set_CareSpaceAlerts]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		dpatel
-- Create date: 09/30/2016
-- Description:	This sp inserts care space referrals to HPAlert table.
--				TriggerName: Note represents TriggerId = ID column in HpAlertNote table
-- Date			Name			Comments
--01/25/2017	PPetluri		For time being added logic to getMVDID from MemberID and Update HPAlert table, once deep is back from vacation need to make changes to table data type and UI
-- =============================================
CREATE PROCEDURE [dbo].[Set_CareSpaceAlerts]
	@AlertRecords [dbo].[CareSpaceAlert] readonly
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
Declare @HPAlertID	INT, @MVDID	VARCHAR(30)
	BEGIN TRY  
		Insert into HPAlert ([AgentID]
		  ,[AlertDate]
		  ,[Facility]
		  ,[Customer]
		  ,[Text]
		  ,[MemberID]
		  ,[StatusID]
		  ,[RecordAccessID]
		  ,[DateCreated]
		  ,[DateModified]
		  ,[ModifiedBy]
		  ,[TriggerType]
		  ,[TriggerID]
		  ,[RecipientType]
		  ,[RecipientCustID]
		  ,[DischargeDisposition]
		  ,[SourceName]
		  ,[ChiefComplaint]
		  ,[EMSNote])
		SELECT [AgentID]
		  ,[AlertDate]
		  ,[Facility]
		  ,[Customer]
		  ,[Text]
		  ,[MemberID]
		  ,[StatusID]
		  ,[RecordAccessID]
		  ,[DateCreated]
		  ,[DateModified]
		  ,[ModifiedBy]
		  ,[TriggerType]
		  ,[TriggerID]
		  ,[RecipientType]
		  ,[RecipientCustID]
		  ,[DischargeDisposition]
		  ,[SourceName]
		  ,[ChiefComplaint]
		  ,[EMSNote]
		FROM @AlertRecords 

		select @HPAlertID = SCOPE_IDENTITY();

		Select @MVDID = L.MVDID from HPAlert A JOIN Link_MemberID_MVD_Ins L ON A.MemberID = L.InsMemberID and L.Cust_id = A.[RecipientCustID]
		Where ID = @HPAlertID

		UPDATE  HPAlert
		SET MVDID = @MVDID
		WHERE ID = @HPAlertID
	END TRY  
	BEGIN CATCH
		DECLARE @ErrorMessage varchar(max);  
		DECLARE @ErrorSeverity INT;  
		DECLARE @ErrorState INT;  

		SELECT   
        @ErrorMessage = ERROR_MESSAGE(),  
        @ErrorSeverity = ERROR_SEVERITY(),  
        @ErrorState = ERROR_STATE();  
  
		-- Use RAISERROR inside the CATCH block to return error  
		-- information about the original error that caused  
		-- execution to jump to the CATCH block.  
		RAISERROR (@ErrorMessage, -- Message text.  
		           @ErrorSeverity, -- Severity.  
		           @ErrorState -- State.  
		           );  
	END CATCH
END