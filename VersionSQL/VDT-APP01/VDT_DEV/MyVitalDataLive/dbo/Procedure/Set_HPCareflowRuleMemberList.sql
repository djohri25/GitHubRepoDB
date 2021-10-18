/****** Object:  Procedure [dbo].[Set_HPCareflowRuleMemberList]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		Marc De Luca
-- Create date: 10/17/2018
-- Description:	Inserts member records into HPAlert from HPWorkflowRule
-- Example:		EXEC dbo.Set_HPCareflowRuleMemberList @RuleID = 71
-- =============================================
CREATE PROCEDURE [dbo].[Set_HPCareflowRuleMemberList]
	@RuleID INT
AS
BEGIN

	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	DECLARE 
	 @CustID VARCHAR(10)
	,@Body VARCHAR(MAX)
	,@OriginalBody VARCHAR(MAX)
	,@TableName VARCHAR(MAX)
	,@MaxString INT
	,@CurrentStart INT = 1
	,@CurrentEnd INT
	,@CurrentSpace INT
	,@StatusID INT
	,@ProductID INT
	,@TaskOwner SMALLINT
	,@SQL NVARCHAR(MAX)
	,@SQLCount NVARCHAR(MAX)
	,@From VARCHAR(MAX) = ''
	,@TableCount INT
	,@CurrentTableID INT = 1
	,@FromStatement VARCHAR(MAX) = ''

	SELECT @StatusID = CodeID FROM dbo.Lookup_Generic_Code WHERE CodeTypeID = 12 AND Label = 'Open'

	SELECT @ProductID = ID FROM dbo.Products WHERE [Description] = 'Provider Link'

	SELECT @TaskOwner = G.ID
	FROM dbo.HPWorkflowRule R
	JOIN dbo.Link_HPRuleAlertGroup L ON R.Rule_ID = L.Rule_ID
	JOIN dbo.HPAlertGroup G ON L.AlertGroup_ID = G.ID
	WHERE R.Rule_ID = @RuleID
	AND R.[Group] = 'ProviderLink'

	DECLARE @Tables TABLE (ID INT IDENTITY (1,1), TableName VARCHAR(100) )

	SELECT @OriginalBody = Body, @Body =  ' '+Body,  @CustID = Cust_ID
	FROM dbo.HPWorkflowRule
	WHERE Rule_ID = @RuleID
	AND Active = 1

	SET @Body = REPLACE(REPLACE(@Body,' dbo.',' '), ' rules.',' ')

	SELECT @MaxString = LEN(@Body) - CHARINDEX('.', REVERSE(@Body), 1)

	-- Loop through the from clause and look for any "." and then reverse the string look for a space. This will give you a table. Example) WHERE MainCondition.Column LIKE '%xxx%'. 
	WHILE @CurrentStart <= @MaxString
	BEGIN

		SELECT @CurrentEnd = CHARINDEX('.', @Body, @CurrentStart)

		SELECT @TableName = RTRIM(SUBSTRING(@Body, @CurrentStart, @CurrentEnd-@CurrentStart))

		SELECT @CurrentSpace = CHARINDEX(' ', REVERSE(@TableName), 1)

		SELECT @TableName = SUBSTRING(REVERSE(@TableName), 1, @CurrentSpace)

		IF NOT EXISTS 
		(
			SELECT 1 
			FROM @Tables 
			WHERE TableName = LTRIM(RTRIM(REVERSE(@TableName))) 
		)

		INSERT INTO @Tables (TableName)
		SELECT s.name+'.'+st.name
		FROM sys.objects st
		JOIN sys.schemas s ON st.schema_id = s.schema_id
		WHERE type IN ('U','V')
		AND st.name = LTRIM(RTRIM(REVERSE(@TableName)))
		AND LTRIM(RTRIM(REVERSE(@TableName))) <> 'MainPersonalDetails'
		AND NOT EXISTS (SELECT * FROM @Tables T WHERE s.name+'.'+st.name = T.TableName)

		SET @CurrentStart = @CurrentEnd + 2

	END

	SELECT @TableCount = COUNT(*) FROM @Tables T

	-- Find the column to join on. Either MVDID or ICENUMBER
	WHILE @CurrentTableID <= @TableCount
	BEGIN

		SELECT @From = ' JOIN '+TableName+' ON dbo.MainPersonalDetails.ICENUMBER = '+TableName+'.'+C.PKNo+' '+CHAR(13)
		FROM @Tables T
		OUTER APPLY
		(
			SELECT TOP 1 s.name SName, c.Name AS PKNo
			FROM sys.objects st
			JOIN sys.schemas s ON st.schema_id = s.schema_id
			JOIN sys.columns c ON st.object_id = c.object_id AND c.name IN ('MVDID', 'ICENUMBER')
			WHERE type IN ('U','V')
			AND s.name+'.'+st.name = T.TableName
		) C
		WHERE T.ID = @CurrentTableID

		SELECT @FromStatement = @FromStatement + @From

		SET @From = ''

		SET @CurrentTableID += 1

	END

		SET @SQL = 
		'
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
		SET NOCOUNT ON;

		SELECT DISTINCT MainPersonalDetails.ICENUMBER
		FROM dbo.MainPersonalDetails 
		'

		IF @FromStatement NOT LIKE '%Link_MemberId_MVD_Ins%'
			SET @SQL = @SQL + ' JOIN dbo.Link_MemberId_MVD_Ins ON MainPersonalDetails.ICENUMBER = Link_MemberId_MVD_Ins.MVDID AND Link_MemberId_MVD_Ins.Active = 1 '

		IF @Body like '%MobileMVDLive.dbo.Link_Device_MVDMember.DeviceID%' and @FromStatement NOT LIKE '%MobileMVDLive.dbo.Link_Device_MVDMember%'
			SET @SQL = @SQL + ' JOIN MobileMVDLive.dbo.Link_Device_MVDMember ON MainPersonalDetails.ICENUMBER = MobileMVDLive.dbo.Link_Device_MVDMember.MVDID '

		SET @SQL = @SQL + @FromStatement

		IF @FromStatement NOT LIKE '%Link_MemberId_MVD_Ins%'
			SET @SQL = @SQL + 'WHERE Link_MemberId_MVD_Ins.Cust_ID = ' +@CustID
		SET @SQL = @SQL + ' AND ' +@OriginalBody

		SET @SQL = REPLACE(REPLACE(@SQL, 'dbo.DAYSBEFORE', 'DAYSBEFORE'), 'DAYSBEFORE', 'dbo.DAYSBEFORE')
		SET @SQL = REPLACE(REPLACE(REPLACE(@SQL,'\\\''''', ''''), '''\\\''', ''''), '\\\''', '''')
		SET @SQL = REPLACE(REPLACE(@SQL,'\', ''), '''''', '''')

		DROP TABLE IF EXISTS #F;
		CREATE TABLE #F (MVDID VARCHAR(15) )

		INSERT INTO #F (MVDID)
		EXEC sp_executesql @SQL

	IF EXISTS (SELECT TOP (1) * FROM #F)
	BEGIN

		DROP TABLE IF EXISTS #Results;
		CREATE TABLE #Results (UniqueRecordCheckSum VARCHAR(250), MVDID VARCHAR(10), RuleId SMALLINT, ExpirationDate DATETIME,CreatedBy VARCHAR(20), ProductId INT, CustomerId INT, TaskOwner SMALLINT, StatusId INT)

		INSERT INTO #Results (UniqueRecordCheckSum, MVDID, RuleId, ExpirationDate, CreatedBy, ProductId, CustomerId, TaskOwner, StatusId)
		SELECT DISTINCT
		 NULL AS UniqueRecordCheckSum
		,MVDID = I.MVDId
		,@RuleID AS RuleId
		,'12/31/2020' AS ExpirationDate
		,NULL AS CreatedBy
		,@ProductID AS ProductId
		,CustomerId = R.Cust_ID
		,@TaskOwner TaskOwner
		,StatusID = @StatusID
		FROM #F F
		JOIN dbo.Link_MemberId_MVD_Ins I ON F.MVDID = I.MVDId
		JOIN dbo.HPCustomer C ON I.Cust_ID = C.Cust_ID
		JOIN dbo.HPWorkflowRule R ON 1=1 
		WHERE R.Rule_ID = @RuleID 
		AND R.Active = 1

		-- Member record exists in the new rule list but not in the existing
		INSERT INTO dbo.CareFlowTask (UniqueRecordCheckSum, MVDID, RuleId, ExpirationDate, CreatedBy, ProductId, CustomerId, TaskOwner, StatusId)
		SELECT DISTINCT
		 R.UniqueRecordCheckSum
		,R.MVDID
		,R.RuleId
		,R.ExpirationDate
		,R.CreatedBy
		,R.ProductId
		,R.CustomerId
		,R.TaskOwner
		,R.StatusID
		FROM #Results R
		JOIN dbo.Link_HPRuleAlertGroup A ON A.Rule_ID = @RuleID
		WHERE NOT EXISTS 
		(
			SELECT 1 
			FROM dbo.CareFlowTask C
			WHERE C.CustomerId = @CustID 
			AND C.RuleID = @RuleID 
			AND C.TaskOwner = @TaskOwner
			AND C.RuleId = R.RuleId
			AND C.MVDID = R.MVDID
		)


	END

END