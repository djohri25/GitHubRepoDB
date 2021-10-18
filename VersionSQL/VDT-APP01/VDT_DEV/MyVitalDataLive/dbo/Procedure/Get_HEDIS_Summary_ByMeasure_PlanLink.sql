/****** Object:  Procedure [dbo].[Get_HEDIS_Summary_ByMeasure_PlanLink]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		Misha
-- Create date: 
-- Description:	Gets HEDIS Summary counts for all measures (first page of the ScoreCard)
-- Modification:01/24/2017		Misha		Removed Link_MDGroupNPI from the case when the GroupID is not null to avoid missed NPIs
-- Changes:	MDeLuca	01/15/2018	Made changes for new Get_HEDIS_CurYearOverallPercentage
-- =============================================
CREATE PROCEDURE [dbo].[Get_HEDIS_Summary_ByMeasure_PlanLink]
(	
	@Abbreviation varchar(50),
	@CustID int,
	@LOB varchar(50) = 'ALL',
	@NPI varchar(50),
	@PCP_GroupID int = NULL,
	@MonthID	char(6)
)
AS
BEGIN

	SET NOCOUNT ON;

	DROP TABLE IF EXISTS #N;
	CREATE TABLE #N (NPI VARCHAR(20))

	IF @PCP_GroupID IS NOT NULL
	BEGIN
		INSERT INTO #N (NPI)
		SELECT DISTINCT NPI
		FROM dbo.Link_MDGroupNPI
		WHERE MDGroupID = @PCP_GroupID
	END

	DECLARE @Total int, @Complete int, @Due int, @MonthID_Check	char(6), @LastMonth int, @PrevYearPerc DECIMAL(8,2), @PrevYear_Total DECIMAL(8,2), @PrevYear_Complete DECIMAL(8,2), @Last_Total int, @Last_Complete int, @Last_MonthID int, @Previous_Total int, @Previous_Complete int
	DECLARE @Hedis_ID int, @Hedis_Name varchar (100), @Hedis_TestType varchar (50), @TestGoal DECIMAL(8,2)
	DECLARE @CurYearToDatePerc decimal(8,4), @CurYearOverall decimal(8,4), @YTD_Goal_Status int, @Year_Overall_Status int, @MeasureEndMonth INT, @MeasureCycleEndDate DATE
	DECLARE @LOB_Temp varchar(50)

	SELECT @Hedis_ID = [ID], @Hedis_Name = [Name], @Hedis_TestType = [TestType], @MeasureEndMonth = MONTH(MeasuramentYearEnd)
	FROM [dbo].[LookupHedis]
	WHERE [Abbreviation] = @Abbreviation

	SET @MeasureCycleEndDate = DATEFROMPARTS(CASE WHEN @MeasureEndMonth < RIGHT(@MonthID,2) THEN LEFT(@MonthID,4) + 1 ELSE LEFT(@MonthID,4) END, @MeasureEndMonth, '01')

	SELECT @TestGoal = Goal FROM HPTestDueGoal WHERE CustID = @CustID AND TestDueID = @Hedis_ID

	SELECT @MonthID_Check = Max(MonthID) from [dbo].[Final_HEDIS_Member_FULL] where Custid = @CustID AND [TestID] = @Hedis_ID and MonthID <= @MonthID

	IF @MonthID > @MonthID_Check
	BEGIN 
		SET @MonthID = @MonthID_Check
	END

	IF (RIGHT(@MonthID, 2) = '01')
	BEGIN
		SELECT @Last_MonthID = CONVERT(INT, CONVERT(VARCHAR(4), LEFT(@MonthID, 4) - 1) + '12')
	END
	ELSE
	BEGIN
		SELECT @Last_MonthID = @MonthID - 1
	END

	--TODO: set different END DATE for certain measures
	SELECT @LastMonth = CAST(CAST((YEAR(GETDATE()) - 1) AS varchar(4)) + '12' AS int)

	SELECT @LOB_Temp = (CASE WHEN @LOB = 'ALL' THEN '' ELSE @LOB END)
	--(CASE
	--						WHEN (@LOB = 'ALL') THEN ''
	--						WHEN (@LOB = 'STAR') THEN 'M'
	--						WHEN (@LOB = 'CHIP') THEN 'C'
	--						ELSE @LOB
	--					END)

	If (@PCP_GroupID IS NOT NULL AND @PCP_GroupID != '')
	BEGIN
		If (@NPI = 'All' OR @NPI IS NULL OR @NPI = '')
		BEGIN
			SELECT @PrevYear_Total = 0 
			SELECT @PrevYear_Complete = 0

			IF (@LOB_Temp = '')
			BEGIN

				--This Year
				SELECT @Total = Count(g.ID) FROM [dbo].[Final_HEDIS_Member_FULL] g
					INNER JOIN [dbo].[MDGroup] m ON g.PCP_TIN = m.GroupName AND [CustID_Import] = g.CustID
					--INNER JOIN [dbo].[Link_MDGroupNPI] n on g.PCP_NPI = n.NPI and m.ID = n.MDGroupID
				WHERE CustID = @CustID
					AND MonthID = @MonthID
					AND [TestID] = @Hedis_ID
					AND m.ID = @PCP_GroupID

				SELECT @Complete = Count(g.ID) FROM [dbo].[Final_HEDIS_Member_FULL] g
					INNER JOIN [dbo].[MDGroup] m ON g.PCP_TIN = m.GroupName AND [CustID_Import] = g.CustID
					--INNER JOIN [dbo].[Link_MDGroupNPI] n on g.PCP_NPI = n.NPI and m.ID = n.MDGroupID
				WHERE CustID = @CustID
					AND [IsTestDue] = 1
					AND MonthID = @MonthID
					AND [TestID] = @Hedis_ID
					AND m.ID = @PCP_GroupID

				--Previous Year
				SELECT @PrevYear_Total = Count(g.ID) FROM [dbo].[Final_HEDIS_Member_FULL] g
					INNER JOIN [dbo].[MDGroup] m ON g.PCP_TIN = m.GroupName AND [CustID_Import] = g.CustID
					--INNER JOIN [dbo].[Link_MDGroupNPI] n on g.PCP_NPI = n.NPI and m.ID = n.MDGroupID
				WHERE CustID = @CustID
					AND MonthID = @Last_MonthID
					AND [TestID] = @Hedis_ID
					AND m.ID = @PCP_GroupID

				SELECT @PrevYear_Complete = Count(g.ID) FROM [dbo].[Final_HEDIS_Member_FULL] g
					INNER JOIN [dbo].[MDGroup] m ON g.PCP_TIN = m.GroupName AND [CustID_Import] = g.CustID
					--INNER JOIN [dbo].[Link_MDGroupNPI] n on g.PCP_NPI = n.NPI and m.ID = n.MDGroupID
				WHERE CustID = @CustID
					AND [IsTestDue] = 1
					AND MonthID = @Last_MonthID
					AND [TestID] = @Hedis_ID
					AND m.ID = @PCP_GroupID
			END
			ELSE
			BEGIN
				--This Year
				SELECT @Total = Count(g.ID) FROM [dbo].[Final_HEDIS_Member_FULL] g
					INNER JOIN [dbo].[MDGroup] m ON g.PCP_TIN = m.GroupName AND [CustID_Import] = g.CustID
					--INNER JOIN [dbo].[Link_MDGroupNPI] n on g.PCP_NPI = n.NPI and m.ID = n.MDGroupID
				WHERE CustID = @CustID
					AND MonthID = @MonthID
					AND [TestID] = @Hedis_ID
					AND m.ID = @PCP_GroupID
					AND LOB = @LOB_Temp

				SELECT @Complete = Count(g.ID) FROM [dbo].[Final_HEDIS_Member_FULL] g
					INNER JOIN [dbo].[MDGroup] m ON g.PCP_TIN = m.GroupName AND [CustID_Import] = g.CustID
					--INNER JOIN [dbo].[Link_MDGroupNPI] n on g.PCP_NPI = n.NPI and m.ID = n.MDGroupID
				WHERE CustID = @CustID
					AND [IsTestDue] = 1
					AND MonthID = @MonthID
					AND [TestID] = @Hedis_ID
					AND m.ID = @PCP_GroupID
					AND LOB = @LOB_Temp

				--Previous Year
				SELECT @PrevYear_Total = Count(g.ID) FROM [dbo].[Final_HEDIS_Member_FULL] g
					INNER JOIN [dbo].[MDGroup] m ON g.PCP_TIN = m.GroupName AND [CustID_Import] = g.CustID
					--INNER JOIN [dbo].[Link_MDGroupNPI] n on g.PCP_NPI = n.NPI and m.ID = n.MDGroupID
				WHERE CustID = @CustID
					AND MonthID = @Last_MonthID
					AND [TestID] = @Hedis_ID
					AND m.ID = @PCP_GroupID
					AND LOB = @LOB_Temp

				SELECT @PrevYear_Complete = Count(g.ID) FROM [dbo].[Final_HEDIS_Member_FULL] g
					INNER JOIN [dbo].[MDGroup] m ON g.PCP_TIN = m.GroupName AND [CustID_Import] = g.CustID
					--INNER JOIN [dbo].[Link_MDGroupNPI] n on g.PCP_NPI = n.NPI and m.ID = n.MDGroupID
				WHERE CustID = @CustID
					AND [IsTestDue] = 1
					AND MonthID = @Last_MonthID
					AND [TestID] = @Hedis_ID
					AND m.ID = @PCP_GroupID
					AND LOB = @LOB_Temp
			END

			SELECT @Due = @Total - @Complete
		END
		ELSE
		BEGIN
			SELECT @PrevYear_Total = 0 
			SELECT @PrevYear_Complete = 0

			IF (@LOB_Temp = '')
			BEGIN
				--This Year
				SELECT @Total = Count(g.ID) FROM [dbo].[Final_HEDIS_Member_FULL] g
					INNER JOIN [dbo].[MDGroup] m ON g.PCP_TIN = m.GroupName AND [CustID_Import] = g.CustID
					INNER JOIN [dbo].[Link_MDGroupNPI] n on g.PCP_NPI = n.NPI and m.ID = n.MDGroupID
				WHERE CustID = @CustID AND
					  [PCP_NPI] = @NPI AND
					  MonthID = @MonthID AND
					  [TestID] = @Hedis_ID AND
					  n.MDGroupID = @PCP_GroupID

				SELECT @Complete = Count(g.ID) FROM [dbo].[Final_HEDIS_Member_FULL] g
					INNER JOIN [dbo].[MDGroup] m ON g.PCP_TIN = m.GroupName AND [CustID_Import] = g.CustID
					INNER JOIN [dbo].[Link_MDGroupNPI] n on g.PCP_NPI = n.NPI and m.ID = n.MDGroupID
				WHERE CustID = @CustID AND
					  [IsTestDue] = 1 AND
					  [PCP_NPI] = @NPI AND
					  MonthID = @MonthID AND
					  [TestID] = @Hedis_ID AND
					  n.MDGroupID = @PCP_GroupID

				--Previous Year
				SELECT @PrevYear_Total = Count(g.ID) FROM [dbo].[Final_HEDIS_Member_FULL] g
					INNER JOIN [dbo].[MDGroup] m ON g.PCP_TIN = m.GroupName AND [CustID_Import] = g.CustID
					INNER JOIN [dbo].[Link_MDGroupNPI] n on g.PCP_NPI = n.NPI and m.ID = n.MDGroupID
				WHERE CustID = @CustID AND
					  [PCP_NPI] = @NPI AND
					  MonthID = @Last_MonthID AND
					  [TestID] = @Hedis_ID AND
					  n.MDGroupID = @PCP_GroupID

				SELECT @PrevYear_Complete = Count(g.ID) FROM [dbo].[Final_HEDIS_Member_FULL] g
					INNER JOIN [dbo].[MDGroup] m ON g.PCP_TIN = m.GroupName AND [CustID_Import] = g.CustID
					INNER JOIN [dbo].[Link_MDGroupNPI] n on g.PCP_NPI = n.NPI and m.ID = n.MDGroupID
				WHERE CustID = @CustID AND
					  [IsTestDue] = 1 AND
					  [PCP_NPI] = @NPI AND
					  MonthID = @Last_MonthID AND
					  [TestID] = @Hedis_ID AND
					  n.MDGroupID = @PCP_GroupID
			END
			ELSE
			BEGIN
				--This Year
				SELECT @Total = Count(g.ID) FROM [dbo].[Final_HEDIS_Member_FULL] g
					INNER JOIN [dbo].[MDGroup] m ON g.PCP_TIN = m.GroupName AND [CustID_Import] = g.CustID
					INNER JOIN [dbo].[Link_MDGroupNPI] n on g.PCP_NPI = n.NPI and m.ID = n.MDGroupID
				WHERE CustID = @CustID AND
					  [PCP_NPI] = @NPI AND
					  MonthID = @MonthID AND
					  [TestID] = @Hedis_ID AND
					  n.MDGroupID = @PCP_GroupID AND
					  LOB = @LOB_Temp

				SELECT @Complete = Count(g.ID) FROM [dbo].[Final_HEDIS_Member_FULL] g
					INNER JOIN [dbo].[MDGroup] m ON g.PCP_TIN = m.GroupName AND [CustID_Import] = g.CustID
					INNER JOIN [dbo].[Link_MDGroupNPI] n on g.PCP_NPI = n.NPI and m.ID = n.MDGroupID
				WHERE CustID = @CustID AND
					  [IsTestDue] = 1 AND
					  [PCP_NPI] = @NPI AND
					  MonthID = @MonthID AND
					  [TestID] = @Hedis_ID AND
					  n.MDGroupID = @PCP_GroupID AND
					  LOB = @LOB_Temp

				--Previous Year
				SELECT @PrevYear_Total = Count(g.ID) FROM [dbo].[Final_HEDIS_Member_FULL] g
					INNER JOIN [dbo].[MDGroup] m ON g.PCP_TIN = m.GroupName AND [CustID_Import] = g.CustID
					INNER JOIN [dbo].[Link_MDGroupNPI] n on g.PCP_NPI = n.NPI and m.ID = n.MDGroupID
				WHERE CustID = @CustID AND
					  [PCP_NPI] = @NPI AND
					  MonthID = @Last_MonthID AND
					  [TestID] = @Hedis_ID AND
					  n.MDGroupID = @PCP_GroupID AND
					  LOB = @LOB_Temp

				SELECT @PrevYear_Complete = Count(g.ID) FROM [dbo].[Final_HEDIS_Member_FULL] g
					INNER JOIN [dbo].[MDGroup] m ON g.PCP_TIN = m.GroupName AND [CustID_Import] = g.CustID
					INNER JOIN [dbo].[Link_MDGroupNPI] n on g.PCP_NPI = n.NPI and m.ID = n.MDGroupID
				WHERE CustID = @CustID AND
					  [IsTestDue] = 1 AND
					  [PCP_NPI] = @NPI AND
					  MonthID = @Last_MonthID AND
					  [TestID] = @Hedis_ID AND
					  n.MDGroupID = @PCP_GroupID AND
					  LOB = @LOB_Temp
			END
			
			SELECT @Due = @Total - @Complete
		END
	END
	ELSE
	BEGIN
		If (@NPI = 'All' OR @NPI IS NULL OR @NPI = '')
		BEGIN
			SELECT @PrevYear_Total = 0 
			SELECT @PrevYear_Complete = 0

			IF (@LOB_Temp = '')
			BEGIN
				--This Year
				SELECT @Total = Count(ID) FROM [dbo].[Final_HEDIS_Member_FULL]
				WHERE CustID = @CustID AND
					  MonthID = @MonthID AND
					  [TestID] = @Hedis_ID

				SELECT @Complete = Count(ID) FROM [dbo].[Final_HEDIS_Member_FULL]
				WHERE CustID = @CustID AND
					  [IsTestDue] = 1 AND
					  MonthID = @MonthID AND
					  [TestID] = @Hedis_ID

				--Previous Year
				SELECT @PrevYear_Total = Count(ID) FROM [dbo].[Final_HEDIS_Member_FULL]
				WHERE CustID = @CustID AND
					  MonthID = @Last_MonthID AND
					  [TestID] = @Hedis_ID

				SELECT @PrevYear_Complete = Count(ID) FROM [dbo].[Final_HEDIS_Member_FULL]
				WHERE CustID = @CustID AND
					  [IsTestDue] = 1 AND
					  MonthID = @Last_MonthID AND
					  [TestID] = @Hedis_ID
			END
			ELSE
			BEGIN
				--This Year
				SELECT @Total = Count(ID) FROM [dbo].[Final_HEDIS_Member_FULL]
				WHERE CustID = @CustID AND
					  MonthID = @MonthID AND
					  [TestID] = @Hedis_ID AND
					  LOB = @LOB_Temp

				SELECT @Complete = Count(ID) FROM [dbo].[Final_HEDIS_Member_FULL]
				WHERE CustID = @CustID AND
					  [IsTestDue] = 1 AND
					  MonthID = @MonthID AND
					  [TestID] = @Hedis_ID AND
					  LOB = @LOB_Temp

				--Previous Year
				SELECT @PrevYear_Total = Count(ID) FROM [dbo].[Final_HEDIS_Member_FULL]
				WHERE CustID = @CustID AND
					  MonthID = @Last_MonthID AND
					  [TestID] = @Hedis_ID AND
					  LOB = @LOB_Temp

				SELECT @PrevYear_Complete = Count(ID) FROM [dbo].[Final_HEDIS_Member_FULL]
				WHERE CustID = @CustID AND
					  [IsTestDue] = 1 AND
					  MonthID = @Last_MonthID AND
					  [TestID] = @Hedis_ID AND
					  LOB = @LOB_Temp
			END

			SELECT @Due = @Total - @Complete
		END
		ELSE
		BEGIN
			SELECT @PrevYear_Total = 0 
			SELECT @PrevYear_Complete = 0

			IF (@LOB_Temp = '')
			BEGIN
				--This Year
				SELECT @Total = Count(ID) FROM [dbo].[Final_HEDIS_Member_FULL]
				WHERE CustID = @CustID AND
					  [PCP_NPI] = @NPI AND
					  MonthID = @MonthID AND
					  [TestID] = @Hedis_ID

				SELECT @Complete = Count(ID) FROM [dbo].[Final_HEDIS_Member_FULL]
				WHERE CustID = @CustID AND
					  [IsTestDue] = 1 AND
					  [PCP_NPI] = @NPI AND
					  MonthID = @MonthID AND
					  [TestID] = @Hedis_ID

				--Previous Year
				SELECT @PrevYear_Total = Count(ID) FROM [dbo].[Final_HEDIS_Member_FULL]
				WHERE CustID = @CustID AND
					  [PCP_NPI] = @NPI AND
					  MonthID = @Last_MonthID AND
					  [TestID] = @Hedis_ID

				SELECT @PrevYear_Complete = Count(ID) FROM [dbo].[Final_HEDIS_Member_FULL]
				WHERE CustID = @CustID AND
					  [IsTestDue] = 1 AND
					  [PCP_NPI] = @NPI AND
					  MonthID = @Last_MonthID AND
					  [TestID] = @Hedis_ID
			END
			ELSE
			BEGIN
				--This Year
				SELECT @Total = Count(ID) FROM [dbo].[Final_HEDIS_Member_FULL]
				WHERE CustID = @CustID AND
					  [PCP_NPI] = @NPI AND
					  MonthID = @MonthID AND
					  [TestID] = @Hedis_ID AND
					  LOB = @LOB_Temp

				SELECT @Complete = Count(ID) FROM [dbo].[Final_HEDIS_Member_FULL]
				WHERE CustID = @CustID AND
					  [IsTestDue] = 1 AND
					  [PCP_NPI] = @NPI AND
					  MonthID = @MonthID AND
					  [TestID] = @Hedis_ID AND
					  LOB = @LOB_Temp

				--Previous Year
				SELECT @PrevYear_Total = Count(ID) FROM [dbo].[Final_HEDIS_Member_FULL]
				WHERE CustID = @CustID AND
					  [PCP_NPI] = @NPI AND
					  MonthID = @Last_MonthID AND
					  [TestID] = @Hedis_ID AND
					  LOB = @LOB_Temp

				SELECT @PrevYear_Complete = Count(ID) FROM [dbo].[Final_HEDIS_Member_FULL]
				WHERE CustID = @CustID AND
					  [IsTestDue] = 1 AND
					  [PCP_NPI] = @NPI AND
					  MonthID = @Last_MonthID AND
					  [TestID] = @Hedis_ID AND
					  LOB = @LOB_Temp
			END

			SELECT @Due = @Total - @Complete
		END
	END

	SELECT @CurYearToDatePerc = 0

	IF (ISNULL(@Complete, 0) > 0)
	BEGIN
		SELECT @CurYearToDatePerc = (CONVERT(decimal(18,4), @Complete) / CONVERT(decimal(18,4), NULLIF(@Total, 0))) * 100
	END
	
	IF (@CurYearToDatePerc < @TestGoal)
	BEGIN
		SELECT @YTD_Goal_Status = -1
	END
	ELSE
	BEGIN
		SELECT @YTD_Goal_Status = 1
	END

	-- Added 12/28/2017
	IF @MeasureCycleEndDate < DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), '01')
				BEGIN
							SELECT @CurYearOverall = (SUM(CAST(IsTestDue AS INT)) /  CAST(COUNT(*) AS DECIMAL(38,17))) * 100
							FROM dbo.Final_HEDIS_Member_FULL
							WHERE CustID = @CustID
							AND MonthID = CAST(YEAR(@MeasureCycleEndDate) AS CHAR(4)) + CASE WHEN LEN(@MeasureEndMonth) = 1 THEN '0'+CAST(@MeasureEndMonth AS CHAR(1)) ELSE CAST(@MeasureEndMonth AS CHAR(2)) END
							AND TestID = @Hedis_ID
							AND (NULLIF(NULLIF(@NPI,''),'All') IS NULL OR PCP_NPI = @NPI)
							AND (@PCP_GroupID IS NULL OR PCP_NPI IN (SELECT NPI FROM #N))

							IF @CurYearOverall IS NULL
							SELECT @CurYearOverall = (SUM(CAST(IsTestDue AS INT)) /  CAST(COUNT(*) AS DECIMAL(38,17))) * 100
							FROM dbo.Final_HEDIS_Member_FULL
							WHERE CustID = @CustID
							AND MonthID = (SELECT MAX(MonthID) FROM dbo.Final_HEDIS_Member_FULL WHERE CustID = @CustID AND LEFT(MonthID,4) = LEFT(@MonthID,4) AND TestID = @Hedis_ID)
							AND TestID = @Hedis_ID
							AND (NULLIF(NULLIF(@NPI,''),'All') IS NULL OR PCP_NPI = @NPI)
							AND (@PCP_GroupID IS NULL OR PCP_NPI IN (SELECT NPI FROM #N))

				END
	ELSE
	EXEC Get_HEDIS_CurYearOverallPercentage	
		@TestID = @Hedis_ID,
		@TIN = '',
		@CustID = @CustID,
		@NPI = @NPI,
		@PCP_GroupID = @PCP_GroupID,
		@CurYearToDatePerc = @CurYearToDatePerc,
		@YearOverallPercentage = @CurYearOverall output

	IF (@CurYearOverall < @TestGoal)
	BEGIN
		SELECT @Year_Overall_Status = -1
	END
	ELSE
	BEGIN
		SELECT @Year_Overall_Status = 1
	END

	If (ISNULL(@PrevYear_Complete, 0) > 0)
	BEGIN
		SELECT @PrevYearPerc = (@PrevYear_Complete / NULLIF(@PrevYear_Total, 0)) * 100
	END

	SELECT @Hedis_ID AS testID,
		   @Abbreviation AS testAbbr,
		   @Hedis_Name AS testName,
		   @Hedis_Name + ' (' + @Abbreviation + ')' AS FullTestName,
		   @Hedis_TestType AS testType,
		   isnull(@PrevYearPerc,0) AS PrevYearPerc,
		   isnull(@CurYearToDatePerc,0) AS CurYearToDatePerc,
		   isnull(@CurYearOverall,0) AS CurYearOverall,
		   @TestGoal AS GoalPerc,
		   0 AS AvgMonthlyDifference,
		   @Total AS QualifyingMemCount,
		   @Complete AS CompletedMemCount,
		   @Due AS DueMemCount,
		   @YTD_Goal_Status AS YearToDateGoalStatus,
		   @Year_Overall_Status AS CurYearOverallGoalStatus,
		   '' AS PCP_NPI,
		   '' AS PCP_GroupID,
		   @CustID AS CustID,
		   0 AS duration,
		   @MonthID as MonthID 
END