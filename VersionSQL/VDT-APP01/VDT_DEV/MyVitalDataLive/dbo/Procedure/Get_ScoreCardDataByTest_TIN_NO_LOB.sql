/****** Object:  Procedure [dbo].[Get_ScoreCardDataByTest_TIN_NO_LOB]    Committed by VersionSQL https://www.versionsql.com ******/

-- =========================================================
-- Author:		Misha
-- Create date: 9/15/2015
-- Description:	Retrieves summary percentages per Hedis test
-- Changes:	MDeLuca	01/15/2018	Made changes for new Get_HEDIS_CurYearOverallPercentage
-- =========================================================
CREATE PROCEDURE [dbo].[Get_ScoreCardDataByTest_TIN_NO_LOB]
	@TestID int,
	@PCP_GroupID int = NULL,
	@PCP_NPI varchar(50) = NULL,
	@CustID int
AS
BEGIN
	SET NOCOUNT ON;

	DROP TABLE IF EXISTS #TEMP_RESULTS;
	CREATE TABLE #TEMP_RESULTS (GroupID int,
								EntityID varchar(50),
								EntityName varchar(100),
								EntityType varchar(50),
								TestID int,
								TestName varchar(110),
								QualifyingMemCount_CurrentYear int,
								CompletedMemCount_CurrentYear int,
								DueMemCount_CurrentYear int,
								QualifyingMemCount_PreviousYear int,
								CompletedMemCount_PreviousYear int,
								PrevYearPerc DECIMAL(8,2),
								CurYearToDatePerc DECIMAL(8,2),
								GoalPerc DECIMAL(8,2),
								YearOverallPercentage DECIMAL(8,2),
								YearToDateGoalStatus int,
								CurYearOverallGoalStatus int)

	DECLARE @MonthID int, @Last_MonthID int, @Abbreviation varchar(50), @TestName varchar(100), @HPGoal DECIMAL(8,2)
	DECLARE @EntityID varchar(50), @EntityName varchar (100), @EntityType varchar(50), @GroupID int
	DECLARE @Total int, @Complete int, @Due int, @Total_Prev int, @Complete_Prev int
	DECLARE @PrevYearPerc DECIMAL(8,2), @CurYearToDatePerc DECIMAL(8,2), @YearOverallPercentage decimal(8,2), @CurYearOverallGoalStatus int, @YearToDateGoalStatus int, @MeasureEndMonth INT, @MeasureCycleEndDate DATE

	SELECT @Abbreviation = Abbreviation, @TestName = Name , @MeasureEndMonth = MONTH(MeasuramentYearEnd)
	FROM [dbo].[LookupHedis] 
	WHERE ID = @TestID
	SELECT @MonthID = Max(MonthID) from [dbo].[Final_HEDIS_Member_FULL] where Custid = @CustID AND [TestID] = @TestID
	SELECT @HPGoal = Goal FROM HPTestDueGoal WHERE CustID = @CustID and TestDueID = @TestID

	IF (RIGHT(@MonthID, 1) = 1)
	BEGIN
		SELECT @Last_MonthID = CONVERT(INT, CONVERT(VARCHAR(4), LEFT(@MonthID, 4) - 1) + '12')
	END
	ELSE
	BEGIN
		SELECT @Last_MonthID = @MonthID - 1
	END

	SET @MeasureCycleEndDate = DATEFROMPARTS(CASE WHEN @MeasureEndMonth < RIGHT(@MonthID,2) THEN LEFT(@MonthID,4) + 1 ELSE LEFT(@MonthID,4) END, @MeasureEndMonth, '01')	

	IF OBJECT_ID('tempdb.dbo.#TEMP_TEST', 'U') IS NOT NULL DROP TABLE #TEMP_TEST
	CREATE TABLE #TEMP_TEST (GroupID int, EntityID VARCHAR(50), EntityName varchar(200), IsTestDue int)
	CREATE INDEX TEMP_TEST_IX_1 on #TEMP_TEST (EntityID)
	CREATE INDEX TEMP_TEST_IX_2 on #TEMP_TEST (EntityID, IsTestDue)
	CREATE INDEX TEMP_TEST_IX_3 on #TEMP_TEST (GroupID, EntityID, IsTestDue)

	--CASE-1: TIN = 'ALL'
	IF (@PCP_GroupID IS NULL OR @PCP_GroupID = 0)
	BEGIN
		SET @EntityType = 'group'

		IF (@CustID = 10) --Parkland
		BEGIN
			INSERT #TEMP_TEST
			SELECT l.ID AS GroupID, GroupName AS EntityID, ISNULL(SecondaryName + ' ' + '(' + GroupName +')', GroupName) AS EntityName, IsTestDue FROM [dbo].[Final_HEDIS_Member_FULL] g
				INNER JOIN [dbo].[MDGroup] l ON g.PCP_TIN = CAST(l.ID AS varchar(50))
			WHERE CustID = @CustID AND MonthID = @MonthID AND [TestID] = @TestID AND GroupName NOT IN ('dchpbeta1','dchpbeta2','dchpbeta3','XXXXXXXXX')
			ORDER BY EntityName
		END
		ELSE
		BEGIN
			INSERT #TEMP_TEST
			SELECT l.ID AS GroupID, GroupName AS EntityID, ISNULL(SecondaryName + ' ' + '(' + GroupName +')', GroupName) AS EntityName, IsTestDue FROM [dbo].[Final_HEDIS_Member_FULL] g
				INNER JOIN [dbo].[MDGroup] l ON g.PCP_TIN = l.GroupName
			WHERE CustID = @CustID AND MonthID = @MonthID AND [TestID] = @TestID AND GroupName NOT IN ('dchpbeta1','dchpbeta2','dchpbeta3','XXXXXXXXX')
			ORDER BY EntityName
		END

		WHILE EXISTS (SELECT TOP 1 EntityID FROM #TEMP_TEST)
		BEGIN
			SELECT TOP 1 @GroupID = GroupID, @EntityID = EntityID, @EntityName = EntityName FROM #TEMP_TEST

			--This Year
			SELECT @Total = COUNT(*) FROM #TEMP_TEST
			WHERE EntityID = @EntityID

			SELECT @Complete = COUNT(*) FROM #TEMP_TEST
			WHERE EntityID = @EntityID AND IsTestDue = 1

			SELECT @Due = @Total - @Complete

			--Previous Year
			--TODO: data should come from one place
			SELECT @Total_Prev = 0 
			SELECT @Complete_Prev = 0
			IF (@Abbreviation = 'W15')
			BEGIN
				SELECT @Total_Prev = Count(*) FROM [VD-RPT01].[_All_2014_Final_HEDIS].[dbo].[Final_W15Member] g
				WHERE CustID = @CustID AND LTRIM(RTRIM(TIN)) = @EntityID

				SELECT @Complete_Prev= Count(*) FROM [VD-RPT01].[_All_2014_Final_HEDIS].[dbo].[Final_W15Member] g
				WHERE CustID = @CustID AND IsComplete = 1 AND LTRIM(RTRIM(TIN)) = @EntityID
			END
			IF (@Abbreviation = 'W34')
			BEGIN
				SELECT @Total_Prev = Count(*) FROM [VD-RPT01].[_All_2014_Final_HEDIS].[dbo].[Final_W34Member] g
				WHERE CustID = @CustID AND LTRIM(RTRIM(TIN)) = @EntityID

				SELECT @Complete_Prev= Count(*) FROM [VD-RPT01].[_All_2014_Final_HEDIS].[dbo].[Final_W34Member] g
				WHERE CustID = @CustID AND IsComplete = 1 AND LTRIM(RTRIM(TIN)) = @EntityID
			END
			IF (@Abbreviation = 'AWC')
			BEGIN
				SELECT @Total_Prev = Count(*) FROM [VD-RPT01].[_All_2014_Final_HEDIS].[dbo].[Final_AWCMember] g
				WHERE CustID = @CustID AND LTRIM(RTRIM(TIN)) = @EntityID

				SELECT @Complete_Prev= Count(*) FROM [VD-RPT01].[_All_2014_Final_HEDIS].[dbo].[Final_AWCMember] g
				WHERE CustID = @CustID AND IsComplete = 1 AND LTRIM(RTRIM(TIN)) = @EntityID
			END

			--Calculations
			SELECT @CurYearToDatePerc = 0.0
			SELECT @CurYearToDatePerc = (CONVERT(decimal(8,4), @Complete) / CONVERT(decimal(8,4), NULLIF(@Total, 0))) * 100
			SELECT @PrevYearPerc = 0.0
			SELECT @PrevYearPerc = (CONVERT(decimal(8,4), @Complete_Prev) / CONVERT(decimal(8,4), NULLIF(@Total_Prev, 0))) * 100

			IF (@CurYearToDatePerc IS NOT NULL AND @CurYearToDatePerc > 0)
			BEGIN

				-- Added 12/28/2017
				IF @MeasureCycleEndDate < DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), '01')
				BEGIN
							SELECT @YearOverallPercentage = (SUM(CAST(IsTestDue AS INT)) /  CAST(COUNT(*) AS DECIMAL(38,17))) * 100
							FROM dbo.Final_HEDIS_Member_FULL
							WHERE CustID = @CustID
							AND MonthID = CAST(YEAR(@MeasureCycleEndDate) AS CHAR(4)) + CASE WHEN LEN(@MeasureEndMonth) = 1 THEN '0'+CAST(@MeasureEndMonth AS CHAR(1)) ELSE CAST(@MeasureEndMonth AS CHAR(2)) END
							AND TestID = @TestID
							AND PCP_TIN = @EntityID

							IF @YearOverallPercentage IS NULL
							SELECT @YearOverallPercentage = (SUM(CAST(IsTestDue AS INT)) /  CAST(COUNT(*) AS DECIMAL(38,17))) * 100
							FROM dbo.Final_HEDIS_Member_FULL
							WHERE CustID = @CustID
							AND MonthID = (SELECT MAX(MonthID) FROM dbo.Final_HEDIS_Member_FULL WHERE CustID = @CustID AND LEFT(MonthID,4) = LEFT(@MonthID,4) AND TestID = @TestID)
							AND TestID = @TestID
							AND PCP_TIN = @EntityID
				END
				ELSE
				EXEC Get_HEDIS_CurYearOverallPercentage	
					@TestID = @TestID,
					@TIN = @EntityID,
					@CustID = @CustID,
					@NPI = NULL,
					@PCP_GroupID = @PCP_GroupID,
					@CurYearToDatePerc = @CurYearToDatePerc,
					@YearOverallPercentage = @YearOverallPercentage OUTPUT
			END
			ELSE
			BEGIN
				SET @YearOverallPercentage = 0
			END

			SELECT @CurYearOverallGoalStatus =
			CASE
				WHEN @YearOverallPercentage > @HPGoal THEN 1
				WHEN @YearOverallPercentage = @HPGoal THEN 0
				ELSE -1
			END

			SELECT @YearToDateGoalStatus =
			CASE
				WHEN @CurYearToDatePerc > @HPGoal THEN 1
				WHEN @CurYearToDatePerc = @HPGoal THEN 0
				ELSE -1
			END

			SELECT @YearOverallPercentage = CASE	WHEN @YearOverallPercentage >= 100 THEN 100.00 WHEN @YearOverallPercentage <= 0 THEN 0 ELSE ISNULL(@YearOverallPercentage,0) END

			--Finalize insert
			INSERT INTO #TEMP_RESULTS
				(GroupID, EntityID, EntityName, EntityType, TestID, TestName, QualifyingMemCount_CurrentYear, CompletedMemCount_CurrentYear, DueMemCount_CurrentYear, QualifyingMemCount_PreviousYear, CompletedMemCount_PreviousYear, GoalPerc, PrevYearPerc, CurYearToDatePerc, YearOverallPercentage, YearToDateGoalStatus, CurYearOverallGoalStatus)
			VALUES
				(@GroupID, @EntityID, @EntityName, @EntityType, @TestID, @TestName + ' (' + @Abbreviation + ')', @Total, @Complete, @Due, @Total_Prev, @Complete_Prev, @HPGoal, @PrevYearPerc, @CurYearToDatePerc, @YearOverallPercentage, @YearToDateGoalStatus, @CurYearOverallGoalStatus)

			DELETE #TEMP_TEST WHERE EntityID = @EntityID
		END

		SELECT * FROM #TEMP_RESULTS
	END
	ELSE
	BEGIN
		--CASE-2: TIN = 'selected tin' & NPI = 'ALL'
		IF (@PCP_NPI IS NULL OR LTRIM(RTRIM(ISNULL(@PCP_NPI, ''))) = '')
		BEGIN
			SET @EntityType = 'pcp'
			
			INSERT #TEMP_TEST
			SELECT @GroupID AS GroupID,
				   g.PCP_NPI AS EntityID,
				   CASE
					   WHEN [Provider Organization Name (Legal Business Name)] != '' THEN [Provider Organization Name (Legal Business Name)]
					   ELSE dbo.fullName([Provider Last Name (Legal Name)], [Provider First Name],'')
				   END AS EntityName,
				   IsTestDue
			FROM [dbo].[Final_HEDIS_Member_FULL] g
				INNER JOIN [dbo].[Link_MDGroupNPI] n ON g.PCP_NPI = n.NPI
				INNER JOIN [dbo].[LookupNPI] l ON g.PCP_NPI = l.NPI
			WHERE CustID = @CustID AND MonthID = @MonthID AND [TestID] = @TestID AND n.MDGroupID = @PCP_GroupID 
			ORDER BY EntityName

			WHILE EXISTS (SELECT TOP 1 EntityID FROM #TEMP_TEST)
			BEGIN
				SELECT TOP 1 @EntityID = EntityID, @EntityName = EntityName FROM #TEMP_TEST

				--This Year
				SELECT @Total = COUNT(*) FROM #TEMP_TEST
				WHERE EntityID = @EntityID

				SELECT @Complete = COUNT(*) FROM #TEMP_TEST
				WHERE EntityID = @EntityID AND IsTestDue = 1

				SELECT @Due = @Total - @Complete

				--Previous Year
				--TODO: data should come from one place
				SELECT @Total_Prev = 0 
				SELECT @Complete_Prev = 0
				IF (@Abbreviation = 'W15')
				BEGIN
					SELECT @Total_Prev = Count(*) FROM [VD-RPT01].[_All_2014_Final_HEDIS].[dbo].[Final_W15Member] g
					WHERE CustID = @CustID AND LTRIM(RTRIM(NPI)) = @EntityID

					SELECT @Complete_Prev= Count(*) FROM [VD-RPT01].[_All_2014_Final_HEDIS].[dbo].[Final_W15Member] g
					WHERE CustID = @CustID AND IsComplete = 1 AND LTRIM(RTRIM(NPI)) = @EntityID
				END
				IF (@Abbreviation = 'W34')
				BEGIN
					SELECT @Total_Prev = Count(*) FROM [VD-RPT01].[_All_2014_Final_HEDIS].[dbo].[Final_W34Member] g
					WHERE CustID = @CustID AND LTRIM(RTRIM(NPI)) = @EntityID

					SELECT @Complete_Prev= Count(*) FROM [VD-RPT01].[_All_2014_Final_HEDIS].[dbo].[Final_W34Member] g
					WHERE CustID = @CustID AND IsComplete = 1 AND LTRIM(RTRIM(NPI)) = @EntityID
				END
				IF (@Abbreviation = 'AWC')
				BEGIN
					SELECT @Total_Prev = Count(*) FROM [VD-RPT01].[_All_2014_Final_HEDIS].[dbo].[Final_AWCMember] g
					WHERE CustID = @CustID AND LTRIM(RTRIM(NPI)) = @EntityID

					SELECT @Complete_Prev= Count(*) FROM [VD-RPT01].[_All_2014_Final_HEDIS].[dbo].[Final_AWCMember] g
					WHERE CustID = @CustID AND IsComplete = 1 AND LTRIM(RTRIM(NPI)) = @EntityID
				END

				--Calculations
				SELECT @CurYearToDatePerc = 0.0
				SELECT @CurYearToDatePerc = (CONVERT(decimal(8,4), @Complete) / CONVERT(decimal(8,4), NULLIF(@Total, 0))) * 100
				SELECT @PrevYearPerc = 0.0
				SELECT @PrevYearPerc = (CONVERT(decimal(8,4), @Complete_Prev) / CONVERT(decimal(8,4), NULLIF(@Total_Prev, 0))) * 100

				IF (@CurYearToDatePerc IS NOT NULL AND @CurYearToDatePerc > 0)
				BEGIN

					-- Added 12/28/2017
					IF @MeasureCycleEndDate < DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), '01')
					BEGIN
								SELECT @YearOverallPercentage = (SUM(CAST(IsTestDue AS INT)) /  CAST(COUNT(*) AS DECIMAL(38,17))) * 100
								FROM dbo.Final_HEDIS_Member_FULL
								WHERE CustID = @CustID
								AND MonthID = CAST(YEAR(@MeasureCycleEndDate) AS CHAR(4)) + CASE WHEN LEN(@MeasureEndMonth) = 1 THEN '0'+CAST(@MeasureEndMonth AS CHAR(1)) ELSE CAST(@MeasureEndMonth AS CHAR(2)) END
								AND TestID = @TestID
								AND PCP_TIN = @EntityID
								AND PCP_NPI = @PCP_GroupID

								IF @YearOverallPercentage IS NULL
								SELECT @YearOverallPercentage = (SUM(CAST(IsTestDue AS INT)) /  CAST(COUNT(*) AS DECIMAL(38,17))) * 100
								FROM dbo.Final_HEDIS_Member_FULL
								WHERE CustID = @CustID
								AND MonthID = (SELECT MAX(MonthID) FROM dbo.Final_HEDIS_Member_FULL WHERE CustID = @CustID AND LEFT(MonthID,4) = LEFT(@MonthID,4) AND TestID = @TestID)
								AND TestID = @TestID
								AND PCP_TIN = @EntityID
								AND PCP_NPI = @PCP_GroupID
					END
					ELSE
					EXEC Get_HEDIS_CurYearOverallPercentage	
						@TestID = @TestID,
						@TIN = NULL,
						@CustID = @CustID,
						@NPI = @EntityID,
						@PCP_GroupID = @PCP_GroupID,
						@CurYearToDatePerc = @CurYearToDatePerc,
						@YearOverallPercentage = @YearOverallPercentage OUTPUT
				END
				ELSE
				BEGIN
					SET @YearOverallPercentage = 0
				END

				SELECT @CurYearOverallGoalStatus =
				CASE
					WHEN @YearOverallPercentage > @HPGoal THEN 1
					WHEN @YearOverallPercentage = @HPGoal THEN 0
					ELSE -1
				END

				SELECT @YearToDateGoalStatus =
				CASE
					WHEN @CurYearToDatePerc > @HPGoal THEN 1
					WHEN @CurYearToDatePerc = @HPGoal THEN 0
					ELSE -1
				END
				
				SELECT @YearOverallPercentage = CASE	WHEN @YearOverallPercentage >= 100 THEN 100.00 WHEN @YearOverallPercentage <= 0 THEN 0 ELSE ISNULL(@YearOverallPercentage,0) END

				--Finalize insert
				INSERT INTO #TEMP_RESULTS
					(GroupID, EntityID, EntityName, EntityType, TestID, TestName, QualifyingMemCount_CurrentYear, CompletedMemCount_CurrentYear, DueMemCount_CurrentYear, QualifyingMemCount_PreviousYear, CompletedMemCount_PreviousYear, GoalPerc, PrevYearPerc, CurYearToDatePerc, YearOverallPercentage, YearToDateGoalStatus, CurYearOverallGoalStatus)
				VALUES
					(@PCP_GroupID, @EntityID, @EntityName, @EntityType, @TestID, @TestName + ' (' + @Abbreviation + ')', @Total, @Complete, @Due, @Total_Prev, @Complete_Prev, @HPGoal, @PrevYearPerc, @CurYearToDatePerc, @YearOverallPercentage, @YearToDateGoalStatus, @CurYearOverallGoalStatus)

				DELETE #TEMP_TEST WHERE EntityID = @EntityID
			END

			SELECT * FROM #TEMP_RESULTS
		END
		ELSE
		BEGIN
			SET @EntityType = 'member'

			--declare @TestID int, @PCP_GroupID int = NULL, @PCP_NPI varchar(50) = NULL, @CustID int, @Abbreviation varchar(50), @MonthID varchar(10)
			--select @TestID = 2,	@PCP_GroupID = 908,	@PCP_NPI = '1447219829', @CustID = 11, @Abbreviation = 'AWC', @MonthID = '201509'

			SELECT @PCP_GroupID AS GroupID
				,@PCP_NPI AS NPI
				,@EntityType AS EntityType
				,g.MemberID AS MemberID
				,dbo.fullName(g.MemberLastName, g.MemberFirstName,'') AS MemberName
				,g.IsTestDue AS [Completed]
				,dbo.Get_HEDISMeasureNote(@Abbreviation, MVDID) as VisitDetail
				,'' AS MeasureDueBy
				,CASE
					WHEN ISNULL(HasAsthma, 0) = 1 AND ISNULL(HasDiabetes, 0) = 1 THEN 'ASM, DIA'
					ELSE
						CASE
							WHEN ISNULL(HasAsthma, 0) = 1 THEN 'ASM'
							WHEN ISNULL(HasDiabetes, 0) = 1 THEN 'DIA'
							ELSE ''
						END
				END AS ASMDIA
				,'' AS MultipleMeasuresDue
				,CASE
					WHEN ISNULL(d.HomePhone, '') = '' THEN d.CellPhone
					ELSE d.HomePhone
				END AS Phone
			FROM [dbo].[Final_HEDIS_Member_FULL] g
				INNER JOIN [dbo].[Link_MDGroupNPI] n ON g.PCP_NPI = n.NPI
				LEFT JOIN dbo.MainPersonalDetails d ON g.MVDID = d.ICENUMBER
			WHERE CustID = @CustID AND MonthID = @MonthID AND [TestID] = @TestID AND n.MDGroupID = @PCP_GroupID AND g.PCP_NPI = LTRIM(RTRIM(@PCP_NPI))
			ORDER BY MemberName
		END
	END
END