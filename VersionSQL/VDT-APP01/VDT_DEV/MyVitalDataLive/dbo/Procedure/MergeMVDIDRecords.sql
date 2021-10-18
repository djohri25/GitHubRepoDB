/****** Object:  Procedure [dbo].[MergeMVDIDRecords]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		Marc De Luca
-- Create date: 08/04/2017
-- Description:	Utility to merge mvdids together
-- Example:	EXEC dbo.MergeMVDIDRecords @MVDIDToRetain = '15DG211872', @MVDIDToReplace = '15DG203003'
-- =============================================
CREATE   PROCEDURE [dbo].[MergeMVDIDRecords]
 @MVDIDToRetain VARCHAR(15)
,@MVDIDToReplace VARCHAR(15)
AS

BEGIN

	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	/*
	1) Find which MVDID is the latest and probably use that one
	2) Check MainpersonalDetails and Link_MemberId_MVD_Ins to see if any vital information is different
	 2a) LastName, FirstName, DOB, Address, Phone
	3) Find all of the tables where the MVDID to be archive exists
	4) Create backup tables for the archived mvdid
	*/

	IF @MVDIDToRetain IS NULL OR @MVDIDToReplace IS NULL 
		RETURN
	IF (SELECT COUNT(*) FROM dbo.Link_MemberId_MVD_Ins WHERE MVDID IN (@MVDIDToRetain, @MVDIDToReplace) ) <> 2
		RETURN
	IF (SELECT COUNT(*) FROM dbo.MainpersonalDetails WHERE ICENUMBER IN (@MVDIDToRetain, @MVDIDToReplace) ) <> 2
		RETURN
	IF EXISTS (SELECT * FROM dbo.MergedMVDIDRecords WHERE RetainedMVDID = @MVDIDToRetain AND ReplacedMVDID = @MVDIDToReplace)
		RETURN

	DECLARE 
	 @MemberIDToRetain VARCHAR(20)
	,@MemberIDToReplace VARCHAR(20)
	,@PrimaryKey VARCHAR(25)

	SELECT @MemberIDToRetain = InsMemberId FROM dbo.Link_MemberId_MVD_Ins WHERE MVDID  = @MVDIDToRetain
	SELECT @MemberIDToReplace = InsMemberId FROM dbo.Link_MemberId_MVD_Ins WHERE MVDID  = @MVDIDToReplace

	IF OBJECT_ID('tempdb..#TablesWithMVDID') IS NOT NULL DROP TABLE #TablesWithMVDID;
	CREATE TABLE #TablesWithMVDID (ID INT IDENTITY(1,1) PRIMARY KEY CLUSTERED, TableName VARCHAR(100), ColumnName VARCHAR(100), Records INT)

	DECLARE 
	 @FindMVDIDSQL NVARCHAR(MAX)
	,@ArchiveRecordsSQL NVARCHAR(MAX)
	,@UpdateRecordsSQL NVARCHAR(MAX)
	,@SchemaName VARCHAR(100)
	,@TableName VARCHAR(100)
	,@ColumnName VARCHAR(100)

	INSERT INTO dbo.MergedMVDIDRecords (RetainedMVDID, ReplacedMVDID, RetainedMemberID, ReplacedMemberID)
	VALUES(@MVDIDToRetain, @MVDIDToReplace, @MemberIDToRetain, @MemberIDToReplace)

	-- Find tables with an MVDID that needs archiving
	DECLARE table_cursor CURSOR LOCAL FAST_FORWARD FOR
	SELECT s.name, t.name, c.name
	FROM sys.tables t
	JOIN sys.schemas s ON t.schema_id = s.schema_id and s.name ='dbo'
	JOIN sys.columns c ON t.object_id = c.object_ID
	WHERE c.Name IN ('MVDID', 'ICENUMBER')
	AND t.name NOT LIKE 'zzz%'
	ORDER BY t.name

	OPEN table_cursor

	FETCH NEXT FROM table_cursor
	INTO @SchemaName, @TableName, @ColumnName

	WHILE @@FETCH_STATUS = 0
	BEGIN
		
		SET @FindMVDIDSQL = N'SELECT '''+@SchemaName+'.'+@TableName+''' AS TableName, '''+@ColumnName+''' AS ColumnName, COUNT(*) AS Records FROM '+@SchemaName+'.'+@TableName+' WHERE '+@ColumnName+' = '''+@MVDIDToReplace+''' '
	
		INSERT INTO #TablesWithMVDID (TableName, ColumnName, Records)
		EXECUTE sp_executesql @FindMVDIDSQL

	FETCH NEXT FROM table_cursor
	INTO @SchemaName, @TableName, @ColumnName
	END

	CLOSE table_cursor
	DEALLOCATE table_cursor

	-- Insert MVDID to be archived into archive tables
	DECLARE archive_cursor CURSOR LOCAL FAST_FORWARD FOR
	SELECT TableName, ColumnName
	FROM #TablesWithMVDID
	WHERE Records > 0
	ORDER BY TableName, ColumnName, Records

	OPEN archive_cursor

	FETCH NEXT FROM archive_cursor
	INTO @TableName, @ColumnName

	WHILE @@FETCH_STATUS = 0
	BEGIN
		
			SELECT TOP (1) @PrimaryKey = c.name
			FROM #TablesWithMVDID t
			LEFT JOIN sys.objects o ON REPLACE(t.TableName,'dbo.','') = o.name
			JOIN sys.columns c ON o.object_id = c.object_id AND c.is_identity = 1 -- Identity column
			WHERE Records > 0
			AND t.TableName = @TableName
			AND t.TableName NOT IN 
			(
			 'dbo.SectionPermission','dbo.UserAdditionalInfo','dbo.Link_MemberId_MVD_Ins','dbo.MainpersonalDetails', 'dbo.MainICENUMBERGroups', 'dbo.MainInsurance', 'dbo.CCC_MemberAdditionalInfo'
			,'dbo.Driscoll_EligibilityAdditionalInfo', 'dbo.ERUtilizerReportData', 'dbo.MemberDiagnosisSummary', 'dbo.MemberDiagnosisSummaryCOPC'
			)

			SET @ArchiveRecordsSQL = '
			SELECT DISTINCT
			 '''+@TableName+''' AS TableName
			,A.'+@ColumnName+'
			,SUBSTRING(
			(
				SELECT '',''+CAST(B.'+@PrimaryKey+' AS VARCHAR(10)) 
				FROM '+@TableName+' B 
				WHERE B.'+@ColumnName+' = A.'+@ColumnName+' 
				ORDER BY B.'+@PrimaryKey+' 
				FOR XML PATH('''') ),2,200000
			) AS RolledUpID
			FROM '+@TableName+' A
			WHERE '+@ColumnName+' = '''+@MVDIDToReplace+'''
			'
			IF @PrimaryKey IS NOT NULL
			BEGIN
				INSERT INTO dbo.MergedMVDIDTablesAffected (TableName, ReplacedMVDID, MergedPrimaryKeys)
				EXECUTE sp_executesql @ArchiveRecordsSQL
			END

			SET @PrimaryKey = NULL

	FETCH NEXT FROM archive_cursor
	INTO @TableName, @ColumnName
	END

	CLOSE archive_cursor
	DEALLOCATE archive_cursor

	-- Update tables with MVDID to keep
	DECLARE update_cursor CURSOR LOCAL FAST_FORWARD FOR
	SELECT TableName, ColumnName
	FROM #TablesWithMVDID
	WHERE Records > 0
	AND TableName NOT IN 			
	(
	 'dbo.SectionPermission','dbo.UserAdditionalInfo','dbo.Link_MemberId_MVD_Ins','dbo.MainpersonalDetails', 'dbo.MainICENUMBERGroups', 'dbo.MainInsurance', 'dbo.CCC_MemberAdditionalInfo'
	,'dbo.Driscoll_EligibilityAdditionalInfo', 'dbo.ERUtilizerReportData', 'dbo.MemberDiagnosisSummary', 'dbo.MemberDiagnosisSummaryCOPC'
		)
	ORDER BY TableName, ColumnName, Records

	OPEN update_cursor

	FETCH NEXT FROM update_cursor
	INTO @TableName, @ColumnName

	WHILE @@FETCH_STATUS = 0
	BEGIN
		
		SET @UpdateRecordsSQL = N'UPDATE '+@TableName+' SET '+@ColumnName+' = '''+@MVDIDToRetain+''' WHERE '+@ColumnName+' = '''+@MVDIDToReplace+''' '

		EXECUTE sp_executesql @UpdateRecordsSQL

	FETCH NEXT FROM update_cursor
	INTO @TableName, @ColumnName
	END

	CLOSE update_cursor
	DEALLOCATE update_cursor

	INSERT INTO [dbo].[MergedMainPersonalDetails]
	(
	 [RecordNumber],[ICENUMBER],[LastName],[FirstName],[GenderID],[SSN],[DOB],[Address1],[Address2],[City],[State],[PostalCode],[HomePhone],[CellPhone],[WorkPhone]
	,[FaxPhone],[Email],[BloodTypeID],[OrganDonor],[HeightInches],[WeightLbs],[MaritalStatusID],[EconomicStatusID],[Occupation],[Hours],[CreationDate],[ModifyDate]
	,[MaxAttachmentLimit],[CreatedBy],[CreatedByOrganization],[UpdatedBy],[UpdatedByOrganization],[UpdatedByContact],[Organization],[Language],[Ethnicity],[CreatedByNPI]
	,[UpdatedByNPI],[InCaseManagement],[NarcoticLockdown],[MiddleName],[CaseManagementStartDate]
	)

	SELECT 
	 [RecordNumber],[ICENUMBER],[LastName],[FirstName],[GenderID],[SSN],[DOB],[Address1],[Address2],[City],[State],[PostalCode],[HomePhone],[CellPhone],[WorkPhone]
	,[FaxPhone],[Email],[BloodTypeID],[OrganDonor],[HeightInches],[WeightLbs],[MaritalStatusID],[EconomicStatusID],[Occupation],[Hours],[CreationDate],[ModifyDate]
	,[MaxAttachmentLimit],[CreatedBy],[CreatedByOrganization],[UpdatedBy],[UpdatedByOrganization],[UpdatedByContact],[Organization],[Language],[Ethnicity],[CreatedByNPI]
	,[UpdatedByNPI],[InCaseManagement],[NarcoticLockdown],[MiddleName],[CaseManagementStartDate]
	FROM dbo.MainPersonalDetails
	WHERE ICENUMBER IN (@MVDIDToRetain,@MVDIDToReplace)

	UPDATE IK
	SET 
	 IK.LastName = COALESCE(NULLIF(IK.LastName,''), NULLIF(IA.LastName,''))-- AS LastName
	,IK.FirstName = COALESCE(NULLIF(IK.FirstName,''), NULLIF(IA.FirstName,''))-- AS FirstName
	,IK.GenderID = COALESCE(IK.GenderID, IA.GenderID)-- AS GenderID
	,IK.SSN = COALESCE(NULLIF(IK.SSN,''), NULLIF(IA.SSN,''))-- AS SSN
	,IK.DOB = COALESCE(NULLIF(IK.DOB,''), NULLIF(IA.DOB,''))-- AS DOB
	,IK.Address1 = COALESCE(NULLIF(IK.Address1,''), NULLIF(IA.Address1,''))-- AS Address1
	,IK.Address2 = COALESCE(NULLIF(IK.Address2,''), NULLIF(IA.Address2,''))-- AS Address2
	,IK.City = COALESCE(NULLIF(IK.City,''), NULLIF(IA.City,''))-- AS City
	,IK.State = COALESCE(NULLIF(IK.State,''), NULLIF(IA.State,''))-- AS State
	,IK.PostalCode = COALESCE(NULLIF(IK.PostalCode,''), NULLIF(IA.PostalCode,''))-- AS PostalCode
	,IK.HomePhone = COALESCE(NULLIF(IK.HomePhone,''), NULLIF(IA.HomePhone,''))-- AS HomePhone
	,IK.CellPhone = COALESCE(NULLIF(IK.CellPhone,''), NULLIF(IA.CellPhone,''))-- AS CellPhone
	,IK.WorkPhone = COALESCE(NULLIF(IK.WorkPhone,''), NULLIF(IA.WorkPhone,''))-- AS WorkPhone
	,IK.FaxPhone = COALESCE(NULLIF(IK.FaxPhone,''), NULLIF(IA.FaxPhone,''))-- AS FaxPhone
	,IK.Email = COALESCE(NULLIF(IK.Email,''), NULLIF(IA.Email,''))-- AS Email
	,IK.BloodTypeID = COALESCE(IK.BloodTypeID, IA.BloodTypeID)-- AS BloodTypeID
	,IK.OrganDonor = COALESCE(NULLIF(IK.OrganDonor,''), NULLIF(IA.OrganDonor,''))-- AS OrganDonor
	,IK.HeightInches = COALESCE(IK.HeightInches, IA.HeightInches)-- AS HeightInches
	,IK.WeightLbs = COALESCE(IK.WeightLbs, IA.WeightLbs)-- AS WeightLbs
	,IK.MaritalStatusID = COALESCE(IK.MaritalStatusID, IA.MaritalStatusID)-- AS MaritalStatusID
	,IK.EconomicStatusID = COALESCE(IK.EconomicStatusID, IA.EconomicStatusID)-- AS EconomicStatusID
	,IK.Occupation = COALESCE(NULLIF(IK.Occupation,''), NULLIF(IA.Occupation,''))-- AS Occupation
	,IK.Hours = COALESCE(NULLIF(IK.Hours,''), NULLIF(IA.Hours,''))-- AS Hours
	,IK.MaxAttachmentLimit = COALESCE(IK.MaxAttachmentLimit, IA.MaxAttachmentLimit)-- AS MaxAttachmentLimit
	,IK.CreatedBy = COALESCE(NULLIF(IK.CreatedBy,''), NULLIF(IA.CreatedBy,''))-- AS CreatedBy
	,IK.CreatedByOrganization = COALESCE(NULLIF(IK.CreatedByOrganization,''), NULLIF(IA.CreatedByOrganization,''))-- AS CreatedByOrganization
	,IK.UpdatedBy = COALESCE(NULLIF(IK.UpdatedBy,''), NULLIF(IA.UpdatedBy,''))-- AS UpdatedBy
	,IK.UpdatedByOrganization = COALESCE(NULLIF(IK.UpdatedByOrganization,''), NULLIF(IA.UpdatedByOrganization,''))-- AS UpdatedByOrganization
	,IK.UpdatedByContact = COALESCE(NULLIF(IK.UpdatedByContact,''), NULLIF(IA.UpdatedByContact,''))-- AS UpdatedByContact
	,IK.Organization = COALESCE(NULLIF(IK.Organization,''), NULLIF(IA.Organization,''))-- AS Organization
	,IK.Language = COALESCE(NULLIF(IK.Language,''), NULLIF(IA.Language,''))-- AS Language
	,IK.Ethnicity = COALESCE(NULLIF(IK.Ethnicity,''), NULLIF(IA.Ethnicity,''))-- AS Ethnicity
	,IK.CreatedByNPI = COALESCE(NULLIF(IK.CreatedByNPI,''), NULLIF(IA.CreatedByNPI,''))-- AS CreatedByNPI
	,IK.UpdatedByNPI = COALESCE(NULLIF(IK.UpdatedByNPI,''), NULLIF(IA.UpdatedByNPI,''))-- AS UpdatedByNPI
	,IK.InCaseManagement = COALESCE(IK.InCaseManagement, IA.InCaseManagement)-- AS InCaseManagement
	,IK.NarcoticLockdown = COALESCE(IK.NarcoticLockdown, IA.NarcoticLockdown)-- AS NarcoticLockdown
	,IK.MiddleName = COALESCE(NULLIF(IK.MiddleName,''), NULLIF(IA.MiddleName,''))-- AS MiddleName
	,IK.CaseManagementStartDate = COALESCE(IK.CaseManagementStartDate, IA.CaseManagementStartDate)-- AS CaseManagementStartDate
	FROM dbo.MainpersonalDetails IK
	JOIN dbo.MainpersonalDetails IA ON IA.ICENUMBER = @MVDIDToReplace
	WHERE IK.ICENUMBER = @MVDIDToRetain

	DELETE FROM dbo.SectionPermission WHERE ICENUMBER = @MVDIDToReplace
	DELETE FROM dbo.UserAdditionalInfo WHERE MVDID = @MVDIDToReplace
	DELETE FROM dbo.MainICENUMBERGroups WHERE ICENUMBER = @MVDIDToReplace
	DELETE FROM dbo.MainInsurance WHERE ICENUMBER = @MVDIDToReplace
	DELETE FROM dbo.MainCarePlanIndex WHERE MVDID = @MVDIDToReplace
	DELETE FROM dbo.CCC_MemberAdditionalInfo WHERE ICENUMBER = @MVDIDToReplace
	DELETE FROM dbo.Driscoll_EligibilityAdditionalInfo WHERE ICENUMBER = @MVDIDToReplace
	DELETE FROM dbo.ERUtilizerReportData WHERE MVDID = @MVDIDToReplace
	DELETE FROM dbo.MemberDiagnosisSummary WHERE MVDID = @MVDIDToReplace
	DELETE FROM dbo.MemberDiagnosisSummaryCOPC WHERE MVDID = @MVDIDToReplace
	DELETE FROM dbo.Link_MemberId_MVD_Ins WHERE MVDID = @MVDIDToReplace
	DELETE FROM dbo.MainpersonalDetails WHERE ICENUMBER = @MVDIDToReplace

END