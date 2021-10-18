/****** Object:  Procedure [dbo].[Get_CareflowTasks]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- EXEC dbo.Get_CareFlowTasks @UserID = 'bdurso', @CustomerId = '10', @ProductId = 3, @StatusId = NULL, @TIN = 'COPC000012', @TaskStartDate = NULL, @TaskEndDate = NULL
-- Date			Name			Comments				
-- =============================================
CREATE PROCEDURE [dbo].[Get_CareflowTasks] 
	 @UserID varchar(50) --Accepts both GUID and varchar based username/userid
	,@CustomerId int
	,@ProductId int --Differentiate between different products - PlanLink, ProviderLink, etc.
	,@StatusId int = NULL --Rename it to @StatusId and type int? For admin user to filter data? Default to Open tasks
	,@TIN varchar(50) = NULL
	,@TaskStartDate datetime = NULL--To search task based on daterange
	,@TaskEndDate datetime = NULL--To search task based on daterange
AS
BEGIN

	SET NOCOUNT ON;

	SELECT @TaskStartDate = COALESCE(@TaskStartDate, GETDATE()), @TaskEndDate = COALESCE(@TaskEndDate, DATEADD(MM,-6,GETDATE()))
	
	DECLARE @MaxMonthID CHAR(6)

	SELECT @MaxMonthID = MAX(MonthID) FROM dbo.Final_ALLMember WHERE CustID = @CustomerId

	-- Get the MVDID's and NPI's for that TIN
	DROP TABLE IF EXISTS #T
	;WITH CTE_TINs AS
	(
		SELECT MVDID, TIN, NPI, ROW_NUMBER() OVER(PARTITION BY MVDID, TIN ORDER BY MVDID, TIN, ID DESC) AS RowNum
		FROM dbo.Final_ALLMember
		WHERE CustID = @CustomerId
		AND TIN = @TIN
	)

	SELECT MVDID, TIN, T.NPI, COALESCE(NULLIF(CONCAT(NPI.[Provider First Name],' ',NPI.[Provider Last Name (Legal Name)]), ''),NPI.[Provider Organization Name (Legal Business Name)]) AS ProviderName
	INTO #T
	FROM CTE_TINs T
	JOIN dbo.LookupNPI NPI ON T.NPI = NPI.NPI
	WHERE RowNum = 1

	CREATE CLUSTERED INDEX IX_MVDID ON #T (MVDID)

	-- Get hedis test due for those who have been recently entered in HedisTestStatus
	DROP TABLE IF EXISTS #HTS;
	SELECT DISTINCT MVDID
	INTO #HTS
	FROM dbo.HedisTestStatus
	WHERE TestID IS NOT NULL
	AND StatusID = 16
	AND Created >= DATEADD(DD, -8, GETDATE())

	SELECT HTS.MVDID
	,CAST(SUBSTRING(
	( 
		SELECT DISTINCT ','+CAST(Abbreviation AS VARCHAR(10)) 
		FROM dbo.Final_HEDIS_Member_FULL F
		JOIN dbo.LookupHedis l ON F.TestID = l.id
		WHERE F.MVDID = HTS.MVDID
		AND F.CustID = @CustomerId
		AND F.MonthID = @MaxMonthID
		AND F.IsTestDue = 0
		AND NOT EXISTS
		(
			SELECT 1
			FROM dbo.HedisTestStatus TS
			WHERE TS.MVDID IN (SELECT MVDID FROM #HTS)
			AND TS.TestID IS NOT NULL
			AND TS.StatusID = 16
			AND TS.Created >= DATEFROMPARTS(YEAR(GETDATE()),'01', '01')
			AND TS.TestID = F.TestID
			AND TS.MVDID = F.MVDID
		)
		FOR XML PATH('')),2,200000
	) AS VARCHAR(2000)) AS HedisDue
	INTO #HTDM
	FROM #HTS HTS

	DROP TABLE IF EXISTS #P;
	SELECT ICENUMBER, SUM(BilledAmount) AS BilledAmountLast6Months
	INTO #P
	FROM dbo.MainMedicationPayments M
	WHERE FillDate > DATEADD(MM, -6, GETDATE())
	GROUP BY ICENUMBER

	DROP TABLE IF EXISTS #RXT;
	SELECT ICENUMBER, BilledAmountLast6Months, AvgBilledAmountLast6Months = (SELECT AVG(BilledAmountLast6Months) FROM #P)
	INTO #RXT
	FROM #P

	DROP TABLE IF EXISTS #RXP;
	SELECT 	 
	 ICENUMBER
	,BilledAmountLast6Months
	,AvgBilledAmountLast6Months
	,CASE WHEN BilledAmountLast6Months > AvgBilledAmountLast6Months*1.5 THEN 1 ELSE 0 END AS IsHighRx
	INTO #RXP
	FROM #RXT
	ORDER BY ICENUMBER

	CREATE NONCLUSTERED INDEX IX_ICENUMBER ON #RXP ([ICENUMBER]) INCLUDE ([BilledAmountLast6Months],[IsHighRx])
	
	SELECT
	 RowNum =  ROW_NUMBER() OVER(ORDER BY C.ID)
	,C.Id
	,'' AS CareFlowGroupId --C.TaskOwner
	,C.StatusID
	,C.ActionId
	,C.CreatedDate
	,C.ExpirationDate
	,C.CreatedBy
	,C.UpdatedDate
	,C.UpdatedBy
	,0 as ParentTaskId --C.ParentTaskId
	,0 as IsSoftDeleted --C.IsSoftDeleted
	,C.ProductId
	,C.CustomerId
	,C.MVDID
	,lh.Label AS StatusName
	,mpd.LastName + ', ' + mpd.FirstName AS MemberName
	,ISNULL(CONVERT(varchar,mpd.DOB,101),'') AS MemberDOB
	,lm.InsMemberId AS MemberID
	,ISNULL(v.ERVisitCount,0) AS ERVisitCount
	,ISNULL(v.PhysicianVisitCount,0) AS PhysicianVisitCount
	,IsHighER = CAST(CASE WHEN v.ERVisitCount >= 3 THEN 1 ELSE 0 END AS BIT)
	,ERVisitDescription = CAST(v.ERVisitCount AS VARCHAR(3))+' visits in the last 6 months'
	,IsHighRX =  CAST(ISNULL(RXP.IsHighRx,0) AS BIT)
	,RXAvgCost = ISNULL(RXP.BilledAmountLast6Months, 0.00)
	,RXDescription = ' RX Totals of $'+CAST(RXP.BilledAmountLast6Months AS VARCHAR(25))+' in the last 6 months'
	,IsHighUtil = CAST(CASE WHEN mr.HCC_Score_Adj > 5 THEN 1 ELSE 0 END AS BIT)
	,HighUtilCost = CAST(mr.HCC_Score_Adj AS DECIMAL(5,2))
	,HighUtilDescription = 'Has an HCC Score of '+CAST(mr.HCC_Score_Adj AS VARCHAR(25))+' '
	,CAST(mr.HCC_Score_Adj AS DECIMAL(5,2)) AS HCCScore
	,mr.Elixhauser_Score AS ElixhauserScore
	,mr.Charlson_Score AS CharlsonScore
	,ISNULL(N.NotesCount, 0) AS NotesCount
	,mpd.LastName
	,mpd.FirstName
	,PCR.RiskScores AS PCCIRiskscore
	,FALL.HasAsthma 
	,FALL.HasDiabetes
--	,LGC.Label as LOB
	,COALESCE(HTDM.HedisDue,FALL.TestDueList) AS HedisDue
	,hwr.Rule_ID as CareFlowRuleId
	,hwr.[Name] as CareFlowRuleName
	,T.NPI
	,NULL as LockedBy
	,T.ProviderName
	--,COALESCE(NULLIF(CONCAT(NPI.[Provider First Name],' ',NPI.[Provider Last Name (Legal Name)]), ''),NPI.[Provider Organization Name (Legal Business Name)]) AS ProviderName 
	,FALL.LOB AS LOBCode
	,LOBT.Label_Desc AS LOB
	FROM dbo.CareFlowTask C
	JOIN #T T ON C.MVDID = T.MVDID
--	LEFT JOIN dbo.LookupNPI NPI ON T.NPI = NPI.NPI
	JOIN dbo.Link_MemberID_MVD_Ins lm ON C.MVDID = lm.MVDID AND C.CustomerId = lm.cust_id AND lm.Active = 1
	JOIN dbo.HPCustomer HPC ON lm.Cust_ID = HPC.Cust_ID
	JOIN dbo.MainPersonalDetails mpd ON C.MVDId = mpd.ICENUMBER
	JOIN dbo.Lookup_Generic_Code lh ON C.StatusID = lh.CodeID AND lh.IsActive = 1
	LEFT JOIN dbo.HPWorkflowRule hwr ON C.RuleId = hwr.Rule_ID
	LEFT JOIN #RXP RXP ON C.MVDID = RXP.ICENUMBER
	LEFT JOIN
		(
			SELECT S.MVDID, COUNT(*) AS NotesCount
			FROM dbo.HPAlertNote S
			JOIN dbo.Link_MemberId_MVD_Ins I ON S.MVDID = I.MVDId
			WHERE I.Cust_ID = @CustomerId
			AND S.NoteTypeID IN (12,13,14,15)
			GROUP BY S.MVDID
		) N ON C.MVDID = N.MVDID
	LEFT JOIN 
		(
			SELECT MR.MVDID,MR.MonthID,MR.ReportDate,MR.HCC_Score_Adj,MR.HCC_Score_NonAdj,MR.Charlson_Score,MR.Elixhauser_Score
			FROM dbo.MainRisk MR
			JOIN
			(
				SELECT MAX(MonthID) AS MonthID, MVDID
				FROM dbo.MainRisk 
				GROUP BY MVDID
			) MMR ON MR.MVDID = MMR.MVDID AND MR.MonthID = MMR.MonthID
		) mr ON C.MVDID = mr.MVDID
	OUTER APPLY
	(
		SELECT 
		 SUM(CASE WHEN v.VisitType = 'ER' THEN 1 ELSE 0 END) AS ERVisitCount
		,SUM(CASE WHEN v.facilityname IS NULL OR v.facilityname = '' THEN 1 ELSE 0 END) AS PhysicianVisitCount
		FROM dbo.EDVisitHistory v 
		WHERE v.ICENUMBER = mpd.ICENUMBER 
		AND v.visitdate > @TaskEndDate
	) v
	LEFT JOIN dbo.ParklandPCCICOPCRisk PCR ON MPD.ICENUMBER = PCR.MVDID
	LEFT JOIN dbo.Final_ALLMember FALL ON FALL.CustID = lm.Cust_ID AND FALL.mvdid = lm.MVDId AND FALL.MonthID = @MaxMonthID AND FALL.CustID = @CustomerId AND FALL.TIN = @TIN
	LEFT JOIN dbo.Lookup_Generic_Code LGC ON LGC.CodeID = mpd.Organization AND LGC.Cust_ID = lm.Cust_ID
	LEFT JOIN #HTDM HTDM ON C.MVDID = HTDM.MVDID
	LEFT JOIN dbo.Lookup_Generic_Code LOBT ON FALL.LOB = LOBT.Label AND LOBT.CodeTypeID = 3 AND LOBT.Cust_ID = @CustomerId
	WHERE 1=1
	AND EXISTS (SELECT 1 FROM #T T WHERE T.MVDID = C.MVDID)
	AND (@StatusId IS NULL OR lh.CodeID = @StatusId)
	AND lm.Cust_ID = @CustomerId

			-- Record SP Log
	DECLARE @params NVARCHAR(1000) = NULL
	SET @params = LEFT(
	 '@UserID=' + ISNULL(CAST(@UserID AS VARCHAR(100)), 'null') + ';' 
	+'@CustomerId=' + ISNULL(CAST(@CustomerId AS VARCHAR(100)), 'null') + ';' 
	+'@ProductId=' + ISNULL(CAST(@ProductId AS VARCHAR(100)), 'null') + ';'
	+'@StatusId=' + ISNULL(CAST(@StatusId AS VARCHAR(100)), 'null') + ';'
	+'@TIN=' + ISNULL(CAST(@TIN AS VARCHAR(100)), 'null') + ';'
	+'@TaskStartDate=' + ISNULL(CAST(@TaskStartDate AS VARCHAR(100)), 'null') + ';'
	+'@TaskEndDate=' + ISNULL(CAST(@TaskEndDate AS VARCHAR(100)), 'null') + ';'
	, 1000);
	
	EXEC dbo.Set_StoredProcedures_Log '[dbo].[Get_CareflowTasks]', @UserID, NULL, @params

END