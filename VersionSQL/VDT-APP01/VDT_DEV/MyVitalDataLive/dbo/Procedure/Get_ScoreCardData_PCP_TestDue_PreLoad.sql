/****** Object:  Procedure [dbo].[Get_ScoreCardData_PCP_TestDue_PreLoad]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 9/9/2013
-- Description:	Retrieves summary percentages per Hedis test
-- Modification:01/24/2017		Misha		Removed Link_MDGroupNPI from the case when the GroupID is not null to avoid missed NPIs
--						 :12/28/2017		MDeLuca	Added other logic for @CurYearOverall when year is in the past
--							09/04/2018		MDeLuca	Added '3Percent', '5Percent'
-- =============================================
CREATE PROCEDURE [dbo].[Get_ScoreCardData_PCP_TestDue_PreLoad]
	@PCP_NPI varchar(20),
	@PCP_GroupID int ,
	@CustID int ,
	@UserType varchar(50),
	@LOB varchar(50) = 'ALL' --,
	--@MonthID	char(6)
AS
--set @PCP_NPI = ''
--set @PCP_GroupID = 0
--set @CustID = 11
--set @UserType = 'HP'
--set @LOB = 'ALL'
BEGIN
	SET NOCOUNT ON;

	DECLARE @TIN  varchar(20) = null

	If (@CustID != 11)  --- Driscoll is the only SSO user at this time
	BEGIN

		--Select @TIN = MDGroupID from [dbo].[MDUser] a
		--join [Link_MDAccountGroup] b
		--on a.ID = b.MDAccountID
		--where username = @EMS

		SET @TIN = @PCP_GroupID
	END

	--exec [dbo].[Get_HEDIS_Summary_PlanLink_TESTPROD]  @CustID,@LOB, @PCP_NPI, @PCP_GroupID,	@MonthID	

	DECLARE @Total int, @Complete int, @Due int, @MonthID CHAR(6), @LastMonth int, @PrevYearPerc DECIMAL(8,2), @PrevYear_Total DECIMAL(8,2), @PrevYear_Complete DECIMAL(8,2), @Last_Total int, @Last_Complete int, @Last_MonthID int, @Previous_Total int, @Previous_Complete int
	DECLARE @Hedis_ID int, @Hedis_Name varchar (100), @Hedis_TestType varchar (50), @TestGoal DECIMAL(8,2)
	DECLARE @CurYearToDatePerc decimal(8,4), @CurYearOverall decimal(8,4), @YTD_Goal_Status int, @Year_Overall_Status int
	DECLARE @LOB_Temp varchar(50)

	DECLARE @Months	TABLE (MonthID	char(6), Abbreviation varchar(50) ,IsProcessed	bit)

	Declare @NPI varchar(50)
	SET @NPI = @PCP_NPI

	DECLARE @PlanLInk_Active bit, @ID int, @Abbreviation varchar(50), @MeasureEndMonth INT, @MeasureCycleEndDate DATE
	DECLARE @Abbreviations TABLE (ID int Identity (1,1), Abbreviation varchar(50))
	INSERT INTO @Abbreviations (Abbreviation)
	SELECT Abbreviation
	FROM [dbo].[LookupHedis]
	WHERE [TestType] IN ('Predictive', 'Real', '3Percent', '5Percent')
		AND [MeasuramentYearStart] IS NOT NULL
	ORDER BY Abbreviation

	DROP TABLE IF EXISTS #TEMP_RESULTS;
	CREATE TABLE #TEMP_RESULTS
	(testID INT, testAbbr VARCHAR(10), testName VARCHAR(300), FullTestName VARCHAR(300), testType VARCHAR(50), PrevYearPerc DECIMAL(8,2), CurYearToDatePerc DECIMAL(8,2), CurYearOverall DECIMAL(8,2), GoalPerc DECIMAL(8,2), AvgMonthlyDifference  DECIMAL(8,2) ,QualifyingMemCount INT, CompletedMemCount INT, DueMemCount INT, YearToDateGoalStatus INT, CurYearOverallGoalStatus INT ,PCP_NPI VARCHAR(50),	PCP_GroupID	 VARCHAR(50), CustID INT,duration VARCHAR(50), MonthID char(6))


	WHILE EXISTS (SELECT TOP 1 * FROM @Abbreviations)
	BEGIN
		SELECT TOP 1  @ID = ID, @Abbreviation = Abbreviation FROM @Abbreviations

		SELECT @PlanLInk_Active = 0
		SELECT @PlanLInk_Active = [PlankLink_Active] FROM HPTestDueGoal  G JOIN [LookupHedis] LH ON G.TestDueID = LH.ID WHERE CustID = @CustID AND [Abbreviation] = @Abbreviation
		

		SELECT @Hedis_ID = [ID], @Hedis_Name = [Name], @Hedis_TestType = [TestType], @MeasureEndMonth = MONTH(MeasuramentYearEnd)
		FROM [dbo].[LookupHedis]
		WHERE [Abbreviation] = @Abbreviation

		SELECT @TestGoal = Goal FROM HPTestDueGoal WHERE CustID = @CustID AND TestDueID = @Hedis_ID

		INSERT INTO @Months
		Select Distinct MonthID,@Abbreviation, 0 from [dbo].[Final_HEDIS_Member_FULL] where Custid = @CustID AND [TestID] = @Hedis_ID

		IF (ISNULL(@PlanLInk_Active, 0) = 1)
		BEGIN
			--INSERT #TEMP_RESULTS
			--	EXEC [dbo].[Get_HEDIS_Summary_ByMeasure_TESTPROD] @Abbreviation =@Abbreviation, @CustID = @CustID, @LOB = @LOB, @NPI = @NPI, @PCP_GroupID = @PCP_GroupID, @MonthID = @MonthID
			WHILE EXISTS (Select * from @Months Where IsProcessed = 0 and Abbreviation = @Abbreviation)
			BEGIN
				Select TOP 1 @MonthID = MonthID From @Months WHere IsProcessed = 0 and Abbreviation = @Abbreviation order by MonthID

				SET @MeasureCycleEndDate = DATEFROMPARTS(CASE WHEN @MeasureEndMonth < RIGHT(@MonthID,2) THEN LEFT(@MonthID,4) + 1 ELSE LEFT(@MonthID,4) END, @MeasureEndMonth, '01')

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
						SELECT @PrevYear_Total = 0, @PrevYear_Complete = 0, @PrevYearPerc = 0

						IF (@LOB_Temp = '')
						BEGIN
							--This Year
							SELECT @Total = Count(g.ID), @Complete = SUM(CASE WHEN [IsTestDue] = 1 THEN 1 ELSE 0 END)
							FROM [dbo].[Final_HEDIS_Member_FULL] g
								INNER JOIN [dbo].[MDGroup] m ON g.PCP_TIN = m.GroupName AND [CustID_Import] = g.CustID
							WHERE CustID = @CustID
								AND MonthID = @MonthID
								AND [TestID] = @Hedis_ID
								AND m.ID = @PCP_GroupID

							--Previous Year
							SELECT @PrevYear_Total = Count(g.ID), @PrevYear_Complete = SUM(CASE WHEN [IsTestDue] = 1 THEN 1 ELSE 0 END)
							FROM [dbo].[Final_HEDIS_Member_FULL] g
								INNER JOIN [dbo].[MDGroup] m ON g.PCP_TIN = m.GroupName AND [CustID_Import] = g.CustID
							WHERE CustID = @CustID
								AND MonthID = @Last_MonthID
								AND [TestID] = @Hedis_ID
								AND m.ID = @PCP_GroupID

						END
						ELSE
						BEGIN
							--This Year
							SELECT @Total = Count(g.ID), @Complete = SUM(CASE WHEN [IsTestDue] = 1 THEN 1 ELSE 0 END)
							FROM [dbo].[Final_HEDIS_Member_FULL] g
								INNER JOIN [dbo].[MDGroup] m ON g.PCP_TIN = m.GroupName AND [CustID_Import] = g.CustID
							WHERE CustID = @CustID
								AND MonthID = @MonthID
								AND [TestID] = @Hedis_ID
								AND m.ID = @PCP_GroupID
								AND LOB = @LOB_Temp

							--Previous Year
							SELECT @PrevYear_Total = Count(g.ID), @PrevYear_Complete = SUM(CASE WHEN [IsTestDue] = 1 THEN 1 ELSE 0 END)
							FROM [dbo].[Final_HEDIS_Member_FULL] g
								INNER JOIN [dbo].[MDGroup] m ON g.PCP_TIN = m.GroupName AND [CustID_Import] = g.CustID
							WHERE CustID = @CustID
								AND MonthID = @Last_MonthID
								AND [TestID] = @Hedis_ID
								AND m.ID = @PCP_GroupID
								AND LOB = @LOB_Temp

						END

						SELECT @Due = @Total - @Complete
					END
					ELSE
					BEGIN
						SELECT @PrevYear_Total = 0, @PrevYear_Complete = 0, @PrevYearPerc = 0

						IF (@LOB_Temp = '')
						BEGIN
							--This Year
							SELECT @Total = Count(g.ID), @Complete = SUM(CASE WHEN [IsTestDue] = 1 THEN 1 ELSE 0 END)
							FROM [dbo].[Final_HEDIS_Member_FULL] g
								INNER JOIN [dbo].[Link_MDGroupNPI] n on g.PCP_NPI = n.NPI
							WHERE CustID = @CustID AND
								  [PCP_NPI] = @NPI AND
								  MonthID = @MonthID AND
								  [TestID] = @Hedis_ID AND
								  n.MDGroupID = @PCP_GroupID

							--Previous Year
							SELECT @PrevYear_Total = Count(g.ID), @PrevYear_Complete = SUM(CASE WHEN [IsTestDue] = 1 THEN 1 ELSE 0 END)
							FROM [dbo].[Final_HEDIS_Member_FULL] g
								INNER JOIN [dbo].[Link_MDGroupNPI] n on g.PCP_NPI = n.NPI
							WHERE CustID = @CustID AND
								  [PCP_NPI] = @NPI AND
								  MonthID = @Last_MonthID AND
								  [TestID] = @Hedis_ID AND
								  n.MDGroupID = @PCP_GroupID

						END
						ELSE
						BEGIN
							--This Year
							SELECT @Total = Count(g.ID), @Complete = SUM(CASE WHEN [IsTestDue] = 1 THEN 1 ELSE 0 END)
							FROM [dbo].[Final_HEDIS_Member_FULL] g
								INNER JOIN [dbo].[Link_MDGroupNPI] n on g.PCP_NPI = n.NPI
							WHERE CustID = @CustID AND
								  [PCP_NPI] = @NPI AND
								  MonthID = @MonthID AND
								  [TestID] = @Hedis_ID AND
								  n.MDGroupID = @PCP_GroupID AND
								  LOB = @LOB_Temp

							--Previous Year
							SELECT @PrevYear_Total = Count(g.ID), @PrevYear_Complete = SUM(CASE WHEN [IsTestDue] = 1 THEN 1 ELSE 0 END)
							FROM [dbo].[Final_HEDIS_Member_FULL] g
								INNER JOIN [dbo].[Link_MDGroupNPI] n on g.PCP_NPI = n.NPI
							WHERE CustID = @CustID AND
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
						SELECT @PrevYear_Total = 0, @PrevYear_Complete = 0, @PrevYearPerc = 0

						IF (@LOB_Temp = '')
						BEGIN
							--This Year
							SELECT @Total = Count(ID), @Complete = SUM(CASE WHEN [IsTestDue] = 1 THEN 1 ELSE 0 END) 
							FROM [dbo].[Final_HEDIS_Member_FULL]
							WHERE CustID = @CustID AND
								  MonthID = @MonthID AND
								  [TestID] = @Hedis_ID

							--Previous Year
							SELECT @PrevYear_Total = Count(ID),  @PrevYear_Complete = SUM(CASE WHEN [IsTestDue] = 1 THEN 1 ELSE 0 END) 
							FROM [dbo].[Final_HEDIS_Member_FULL]
							WHERE CustID = @CustID AND
								  MonthID = @Last_MonthID AND
								  [TestID] = @Hedis_ID

						END
						ELSE
						BEGIN
							--This Year
							SELECT @Total = Count(ID), @Complete = SUM(CASE WHEN [IsTestDue] = 1 THEN 1 ELSE 0 END) 
							FROM [dbo].[Final_HEDIS_Member_FULL]
							WHERE CustID = @CustID AND
								  MonthID = @MonthID AND
								  [TestID] = @Hedis_ID AND
								  LOB = @LOB_Temp

							--Previous Year
							SELECT @PrevYear_Total = Count(ID), @PrevYear_Complete = SUM(CASE WHEN [IsTestDue] = 1 THEN 1 ELSE 0 END)
							FROM [dbo].[Final_HEDIS_Member_FULL]
							WHERE CustID = @CustID AND
								  MonthID = @Last_MonthID AND
								  [TestID] = @Hedis_ID AND
								  LOB = @LOB_Temp

						END

						SELECT @Due = @Total - @Complete
					END
					ELSE
					BEGIN
						SELECT @PrevYear_Total = 0, @PrevYear_Complete = 0, @PrevYearPerc = 0

						IF (@LOB_Temp = '')
						BEGIN
							--This Year
							SELECT @Total = Count(ID), @Complete = SUM(CASE WHEN [IsTestDue] = 1 THEN 1 ELSE 0 END)
							FROM [dbo].[Final_HEDIS_Member_FULL]
							WHERE CustID = @CustID AND
								  [PCP_NPI] = @NPI AND
								  MonthID = @MonthID AND
								  [TestID] = @Hedis_ID

							--Previous Year
							SELECT @PrevYear_Total = Count(ID), @PrevYear_Complete = SUM(CASE WHEN [IsTestDue] = 1 THEN 1 ELSE 0 END)
							FROM [dbo].[Final_HEDIS_Member_FULL]
							WHERE CustID = @CustID AND
								  [PCP_NPI] = @NPI AND
								  MonthID = @Last_MonthID AND
								  [TestID] = @Hedis_ID

						END
						ELSE
						BEGIN
							--This Year
							SELECT @Total = Count(ID), @Complete = SUM(CASE WHEN [IsTestDue] = 1 THEN 1 ELSE 0 END)
							FROM [dbo].[Final_HEDIS_Member_FULL]
							WHERE CustID = @CustID AND
								  [PCP_NPI] = @NPI AND
								  MonthID = @MonthID AND
								  [TestID] = @Hedis_ID AND
								  LOB = @LOB_Temp

							--Previous Year
							SELECT @PrevYear_Total = Count(ID), @PrevYear_Complete = SUM(CASE WHEN [IsTestDue] = 1 THEN 1 ELSE 0 END)
							FROM [dbo].[Final_HEDIS_Member_FULL]
							WHERE CustID = @CustID AND
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

							IF @CurYearOverall IS NULL
							SELECT @CurYearOverall = (SUM(CAST(IsTestDue AS INT)) /  CAST(COUNT(*) AS DECIMAL(38,17))) * 100
							FROM dbo.Final_HEDIS_Member_FULL
							WHERE CustID = @CustID
							AND MonthID = (SELECT MAX(MonthID) FROM dbo.Final_HEDIS_Member_FULL WHERE CustID = @CustID AND LEFT(MonthID,4) = LEFT(@MonthID,4) AND TestID = @Hedis_ID)
							AND TestID = @Hedis_ID
				END
				ELSE
				EXEC dbo.Get_HEDIS_CurYearOverallPercentage	
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
	
				INSERT INTO #TEMP_RESULTS
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
					   0 AS duration ,
					   @MonthID as MonthID

				UPDATE @Months 
				SET IsProcessed = 1
				WHERE MonthID = @MonthID and IsProcessed = 0 and Abbreviation = @Abbreviation
			END
		END

		DELETE @Abbreviations WHERE ID = @ID
	END
	
	INSERT INTO ScoreCard_PCP(testID, testAbbr, testName, FullTestName, testType, PrevYearPerc, CurYearToDatePerc, CurYearOverall, GoalPerc, AvgMonthlyDifference, QualifyingMemCount, CompletedMemCount, DueMemCount, YearToDateGoalStatus, CurYearOverallGoalStatus, PCP_NPI, PCP_GroupID, CustID, duration, MonthID)
	SELECT testID, testAbbr, testName, FullTestName, testType, PrevYearPerc, CurYearToDatePerc, CurYearOverall, GoalPerc, AvgMonthlyDifference, QualifyingMemCount, CompletedMemCount, DueMemCount, YearToDateGoalStatus, CurYearOverallGoalStatus, PCP_NPI, PCP_GroupID, CustID, duration, MonthID  
	FROM #TEMP_RESULTS

END