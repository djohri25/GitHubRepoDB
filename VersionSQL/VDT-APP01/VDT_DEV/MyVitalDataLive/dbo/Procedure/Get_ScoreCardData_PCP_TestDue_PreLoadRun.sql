/****** Object:  Procedure [dbo].[Get_ScoreCardData_PCP_TestDue_PreLoadRun]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[Get_ScoreCardData_PCP_TestDue_PreLoadRun]
(	@PCP_NPI varchar(20),
	@PCP_GroupID int ,
	@CustID int ,
	@UserType varchar(50),
	@LOB varchar(50) = 'ALL',
	@MonthID	char(6)
)
AS
---------------------------------------------------------------------------------------------------
--Date			Name				Comments
--10/26/16		Ppetluri			As per Misha's email added join HPTestDueGoal to fix the issue of Measures showing up that does not belog to that client
--04/10/17		PPetluri			Added Created Column on ScoreCard_PCP so changed the select code for "INSERT INTO #TEMP_RESULTS" 
--06/12/17		PPetluri			Added PlankLink_Active = 1 to show only the measures that should be shown in plan link
--07/14/2017	PPetluri			Fixed Column length issues
---------------------------------------------------------------------------------------------------
--DECLARE 	@PCP_NPI varchar(20),
--			@PCP_GroupID int ,
--			@CustID int ,
--			@UserType varchar(50),
--			@LOB varchar(50) = 'ALL' ,
--			@MonthID	char(6)


--set @PCP_NPI = ''
--set @PCP_GroupID = 0
--set @CustID = 11
--set @UserType = 'HP'
--set @LOB = 'ALL'
--set @MonthID = '201607'

BEGIN

SET NOCOUNT ON;

IF OBJECT_ID('tempdb.dbo.#TEMP_RESULTS', 'U') IS NOT NULL 
DROP TABLE #TEMP_RESULTS

CREATE TABLE #TEMP_RESULTS
	(testID INT, testAbbr VARCHAR(100), testName VARCHAR(1000), FullTestName VARCHAR(1000), testType VARCHAR(500), PrevYearPerc DECIMAL(8,2), CurYearToDatePerc DECIMAL(8,2), CurYearOverall DECIMAL(8,2), GoalPerc DECIMAL(8,2), AvgMonthlyDifference  DECIMAL(8,2) ,QualifyingMemCount INT, CompletedMemCount INT, DueMemCount INT, YearToDateGoalStatus INT, CurYearOverallGoalStatus INT ,PCP_NPI VARCHAR(50),	PCP_GroupID	 VARCHAR(500), CustID INT,duration VARCHAR(50), MonthID char(6))


Declare @Abbreviation varchar(50), @MonthID_Check char(6), @TestID INT
DECLARE @Hedis_ID int, @Hedis_Name varchar (100), @Hedis_TestType varchar (50), @TestGoal DECIMAL(8,2)

DECLARE @Abbreviations TABLE ( Abbreviation varchar(50))
DECLARE @TEST TABLE ( TestID INT)
	
	INSERT INTO @TEST (TestID)
	SELECT Distinct TestID
	FROM [dbo].[LookupHedis]
	WHERE [TestType] IN ('Predictive', 'Real', '3Percent')
		AND [MeasuramentYearStart] IS NOT NULL and TestID is not null --and Abbreviation in ('ASM1')--('MMA1A', 'AMM2')
	ORDER BY TestID

	WHILE EXISTS (SELECT TOP 1 * FROM @TEST)
	BEGIN

		SELECT TOP 1  @TestID = TestID FROM @TEST

		INSERT INTO @Abbreviations (Abbreviation)
		SELECT Abbreviation
		FROM [dbo].[LookupHedis] L JOIN @TEST t on L.TestID = t.TestID
		JOIN HPTestDueGoal TG ON TG.TestDueID = L.ID
		WHERE [TestType] IN ('Predictive', 'Real', '3Percent') AND TG.PlankLink_Active = 1
			AND [MeasuramentYearStart] IS NOT NULL and L.TestID = @TestID and TG.CustID = @CustID
		ORDER BY Abbreviation

		IF EXISTS (Select * from ScoreCard_PCP SC JOIN [dbo].[LookupHedis] L ON L.ID = SC.testID and L.Abbreviation = SC.testAbbr WHere CustID = @CustID and SC.MonthID = @MonthID and L.TestID = @TestID)
		BEGIN
			WHILE EXISTS (SELECT TOP 1 * FROM @Abbreviations)
			BEGIN
				SET @Hedis_ID = NULL
				SET @Hedis_Name = NULL
				SET @Hedis_TestType = NULL
				SET @TestGoal = NULL
				SET @MonthID_Check = NULL

				SELECT TOP 1  @Abbreviation = Abbreviation FROM @Abbreviations

				SELECT @Hedis_ID = [ID], @Hedis_Name = [Name], @Hedis_TestType = [TestType]
				FROM [dbo].[LookupHedis]
				WHERE [Abbreviation] = @Abbreviation

				SELECT @TestGoal = Goal FROM HPTestDueGoal WHERE CustID = @CustID AND TestDueID = @Hedis_ID

				IF NOT EXISTS (Select 1 from ScoreCard_PCP WHERE CustID = @CustID AND testAbbr = @Abbreviation and MonthID = @MonthID)
				BEGIN
						INSERT INTO #TEMP_RESULTS
						Select @Hedis_ID AS testID,
						   @Abbreviation AS testAbbr,
						   @Hedis_Name AS testName,
						   @Hedis_Name + ' (' + @Abbreviation + ')' AS FullTestName,
						   @Hedis_TestType AS testType,	
						   0,
						   0,
						   0,
						   @TestGoal AS GoalPerc,
						   0 AS AvgMonthlyDifference,
						   0,
						   0,
						   0,
						   0,
						   0,
						   '' AS PCP_NPI,
						   '' AS PCP_GroupID,
						   @CustID AS CustID,
						   0 AS duration ,
						   @MonthID as MonthID
				END
				ELSE 
				BEGIN 
				--Print '3rd '+ @Abbreviation+ ' Data Exists for CustID = @CustID AND testAbbr = @Abbreviation and MonthID = @MonthID'
					INSERT INTO #TEMP_RESULTS
					Select testID, testAbbr, testName, FullTestName, testType, PrevYearPerc, CurYearToDatePerc, CurYearOverall, GoalPerc, AvgMonthlyDifference, QualifyingMemCount, CompletedMemCount, DueMemCount, YearToDateGoalStatus, CurYearOverallGoalStatus, PCP_NPI, PCP_GroupID, CustID, duration, MonthID
					from ScoreCard_PCP WHERE CustID = @CustID AND testAbbr = @Abbreviation and MonthID = @MonthID	
				END
			
					--Select @Abbreviation as Abbr , @MonthID as MonthID, @MonthID_Check as MonthID_Check
				--Print @Abbreviation +' '+ @MonthID +' '+ @MonthID_Check 
				Delete From @Abbreviations Where Abbreviation = @Abbreviation
			END
		END
		ELSE IF NOT EXISTS (Select * from ScoreCard_PCP SC JOIN [dbo].[LookupHedis] L ON L.ID = SC.testID and L.Abbreviation = SC.testAbbr WHere CustID = @CustID and SC.MonthID = @MonthID AND L.TestID = @TestID)
		BEGIN
			WHILE EXISTS (SELECT TOP 1 * FROM @Abbreviations)
			BEGIN

				SELECT TOP 1  @Abbreviation = Abbreviation FROM @Abbreviations

				SET @Hedis_ID = NULL
				SET @Hedis_Name = NULL
				SET @Hedis_TestType = NULL
				SET @TestGoal = NULL
				SET @MonthID_Check = NULL

				SELECT @Hedis_ID = [ID], @Hedis_Name = [Name], @Hedis_TestType = [TestType]
				FROM [dbo].[LookupHedis]
				WHERE [Abbreviation] = @Abbreviation

				SELECT @TestGoal = Goal FROM HPTestDueGoal WHERE CustID = @CustID AND TestDueID = @Hedis_ID

				IF NOT EXISTS (Select 1 from ScoreCard_PCP WHERE CustID = @CustID AND testAbbr = @Abbreviation and MonthID = @MonthID)
				BEGIN
				--Print '2nd '+ @Abbreviation	
					SELECT @MonthID_Check = Max(MonthID) from [dbo].[ScoreCard_PCP] where Custid = @CustID AND [TestID] = @Hedis_ID and testAbbr = @Abbreviation and MonthID < @MonthID

					IF @MonthID > @MonthID_Check
					BEGIN 
					--Print 'MonthID_Check'
						INSERT INTO #TEMP_RESULTS
						Select testID, testAbbr, testName, FullTestName, testType, PrevYearPerc, CurYearToDatePerc, CurYearOverall, GoalPerc, AvgMonthlyDifference, QualifyingMemCount, CompletedMemCount, DueMemCount, YearToDateGoalStatus, CurYearOverallGoalStatus, PCP_NPI, PCP_GroupID, CustID, duration, MonthID 
						from ScoreCard_PCP WHERE CustID = @CustID AND testAbbr = @Abbreviation and MonthID = @MonthID_Check	
					END
					ELSE IF (@MonthID_Check is NULL and @TestGoal IS NOT NULL)
					BEGIN
						INSERT INTO #TEMP_RESULTS
						Select @Hedis_ID AS testID,
						   @Abbreviation AS testAbbr,
						   @Hedis_Name AS testName,
						   @Hedis_Name + ' (' + @Abbreviation + ')' AS FullTestName,
						   @Hedis_TestType AS testType,	
						   0,
						   0,
						   0,
						   @TestGoal AS GoalPerc,
						   0 AS AvgMonthlyDifference,
						   0,
						   0,
						   0,
						   0,
						   0,
						   '' AS PCP_NPI,
						   '' AS PCP_GroupID,
						   @CustID AS CustID,
						   0 AS duration ,
						   NULL as MonthID
					END
				END
				ELSE 
				BEGIN 
				--Print '3rd '+ @Abbreviation+ ' Data Exists for CustID = @CustID AND testAbbr = @Abbreviation and MonthID = @MonthID'
					INSERT INTO #TEMP_RESULTS
					Select testID, testAbbr, testName, FullTestName, testType, PrevYearPerc, CurYearToDatePerc, CurYearOverall, GoalPerc, AvgMonthlyDifference, QualifyingMemCount, CompletedMemCount, DueMemCount, YearToDateGoalStatus, CurYearOverallGoalStatus, PCP_NPI, PCP_GroupID, CustID, duration, MonthID 
					from ScoreCard_PCP WHERE CustID = @CustID AND testAbbr = @Abbreviation and MonthID = @MonthID	
				END

					--Select @Abbreviation as Abbr , @MonthID as MonthID, @MonthID_Check as MonthID_Check
				--Print @Abbreviation +' '+ @MonthID +' '+ @MonthID_Check 
				Delete From @Abbreviations Where Abbreviation = @Abbreviation

			END
		END
		Delete From @Test Where TestID = @TestID
	END
	SELECT * FROM #TEMP_RESULTS ORDER BY 2
	DROP TABLE #TEMP_RESULTS
	
END