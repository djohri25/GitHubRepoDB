/****** Object:  Procedure [dbo].[Set_HPWorkflowRuleMemberList]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		Marc De Luca
-- Create date: 01/23/2017
-- Description:	Inserts member records into HPAlert from HPWorkflowRule
-- Example:		EXEC dbo.Set_HPWorkflowRuleMemberList @RuleID = 17
-- 06/28/2017	Marc De Luca	Added Active flag
-- 07/28/2017	Marc De Luca	Added SET @SQL = REPLACE(REPLACE(@SQL,'\', ''), '''''', '''')
-- 08/07/2017 Marc De Luca	Added AND H.StatusID <> 2 to the first update.  Added a second update for rules that have been removed.
-- 12/11/2017	Mike Grover	Added cross database support for MobileMVDLive ~ Ln130
-- 03/09/2018	Marc De Luca	Changed the table finder to include the rules. tables
-- =============================================
CREATE PROCEDURE [dbo].[Set_HPWorkflowRuleMemberList]
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
	,@UTCDate DATE = GETUTCDATE()

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

	DECLARE
	 @SQL NVARCHAR(MAX)
	,@SQLCount NVARCHAR(MAX)
	,@From VARCHAR(MAX) = ''
	,@TableCount INT
	,@CurrentTableID INT = 1
	,@FromStatement VARCHAR(MAX) = ''

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
			SET @SQL = @SQL + ' JOIN dbo.Link_MemberId_MVD_Ins ON MainPersonalDetails.ICENUMBER = Link_MemberId_MVD_Ins.MVDID '

		IF @Body like '%MobileMVDLive.dbo.Link_Device_MVDMember.DeviceID%' and @FromStatement NOT LIKE '%MobileMVDLive.dbo.Link_Device_MVDMember%'
			SET @SQL = @SQL + ' JOIN MobileMVDLive.dbo.Link_Device_MVDMember ON MainPersonalDetails.ICENUMBER = MobileMVDLive.dbo.Link_Device_MVDMember.MVDID '

		SET @SQL = @SQL + @FromStatement

		IF @FromStatement NOT LIKE '%Link_MemberId_MVD_Ins%'
			SET @SQL = @SQL + 'WHERE Link_MemberId_MVD_Ins.Cust_ID = ' +@CustID
		SET @SQL = @SQL + ' AND ' +@OriginalBody

		SET @SQL = REPLACE(REPLACE(@SQL, 'dbo.DAYSBEFORE', 'DAYSBEFORE'), 'DAYSBEFORE', 'dbo.DAYSBEFORE')
		SET @SQL = REPLACE(REPLACE(REPLACE(@SQL,'\\\''''', ''''), '''\\\''', ''''), '\\\''', '''')
		SET @SQL = REPLACE(REPLACE(@SQL,'\', ''), '''''', '''')

		IF OBJECT_ID('tempdb..#F') IS NOT NULL DROP TABLE #F;
		CREATE TABLE #F (MVDID VARCHAR(15) )

		INSERT INTO #F (MVDID)
		EXEC sp_executesql @SQL

	IF EXISTS (SELECT TOP (1) * FROM #F)
	BEGIN

		IF OBJECT_ID('tempdb..#Results') IS NOT NULL DROP TABLE #Results;
		SELECT
		 AlertDate = @UTCDate
		,Facility = NULL
		,Customer = C.Name
		,Text = R.Description
		,MemberID = I.InsMemberId
		,StatusID = 0
		,RecordAccessID = -1
		,TriggerType = 'WORKFLOW'
		,TriggerID = @RuleID
		,RecipientType = 'Group'
		,RecipientCustID = R.Cust_ID
		,ChiefComplaint = NULL
		,EMSNote = NULL
		,DischargeDisposition = NULL
		,SourceName = 'Workflow Engine' 
		,MVDID = I.MVDId
		INTO #Results
		FROM #F F
		JOIN dbo.Link_MemberId_MVD_Ins I ON F.MVDID = I.MVDId
		JOIN dbo.HPCustomer C ON I.Cust_ID = C.Cust_ID
		JOIN dbo.HPWorkflowRule R ON 1=1 AND R.Rule_ID = @RuleID AND R.Active = 1
		WHERE I.Cust_ID = @CustID

		-- Member record exists in the new rule list but not in the existing
		INSERT INTO dbo.HPAlert (AgentID,AlertDate,Facility,Customer,Text,MemberID,StatusID,RecordAccessID,TriggerType,TriggerID,RecipientType,RecipientCustID,ChiefComplaint,EMSNote,DischargeDisposition,SourceName,MVDID)
		SELECT
		 AgentID = A.AlertGroup_ID
		,R.AlertDate
		,R.Facility
		,R.Customer
		,R.[Text]
		,R.MemberID
		,R.StatusID
		,R.RecordAccessID
		,R.TriggerType
		,R.TriggerID
		,R.RecipientType
		,R.RecipientCustID
		,R.ChiefComplaint
		,R.EMSNote
		,R.DischargeDisposition
		,R.SourceName
		,R.MVDID
		FROM #Results R
		JOIN dbo.Link_HPRuleAlertGroup A ON A.Rule_ID = @RuleID
		WHERE NOT EXISTS 
		(
			SELECT 1 
			FROM dbo.HPAlert H 
			WHERE SourceName LIKE 'Workflow%' 
			AND H.RecipientCustID = @CustID 
			AND H.TriggerID = @RuleID 
			AND H.AgentID = CAST(A.AlertGroup_ID AS VARCHAR(25))
			AND R.TriggerID = H.TriggerID 
			AND R.MemberID = H.MemberID
		)
		
		-- Member record exists in the existing rule list but not in the new.  Update to closed by Workflow rule
		UPDATE H
		SET H.StatusID = 2
		FROM dbo.HPAlert H
		JOIN dbo.Link_HPRuleAlertGroup A ON H.TriggerID = A.Rule_ID AND H.AgentID = CAST(A.AlertGroup_ID AS VARCHAR(25)) AND A.Rule_ID = @RuleID
		WHERE NOT EXISTS 
		(
			SELECT 1 
			FROM #Results R 
			WHERE R.TriggerID = @RuleID 
			AND R.TriggerID = H.TriggerID 
			AND H.AgentID = CAST(A.AlertGroup_ID AS VARCHAR(25))
			AND R.MemberID = H.MemberID
		)
		AND H.RecipientCustID = @CustID
		AND H.TriggerID = @RuleID
		AND H.SourceName LIKE 'Workflow%'
		AND H.Text NOT LIKE '%record was accessed by%'
		AND H.StatusID <> 2

		-- Rule has been deleted from HPWorkflowRule.  Update to closed by Workflow rule
		UPDATE A
		SET A.StatusID = 2
		FROM dbo.HPAlert A
		WHERE A.TriggerType = 'WORKFLOW'
		AND A.SourceName = 'Workflow Engine'
		AND A.StatusID <> 2
		AND NOT EXISTS (SELECT 1 FROM dbo.HPWorkflowRule R WHERE R.Rule_ID = A.TriggerID)

	END

END