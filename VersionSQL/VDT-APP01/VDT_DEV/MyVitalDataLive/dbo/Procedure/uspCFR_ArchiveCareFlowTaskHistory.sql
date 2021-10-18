/****** Object:  Procedure [dbo].[uspCFR_ArchiveCareFlowTaskHistory]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROC uspCFR_ArchiveCareFlowTaskHistory 
AS
/*

note:  This procedure may not do the work we need.  The Azure database takes too long to move data to.

Changes
WHO		WHEN		WHAT
Scott	2021-03-09	Created to archive CareFlowHistory table to VD-ARCH (Azure Archive)

*/
BEGIN
	SET NOCOUNT ON

	DECLARE @BeginDate date 
	DECLARE @EndDate date
	DECLARE @ArchiveDate date 
	DECLARE @iRows int
	DECLARE @Msg varchar(1000)
	DECLARE @Today datetime = GETDATE()

	DROP TABLE IF EXISTS #CFR_Archive_Log
	CREATE TABLE #CFR_Archive_Log (ID int IDENTITY, LogDate Datetime, Records int)

	SELECT @BeginDate = (SELECT MIN(CAST(UpdatedDate AS date)) FROM CareFlowTaskHistory)
	SELECT @EndDate = (SELECT EOMONTH(GETDATE(),-3)) 
	SELECT @ArchiveDate = @BeginDate

	PRINT 'Archiving CareFlowTaskHistory to VD-ARCH for dates ' + CAST(@BeginDate AS varchar(10)) + ' to ' + CAST(@EndDate AS varchar(10))

	WHILE @ArchiveDate <= @EndDate
		BEGIN

			SELECT @iRows = COUNT(*) FROM CareFlowTaskHistory WHERE CAST(UpdatedDate AS date) = @ArchiveDate
			
			SET @Msg = 'Archiving ' + CAST(@iRows AS varchar) + ' rows from ' + CAST(@ArchiveDate AS varchar(10)) 
			RAISERROR(@Msg,0,1)

			--This is an Azure db and it is sometimes difficult to get a connection.  It can be very slow to move data.
			--the batch size we move over there seems to be best at about 10k rows.
			INSERT [VD-ARCH].Archive_MyVitalDataLive.dbo.CareFlowTaskHistory (MVDID, RuleID, ExpirationDate, CreatedDate, CreatedBy,
			                                                                  UpdatedDate, UpdatedBy, ProductID, CustomerID, StatusID, OwnerGroup)
			SELECT MVDID, RuleID, ExpirationDate, CreatedDate, CreatedBy,UpdatedDate, UpdatedBy, ProductID, CustomerID, StatusID, OwnerGroup 
			  FROM MyVitalDataLive.dbo.CareFlowTaskHistory
			 WHERE CAST(UpdatedDate AS date) = @ArchiveDate
			 
			DELETE MyVitalDataLive.dbo.CareFlowTaskHistory
			 WHERE CAST(UpdatedDate AS date) = @ArchiveDate

			INSERT INTO #CFR_Archive_Log (LogDate, Records)
			SELECT GETDATE() AS LogDate, @iRows AS Records
			
			SET @ArchiveDate = DATEADD(day,1,@ArchiveDate)
		END

END