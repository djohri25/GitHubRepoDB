/****** Object:  Procedure [dbo].[DashboardCareflowList]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- EXEC dbo.DashboardCareflowList @UserID=N'FE1BFC9B-AD29-4540-BE3A-9872D3E5F094',@Customer='10'
-- Date			Name			Comments				
-- =============================================
CREATE PROCEDURE [dbo].[DashboardCareflowList] 
	 @UserID varchar(50)
	,@DateRange int = 0
	,@Customer varchar(50)
	,@IsCompleted bit = 0
	,@AfterHoursFilter bit = NULL
	,@RecipientID varchar(50) = NULL
	,@CopcFacilityID varchar(50) = NULL
	,@CopcPCP_NPI varchar(50) = NULL
	,@MemberID VARCHAR(20) = NULL
--WITH RECOMPILE
AS
BEGIN

	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	 DECLARE
	 @UserIDLocal varchar(50) = @UserID
	,@DateRangeLocal int = @DateRange
	,@CustomerLocal varchar(50) = @Customer
	,@IsCompletedLocal bit = @IsCompleted
	,@AfterHoursFilterLocal bit = @AfterHoursFilter
	,@RecipientIDLocal varchar(50) = @RecipientID
	,@CopcFacilityIDLocal varchar(50) = @CopcFacilityID
	,@CopcPCP_NPILocal varchar(50) = @CopcPCP_NPI
	,@MemberIDLocal VARCHAR(20) = @MemberID



	SELECT	 
		@AfterHoursFilterLocal = NULLIF(@AfterHoursFilterLocal,0)
	,@CopcFacilityID = NULLIF(@CopcFacilityID,'0')
	,@RecipientIDLocal = NULLIF(@RecipientIDLocal, '0')
	
	Declare @TIN varchar(60) = NULL

	DECLARE @DateRangeFilter DATE, @TopValue INT, @VisitCountDateRange DATETIME = DATEADD(MM,-6,GETDATE())

	SELECT @TopValue = CASE WHEN ABS(@DateRangeLocal) = 50 THEN 50 ELSE 1000000 END

	SELECT @DateRangeFilter = CASE WHEN @DateRangeLocal <= 0 THEN CONVERT(DATETIME,'1/1/1980') ELSE DATEADD(DD, -@DateRangeLocal , GETUTCDATE()) END

	DECLARE @AlertGroups TABLE (GroupID NVARCHAR(100))
	INSERT INTO @AlertGroups (GroupID)
	SELECT group_ID 
	FROM dbo.Link_HPAlertGroupAgent 
	WHERE Agent_ID = CAST(@UserIDLOcal AS NVARCHAR(100))

	Drop table If exists #TINGroups
	Create TABLE #TINGroups (GroupName NVARCHAR(100))
	INSERT INTO #TINGroups
	Select Distinct G.GroupName
	From MDGroup G JOIN Link_MDAccountGroup L ON L.MDGroupID = G.ID
	JOIN MDUser U ON U.ID = L.MDAccountID
	Where U.UserName = CAST(@UserIDLOcal AS NVARCHAR(100))

	DROP TABLE IF EXISTS #T
	Create Table #T (ID int)

	IF EXISTS (SELECT 1 FROM #TINGroups) 
	BEGIN
		
		Drop table if exists #HPAlerts_ProvLink
		SELECT MIN(A.ID) AS ID, AlertDate, MemberID, RecipientCustID, TriggerID
		INTO #HPAlerts_ProvLink
		FROM dbo.HPAlert A JOIN HPAlertGroup G ON Cust_ID = RecipientCustID and A.AgentID = CAST(G.ID as varchar(10))
		WHERE RecipientCustID = @CustomerLocal
		AND (RecipientType = 'Group')
		AND AlertDate > @DateRangeFilter
		AND G.Active = 1
		GROUP BY AlertDate, MemberID, RecipientCustID, TriggerID

		CREATE NONCLUSTERED INDEX [IX_X] ON #HPAlerts_ProvLink ([ID])

		INSERT INTO #T
		SELECT TOP(@TopValue) h.ID
		FROM dbo.HPAlert h 
		JOIN #HPAlerts_ProvLink mh ON h.ID = mh.ID
		JOIN MainSpecialist S ON S.ICENUMBER = h.MVDID 
		JOIN Link_MDGroupNPI N ON N.NPI = S.NPI 
		JOIN MDGroup G ON G.ID = N.MDGroupID and G.GroupName = S.TIN
		JOIN HPAlertGroup AG ON Cust_ID = h.RecipientCustID and h.AgentID = CAST(AG.ID as varchar(10))
		WHERE h.RecipientCustID = @CustomerLocal
		AND (h.RecipientType = 'Group')
		AND h.AlertDate > @DateRangeFilter
		AND AG.Active = 1
		AND G.GroupName in (Select GroupName from #TINGroups)
	ORDER BY CASE WHEN @DateRangeLocal >= 0 THEN h.AlertDate END DESC, CASE @DateRangeLocal WHEN -50 THEN h.AlertDate END, h.ID
	END
	ELSE 
	BEGIN
		INSERT INTO #T
		SELECT TOP(@TopValue) h.ID
		FROM dbo.HPAlert h 
		JOIN
		(
			SELECT MIN(ID) AS ID, AlertDate, MemberID, RecipientCustID, TriggerID
			FROM dbo.HPAlert
			WHERE RecipientCustID = @CustomerLocal
			AND (@UserIDLOcal IS NULL OR (RecipientType = 'Group' AND AgentID IN (SELECT GroupID FROM @AlertGroups)))
			AND AlertDate > @DateRangeFilter
			GROUP BY AlertDate, MemberID, RecipientCustID, TriggerID
		) mh ON h.ID = mh.ID
		LEFT JOIN MainSpecialist S ON S.ICENUMBER = h.MVDID 
		LEFT JOIN Link_MDGroupNPI N ON N.NPI = S.NPI 
		LEFT JOIN MDGroup G ON G.ID = N.MDGroupID and G.GroupName = S.TIN
		WHERE h.RecipientCustID = @CustomerLocal
		AND (@UserIDLOcal IS NULL OR (h.RecipientType = 'Group' AND h.AgentID IN (SELECT GroupID FROM @AlertGroups)))
		AND h.AlertDate > @DateRangeFilter
		ORDER BY CASE WHEN @DateRangeLocal >= 0 THEN h.AlertDate END DESC, CASE @DateRangeLocal WHEN -50 THEN h.AlertDate END, h.ID
	END

	;WITH CTE_Data AS
	(
		SELECT hwr.[Group], hwr.[Name], COUNT(*) AS Records
		FROM dbo.HPAlert h
		JOIN dbo.Link_MemberID_MVD_Ins lm ON h.MemberID = lm.InsMemberId AND lm.cust_id = h.RecipientCustID
		JOIN dbo.MainPersonalDetails mpd ON h.MVDId = mpd.ICENUMBER
		JOIN dbo.LookupHPAlertStatus lh ON h.StatusID = lh.ID 
		JOIN dbo.HPWorkflowRule hwr ON h.TriggerID = hwr.Rule_ID
		WHERE EXISTS (SELECT 1 FROM #T WHERE ID = h.ID)
		AND lh.IsCompleted= @IsCompletedLocal
		AND lm.Cust_ID = @CustomerLocal
		AND (@MemberIDLocal IS NULL OR lm.InsMemberId = @MemberIDLocal)
		AND (@AfterHoursFilterLocal IS NULL OR h.StatusID = @AfterHoursFilterLocal)
		GROUP BY hwr.[Group], hwr.[Name]
	)
	,CTE_Agg AS
	(
		SELECT [Group], [Name], Records, Total = (SELECT SUM(Records) FROM CTE_Data)
		FROM CTE_Data
	) 

	SELECT [Group], [Name], Records, Total, Records / CAST(Total AS DECIMAL(8,2)) AS Pct
	FROM CTE_Agg

END