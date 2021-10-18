/****** Object:  Procedure [dbo].[Get_ScoreCardDataByTest_TIN]    Committed by VersionSQL https://www.versionsql.com ******/

-- =========================================================
-- Author:		Misha
-- Create date: 9/15/2015
-- Description:	Retrieves summary percentages per Hedis test
-- Changes:	MDeLuca	01/15/2018	Made changes for new Get_HEDIS_CurYearOverallPercentage
-- =========================================================
CREATE PROCEDURE [dbo].[Get_ScoreCardDataByTest_TIN]
--DECLARE 
	@TestID int,
	@LOB varchar(50) = 'ALL',
	@PCP_GroupID int = NULL,
	@PCP_NPI varchar(50) = NULL,
	@CustID int,
	@MonthID int
AS

BEGIN
	SET NOCOUNT ON;

	IF OBJECT_ID('tempdb..#TEMP_RESULTS') IS NOT NULL
	 BEGIN
		DROP TABLE #TEMP_RESULTS;
	 END
	CREATE TABLE #TEMP_RESULTS (GroupID int,
								LOB varchar(50),
								EntityID varchar(50),
								EntityName varchar(250),
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
								CurYearOverallGoalStatus int,
								MonthID	int)

	DECLARE @MonthID_Check int, @Last_MonthID int, @Abbreviation varchar(50), @TestName varchar(100), @HPGoal DECIMAL(8,2)
	DECLARE @EntityID varchar(50), @EntityName varchar (250), @EntityType varchar(50), @GroupID int
	DECLARE @Total int, @Complete int, @Due int, @Total_Prev int, @Complete_Prev int
	DECLARE @PrevYearPerc DECIMAL(8,2), @CurYearToDatePerc DECIMAL(8,2), @YearOverallPercentage decimal(8,2), @CurYearOverallGoalStatus int, @YearToDateGoalStatus int
	DECLARE @LOB_Temp varchar(50)
	DECLARE @TestID_Check INT, @MeasureEndMonth INT, @MeasureCycleEndDate DATE

	SELECT @Abbreviation = Abbreviation, @TestName = Name,  @TestID_Check = TestID, @MeasureEndMonth = MONTH(MeasuramentYearEnd) FROM [dbo].[LookupHedis] wHERE ID = @TestID
	SELECT @HPGoal = Goal FROM HPTestDueGoal WHERE CustID = @CustID and TestDueID = @TestID
	SELECT @MonthID_Check = Max(MonthID) from [dbo].[Final_HEDIS_Member_FULL] where Custid = @CustID AND [TestID] = @TestID and MonthID <= @MonthID


	IF NOT Exists (Select top 1 g.ID from [Final_HEDIS_Member_FULL] g JOIN [dbo].[LookupHedis] L ON g.TestID = L.ID Where g.CustID = @CustID and MonthID = @MonthID and L.TestID = @TestID_Check  and g.TestID = @TestID)
	BEGIN
		
		--select @MonthID_Check as MonthID_Check
		IF @MonthID > @MonthID_Check
		BEGIN 
			--print 'Setting MonthID = MonthID_CHeck'
			SET @MonthID = @MonthID_Check
		END
	END
	--TODO: set different END DATE for certain measures
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
	CREATE TABLE #TEMP_TEST (GroupID int, EntityID VARCHAR(250), EntityName varchar(250), IsTestDue int)
	CREATE INDEX TEMP_TEST_IX_1 on #TEMP_TEST (EntityID)
	CREATE INDEX TEMP_TEST_IX_2 on #TEMP_TEST (EntityID, IsTestDue)
	CREATE INDEX TEMP_TEST_IX_3 on #TEMP_TEST (GroupID, EntityID, IsTestDue)

	IF OBJECT_ID('tempdb.dbo.#TEMP_TEST_LAST', 'U') IS NOT NULL DROP TABLE #TEMP_TEST_LAST
	CREATE TABLE #TEMP_TEST_LAST (GroupID int, EntityID VARCHAR(250), EntityName varchar(250), IsTestDue int)
	CREATE INDEX TEMP_TEST_LAST_IX_1 on #TEMP_TEST_LAST (EntityID)
	CREATE INDEX TEMP_TEST_LAST_IX_2 on #TEMP_TEST_LAST (EntityID, IsTestDue)
	CREATE INDEX TEMP_TEST_LAST_IX_3 on #TEMP_TEST_LAST (GroupID, EntityID, IsTestDue)

	SELECT @LOB_Temp = (CASE WHEN @LOB = 'ALL' THEN '' ELSE @LOB END)


	--CASE-1: TIN = 'ALL'
	IF (@PCP_GroupID IS NULL OR @PCP_GroupID = 0)
	BEGIN
		SET @EntityType = 'group'

		BEGIN
			IF (@LOB_Temp = '')
			BEGIN
				INSERT #TEMP_TEST
				SELECT l.ID AS GroupID, GroupName AS EntityID, ISNULL(SecondaryName + ' ' + '(' + GroupName +')', GroupName) AS EntityName, IsTestDue FROM [dbo].[Final_HEDIS_Member_FULL] g
					INNER JOIN [dbo].[MDGroup] l ON g.PCP_TIN = l.GroupName AND [CustID_Import] = @CustID
				WHERE CustID = @CustID AND
					  MonthID = @MonthID AND
					  [TestID] = @TestID AND
					  GroupName NOT IN ('dchpbeta1','dchpbeta2','dchpbeta3','XXXXXXXXX')
				ORDER BY EntityName

				INSERT #TEMP_TEST_LAST
				SELECT l.ID AS GroupID, GroupName AS EntityID, ISNULL(SecondaryName + ' ' + '(' + GroupName +')', GroupName) AS EntityName, IsTestDue FROM [dbo].[Final_HEDIS_Member_FULL] g
					INNER JOIN [dbo].[MDGroup] l ON g.PCP_TIN = l.GroupName AND [CustID_Import] = @CustID
				WHERE CustID = @CustID AND
					  MonthID = @Last_MonthID AND
					  [TestID] = @TestID AND
					  GroupName NOT IN ('dchpbeta1','dchpbeta2','dchpbeta3','XXXXXXXXX')
				ORDER BY EntityName
			END
			ELSE
			BEGIN
				INSERT #TEMP_TEST
				SELECT l.ID AS GroupID, GroupName AS EntityID, ISNULL(SecondaryName + ' ' + '(' + GroupName +')', GroupName) AS EntityName, IsTestDue FROM [dbo].[Final_HEDIS_Member_FULL] g
					INNER JOIN [dbo].[MDGroup] l ON g.PCP_TIN = l.GroupName AND [CustID_Import] = @CustID
				WHERE CustID = @CustID AND
					  MonthID = @MonthID AND
					  [TestID] = @TestID AND
					  GroupName NOT IN ('dchpbeta1','dchpbeta2','dchpbeta3','XXXXXXXXX') AND
					  LOB = @LOB_Temp
				ORDER BY EntityName

				INSERT #TEMP_TEST_LAST
				SELECT l.ID AS GroupID, GroupName AS EntityID, ISNULL(SecondaryName + ' ' + '(' + GroupName +')', GroupName) AS EntityName, IsTestDue FROM [dbo].[Final_HEDIS_Member_FULL] g
					INNER JOIN [dbo].[MDGroup] l ON g.PCP_TIN = l.GroupName AND [CustID_Import] = @CustID
				WHERE CustID = @CustID AND
					  MonthID = @Last_MonthID AND
					  [TestID] = @TestID AND
					  GroupName NOT IN ('dchpbeta1','dchpbeta2','dchpbeta3','XXXXXXXXX') AND
					  LOB = @LOB_Temp
				ORDER BY EntityName
			END
		END

		
		WHILE EXISTS (SELECT TOP 1 EntityID FROM #TEMP_TEST)
		BEGIN
			SELECT TOP 1 @GroupID = GroupID, @EntityID = EntityID, @EntityName = EntityName FROM #TEMP_TEST

			--This Year
			SELECT @Total = COUNT(*) FROM #TEMP_TEST
			WHERE EntityID = @EntityID and GroupID = @GroupID

			SELECT @Complete = COUNT(*) FROM #TEMP_TEST
			WHERE EntityID = @EntityID AND IsTestDue = 1 and GroupID = @GroupID

			SELECT @Due = @Total - @Complete

			--Previous Year
			SELECT @Total_Prev = 0 
			SELECT @Complete_Prev = 0

			SELECT @Total_Prev = COUNT(*) FROM #TEMP_TEST_LAST
			WHERE EntityID = @EntityID and GroupID = @GroupID

			SELECT @Complete_Prev = COUNT(*) FROM #TEMP_TEST_LAST
			WHERE EntityID = @EntityID AND IsTestDue = 1 and GroupID = @GroupID

			--Calculations
			SELECT @CurYearToDatePerc = 0.0
			SELECT @CurYearToDatePerc = (CONVERT(decimal(10,4), @Complete) / CONVERT(decimal(10,4), NULLIF(@Total, 0))) * 100
			SELECT @PrevYearPerc = 0.0
			SELECT @PrevYearPerc = (CONVERT(decimal(10,4), @Complete_Prev) / CONVERT(decimal(10,4), NULLIF(@Total_Prev, 0))) * 100

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

			--Finalize insert
			INSERT INTO #TEMP_RESULTS
				(GroupID, LOB, EntityID, EntityName, EntityType, TestID, TestName, QualifyingMemCount_CurrentYear, CompletedMemCount_CurrentYear, DueMemCount_CurrentYear, QualifyingMemCount_PreviousYear, CompletedMemCount_PreviousYear, GoalPerc, PrevYearPerc, CurYearToDatePerc, YearOverallPercentage, YearToDateGoalStatus, CurYearOverallGoalStatus, MonthID)
			VALUES
				(@GroupID, @LOB, @EntityID, @EntityName, @EntityType, @TestID, @TestName + ' (' + @Abbreviation + ')', @Total, @Complete, @Due, @Total_Prev, @Complete_Prev, @HPGoal, @PrevYearPerc, @CurYearToDatePerc, @YearOverallPercentage, @YearToDateGoalStatus, @CurYearOverallGoalStatus, @MonthID)

			DELETE #TEMP_TEST WHERE EntityID = @EntityID and GroupID = @GroupID
		END

		SELECT distinct * FROM #TEMP_RESULTS Where GroupID is NOT NULL
	END
	ELSE
	BEGIN
		--CASE-2: TIN = 'selected tin' & NPI = 'ALL'
		IF (@PCP_NPI IS NULL OR LTRIM(RTRIM(ISNULL(@PCP_NPI, ''))) = '')
		BEGIN
			SET @EntityType = 'pcp'
			
			IF (@LOB_Temp = '')
			BEGIN
				INSERT #TEMP_TEST
				SELECT @GroupID AS GroupID,
					   g.PCP_NPI AS EntityID,
					   CASE
						   WHEN [Provider Organization Name (Legal Business Name)] != '' THEN [Provider Organization Name (Legal Business Name)]
						   ELSE dbo.fullName([Provider Last Name (Legal Name)], [Provider First Name],'')
					   END AS EntityName,
					   IsTestDue
				FROM [dbo].[Final_HEDIS_Member_FULL] g
					LEFT JOIN [dbo].[MDGroup] m ON g.PCP_TIN = m.GroupName AND m.[CustID_Import] = CustID
					LEFT JOIN [dbo].[LookupNPI] l ON g.PCP_NPI = l.NPI
				WHERE CustID = @CustID AND
					  MonthID = @MonthID AND
					  [TestID] = @TestID AND
					  m.ID = @PCP_GroupID
				ORDER BY EntityName
			END
			ELSE
			BEGIN
				INSERT #TEMP_TEST
				SELECT @GroupID AS GroupID,
					   g.PCP_NPI AS EntityID,
					   CASE
						   WHEN [Provider Organization Name (Legal Business Name)] != '' THEN [Provider Organization Name (Legal Business Name)]
						   ELSE dbo.fullName([Provider Last Name (Legal Name)], [Provider First Name],'')
					   END AS EntityName,
					   IsTestDue
				FROM [dbo].[Final_HEDIS_Member_FULL] g
				LEFT JOIN [dbo].[MDGroup] m ON g.PCP_TIN = m.GroupName AND m.[CustID_Import] = CustID
					LEFT JOIN [dbo].[LookupNPI] l ON g.PCP_NPI = l.NPI
				WHERE CustID = @CustID AND
					  MonthID = @MonthID AND
					  [TestID] = @TestID AND
					  m.ID = @PCP_GroupID AND
					  LOB = @LOB_Temp
				ORDER BY EntityName
			END

			WHILE EXISTS (SELECT TOP 1 EntityID FROM #TEMP_TEST)
			BEGIN
				SELECT TOP 1 @EntityID = EntityID, @EntityName = EntityName FROM #TEMP_TEST

				--This Year
				SELECT @Total = COUNT(*) FROM #TEMP_TEST
				WHERE EntityID = @EntityID

				--select @Total as '@Total'

				SELECT @Complete = COUNT(*) FROM #TEMP_TEST
				WHERE EntityID = @EntityID AND IsTestDue = 1

				SELECT @Due = @Total - @Complete

				--Previous Year
				SELECT @Total_Prev = 0 
				SELECT @Complete_Prev = 0
				
				SELECT @Total_Prev = COUNT(*) FROM #TEMP_TEST_LAST
				WHERE EntityID = @EntityID

				SELECT @Complete_Prev = COUNT(*) FROM #TEMP_TEST_LAST
				WHERE EntityID = @EntityID AND IsTestDue = 1

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
									AND PCP_NPI = @EntityID

									IF @YearOverallPercentage IS NULL
									SELECT @YearOverallPercentage = (SUM(CAST(IsTestDue AS INT)) /  CAST(COUNT(*) AS DECIMAL(38,17))) * 100
									FROM dbo.Final_HEDIS_Member_FULL
									WHERE CustID = @CustID
									AND MonthID = (SELECT MAX(MonthID) FROM dbo.Final_HEDIS_Member_FULL WHERE CustID = @CustID AND LEFT(MonthID,4) = LEFT(@MonthID,4) AND TestID = @TestID)
									AND TestID = @TestID
									AND PCP_NPI = @EntityID

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

				--Finalize insert
				INSERT INTO #TEMP_RESULTS
					(GroupID, LOB, EntityID, EntityName, EntityType, TestID, TestName, QualifyingMemCount_CurrentYear, CompletedMemCount_CurrentYear, DueMemCount_CurrentYear, QualifyingMemCount_PreviousYear, CompletedMemCount_PreviousYear, GoalPerc, PrevYearPerc, CurYearToDatePerc, YearOverallPercentage, YearToDateGoalStatus, CurYearOverallGoalStatus, MonthID)
				VALUES
					(@PCP_GroupID, @LOB, @EntityID, @EntityName, @EntityType, @TestID, @TestName + ' (' + @Abbreviation + ')', @Total, @Complete, @Due, @Total_Prev, @Complete_Prev, @HPGoal, @PrevYearPerc, @CurYearToDatePerc, @YearOverallPercentage, @YearToDateGoalStatus, @CurYearOverallGoalStatus, @MonthID)

				DELETE #TEMP_TEST WHERE EntityID = @EntityID
			END

			SELECT distinct * FROM #TEMP_RESULTS
		END
		ELSE
		BEGIN
			SET @EntityType = 'member'

			IF (@LOB_Temp = '')
			BEGIN
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
				LEFT JOIN [dbo].[MDGroup] m ON g.PCP_TIN = m.GroupName AND m.[CustID_Import] = CustID
					LEFT JOIN dbo.MainPersonalDetails d ON g.MVDID = d.ICENUMBER
				WHERE CustID = @CustID AND
					MonthID = @MonthID AND
					[TestID] = @TestID AND
					m.ID = @PCP_GroupID AND
					g.PCP_NPI = LTRIM(RTRIM(@PCP_NPI))
				ORDER BY MemberName
			END
			ELSE
			BEGIN
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
					LEFT JOIN [dbo].[MDGroup] m ON g.PCP_TIN = m.GroupName AND m.[CustID_Import] = CustID
					LEFT JOIN dbo.MainPersonalDetails d ON g.MVDID = d.ICENUMBER
				WHERE CustID = @CustID AND
					MonthID = @MonthID AND
					[TestID] = @TestID AND
					m.ID = @PCP_GroupID AND
					g.PCP_NPI = LTRIM(RTRIM(@PCP_NPI)) AND
					LOB = @LOB_Temp
				ORDER BY MemberName
			END
		END
	END
END