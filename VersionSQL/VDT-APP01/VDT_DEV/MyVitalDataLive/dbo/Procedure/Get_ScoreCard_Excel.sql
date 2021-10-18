/****** Object:  Procedure [dbo].[Get_ScoreCard_Excel]    Committed by VersionSQL https://www.versionsql.com ******/

-- =========================================================
-- Author:		Misha
-- Create date: 9/29/2015
-- Description:	Retrieves summary percentages per Hedis test
-- Changes:	MDeLuca	01/15/2018	Made changes for new Get_HEDIS_CurYearOverallPercentage
-- =========================================================
CREATE PROCEDURE [dbo].[Get_ScoreCard_Excel]
--DECLARE
	@ExcelType int,
	@TestID int,
	@LOB varchar(50) = 'ALL',
	@PCP_GroupID int = NULL,
	@PCP_NPI varchar(50) = NULL,
	@CustID int,
	@MonthID int
AS
BEGIN
--SET @ExcelType = 0
--SET	@TestID = 74--67
--SET	@LOB  = 'ALL'
--SET	@PCP_GroupID = NULL--5282--NULL
--SET	@PCP_NPI = NULL--1043524812                                        --NULL
--SET	@CustID = 11
--SET	@MonthID = 201607
	/* Exlel Types
	0 - TIN
	1 - NPI
	2 - Member per TIN
	3 - Member per NPI*/

	SET NOCOUNT ON;

	DECLARE  @MonthID_Check int, @Last_MonthID int, @Abbreviation varchar(50), @TestName varchar(60), @HPGoal DECIMAL(8,2)
	DECLARE @EntityID varchar(50), @EntityName varchar (100), @LOB_TMP varchar(50), @EntityType varchar(50), @GroupID int
	DECLARE @Total int, @Complete int, @Due int, @Total_Prev int, @Complete_Prev int
	DECLARE @PrevYearPerc DECIMAL(8,2), @CurYearToDatePerc DECIMAL(8,2), @YearOverallPercentage decimal(8,2), @CurYearOverallGoalStatus int, @YearToDateGoalStatus int
	DECLARE @TestID_Check INT, @MeasureEndMonth INT, @MeasureCycleEndDate DATE

	IF OBJECT_ID('tempdb.dbo.#TEMP_TEST', 'U') IS NOT NULL DROP TABLE #TEMP_TEST
	CREATE TABLE #TEMP_TEST (GroupID int, EntityID VARCHAR(250), [LOB] varchar(50), EntityName varchar(250), IsTestDue int)
	CREATE INDEX TEMP_TEST_IX_1 on #TEMP_TEST (EntityID)
	CREATE INDEX TEMP_TEST_IX_2 on #TEMP_TEST (EntityID, IsTestDue)
	CREATE INDEX TEMP_TEST_IX_3 on #TEMP_TEST (GroupID, EntityID, IsTestDue)

	SELECT @Abbreviation = Abbreviation, @TestName = Name,  @TestID_Check = TestID, @MeasureEndMonth = MONTH(MeasuramentYearEnd) FROM [dbo].[LookupHedis] WHERE ID = @TestID
	SELECT @HPGoal = Goal FROM HPTestDueGoal WHERE CustID = @CustID and TestDueID = @TestID
	SELECT @MonthID_Check = Max(MonthID) from [dbo].[Final_HEDIS_Member_FULL] where Custid = @CustID AND [TestID] = @TestID and MonthID <= @MonthID


	IF NOT Exists (Select top 1 g.ID from [Final_HEDIS_Member_FULL] g JOIN [dbo].[LookupHedis] L ON g.TestID = L.ID Where g.CustID = @CustID and MonthID = @MonthID and L.TestID = @TestID_Check)
	BEGIN
		IF @MonthID > @MonthID_Check
		BEGIN 
			--print 'Setting MonthID = MonthID_CHeck'
			SET @MonthID = @MonthID_Check
		END
	END
	IF (RIGHT(@MonthID, 1) = 1)
	BEGIN
		SELECT @Last_MonthID = CONVERT(INT, CONVERT(VARCHAR(4), LEFT(@MonthID, 4) - 1) + '12')
	END
	ELSE
	BEGIN
		SELECT @Last_MonthID = @MonthID - 1
	END

	SET @MeasureCycleEndDate = DATEFROMPARTS(CASE WHEN @MeasureEndMonth < RIGHT(@MonthID,2) THEN LEFT(@MonthID,4) + 1 ELSE LEFT(@MonthID,4) END, @MeasureEndMonth, '01')

	--CASE-1: ExcelType = 0 - TIN'
	IF (@ExcelType = 0)
	BEGIN
		IF OBJECT_ID('tempdb..#TEMP_RESULTS') IS NOT NULL
		BEGIN
			DROP TABLE #TEMP_RESULTS;
		END
		CREATE TABLE #TEMP_RESULTS ([Test Name] varchar(200),
									[Clinic Name] varchar(200),
									[LOB] varchar(50),
									[Eligible] int,
									[Completed] int,
									[Due] int,
									[Health Plan Goal] DECIMAL(8,2),
									[Year To Date Score] DECIMAL(8,2),
									[Estimated Year End Score] DECIMAL(8,2),
									[MonthID]	int)

		IF (@CustID = 10) --Parkland
		BEGIN
			INSERT #TEMP_TEST
			SELECT l.ID AS GroupID, GroupName AS EntityID, [LOB], ISNULL(SecondaryName + ' ' + '(' + GroupName +')', GroupName) AS EntityName, IsTestDue FROM [dbo].[Final_HEDIS_Member_FULL] g
				INNER JOIN [dbo].[MDGroup] l ON g.PCP_TIN = l.GroupName and [CustID_Import] = g.CustID
			WHERE CustID = @CustID AND
				  MonthID = @MonthID AND
				  [TestID] = @TestID AND
				  GroupName NOT IN ('dchpbeta1','dchpbeta2','dchpbeta3','XXXXXXXXX') AND
				  LOB = (CASE
							WHEN (@LOB = 'ALL') THEN LOB
							--WHEN (@LOB = 'STAR') THEN 'M'
							--WHEN (@LOB = 'CHIP') THEN 'C'
							ELSE @LOB
						END)
			ORDER BY EntityName
		END
		ELSE
		BEGIN
			INSERT #TEMP_TEST
			SELECT l.ID AS GroupID, GroupName AS EntityID, [LOB], ISNULL(SecondaryName + ' ' + '(' + GroupName +')', GroupName) AS EntityName, IsTestDue FROM [dbo].[Final_HEDIS_Member_FULL] g
				INNER JOIN [dbo].[MDGroup] l ON g.PCP_TIN = l.GroupName and [CustID_Import] = g.CustID
			WHERE CustID = @CustID AND
				  MonthID = @MonthID AND
				  [TestID] = @TestID AND
				  GroupName NOT IN ('dchpbeta1','dchpbeta2','dchpbeta3','XXXXXXXXX') AND
				  LOB = (CASE
							WHEN (@LOB = 'ALL') THEN LOB
							--WHEN (@LOB = 'STAR') THEN 'M'
							--WHEN (@LOB = 'CHIP') THEN 'C'
							ELSE @LOB
						END)
			ORDER BY EntityName
		END

		WHILE EXISTS (SELECT TOP 1 EntityID FROM #TEMP_TEST)
		BEGIN
			SELECT TOP 1 @GroupID = GroupID, @EntityID = EntityID, @LOB_TMP = LOB, @EntityName = EntityName FROM #TEMP_TEST

			--This Year
			SELECT @Total = COUNT(*) FROM #TEMP_TEST
			WHERE EntityID = @EntityID

			SELECT @Complete = COUNT(*) FROM #TEMP_TEST
			WHERE EntityID = @EntityID AND IsTestDue = 1

			SELECT @Due = @Total - @Complete

			--Calculations
			SELECT @CurYearToDatePerc = 0.0
			SELECT @CurYearToDatePerc = (CONVERT(decimal(8,4), @Complete) / CONVERT(decimal(8,4), NULLIF(@Total, 0))) * 100

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

			--Finalize insert
			INSERT INTO #TEMP_RESULTS
				([Clinic Name], [Test Name], [LOB], [Eligible], [Completed], [Due], [Health Plan Goal], [Year To Date Score], [Estimated Year End Score], MonthID)
			VALUES
				(@EntityName, @TestName + ' (' + @Abbreviation + ')', (CASE
							WHEN (@LOB_TMP = 'M') THEN 'STAR'
							WHEN (@LOB_TMP = 'C') THEN 'CHIP'
							ELSE @LOB_TMP
						END), @Total, @Complete, @Due, @HPGoal, @CurYearToDatePerc, @YearOverallPercentage, @MonthID)

			DELETE #TEMP_TEST WHERE EntityID = @EntityID
		END

		SELECT * FROM #TEMP_RESULTS
	END

	--CASE-2: ExcelType = 1 - NPI'
	IF (@ExcelType = 1)
	BEGIN
		IF OBJECT_ID('tempdb..#TEMP_RESULTS_NPI') IS NOT NULL
		BEGIN
			DROP TABLE #TEMP_RESULTS_NPI;
		END
		CREATE TABLE #TEMP_RESULTS_NPI ([Test Name] varchar(200),
								[Provider Name] varchar(200),
								[LOB] varchar(50),
								[Eligible] int,
								[Completed] int,
								[Due] int,
								[Health Plan Goal] DECIMAL(8,2),
								[Year To Date Score] DECIMAL(8,2),
								[Estimated Year End Score] DECIMAL(8,2),
								MonthID int)

		INSERT #TEMP_TEST
		SELECT @GroupID AS GroupID,
				g.PCP_NPI AS EntityID,
				g.LOB,
				CASE
					WHEN [Provider Organization Name (Legal Business Name)] != '' THEN [Provider Organization Name (Legal Business Name)]
					ELSE dbo.fullName([Provider Last Name (Legal Name)], [Provider First Name],'')
				END AS EntityName,
				IsTestDue
		FROM [dbo].[Final_HEDIS_Member_FULL] g
			INNER JOIN [dbo].[MDGroup] m ON g.PCP_TIN = m.GroupName AND m.[CustID_Import] = CustID
			--INNER JOIN [dbo].[Link_MDGroupNPI] n ON g.PCP_NPI = n.NPI and m.ID = n.MDGroupID
			INNER JOIN [dbo].[LookupNPI] l ON g.PCP_NPI = l.NPI
		WHERE CustID = @CustID AND
			  MonthID = @MonthID AND
			  [TestID] = @TestID AND
			  m.ID = @PCP_GroupID AND
			  LOB = (CASE
				  WHEN (@LOB = 'ALL') THEN LOB
				  --WHEN (@LOB = 'STAR') THEN 'M'
				  --WHEN (@LOB = 'CHIP') THEN 'C'
				  ELSE @LOB
			  END)
		ORDER BY EntityName

		WHILE EXISTS (SELECT TOP 1 EntityID FROM #TEMP_TEST)
		BEGIN
			SELECT TOP 1 @EntityID = EntityID, @EntityName = EntityName, @LOB_TMP = LOB FROM #TEMP_TEST

			--This Year
			SELECT @Total = COUNT(*) FROM #TEMP_TEST
			WHERE EntityID = @EntityID

			SELECT @Complete = COUNT(*) FROM #TEMP_TEST
			WHERE EntityID = @EntityID AND IsTestDue = 1

			SELECT @Due = @Total - @Complete

			--Calculations
			SELECT @CurYearToDatePerc = 0.0
			SELECT @CurYearToDatePerc = (CONVERT(decimal(8,4), @Complete) / CONVERT(decimal(8,4), NULLIF(@Total, 0))) * 100

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

			--Finalize insert
			INSERT INTO #TEMP_RESULTS_NPI
			([Provider Name], [Test Name], LOB, [Eligible], [Completed], [Due], [Health Plan Goal], [Year To Date Score], [Estimated Year End Score], MonthID)
		VALUES
			(@EntityName, @TestName + ' (' + @Abbreviation + ')', (CASE
							WHEN (@LOB_TMP = 'M') THEN 'STAR'
							WHEN (@LOB_TMP = 'C') THEN 'CHIP'
							ELSE @LOB_TMP
						END), @Total, @Complete, @Due, @HPGoal, @CurYearToDatePerc, @YearOverallPercentage, @MonthID)

			DELETE #TEMP_TEST WHERE EntityID = @EntityID
		END

		SELECT * FROM #TEMP_RESULTS_NPI
	END

	--CASE-3: ExcelType = 2 - Member per TIN'
	IF (@ExcelType = 2)
	BEGIN
		SELECT
			@TestName AS [Test Name]
			,CASE
				WHEN [Provider Organization Name (Legal Business Name)] != '' THEN [Provider Organization Name (Legal Business Name)]
				ELSE dbo.fullName([Provider Last Name (Legal Name)], [Provider First Name],'')
			END AS [Provider Name]
			,LOB
			,g.MemberID AS [Member ID]
			,dbo.fullName(g.MemberLastName, g.MemberFirstName,'') AS [Member Name]
			,g.IsTestDue AS [Completed]
			,dbo.Get_HEDISMeasureNote(@Abbreviation, MVDID) as [Visit Detail]
			,'' AS [Measure Due By]
			,CASE
				WHEN ISNULL(HasAsthma, 0) = 1 AND ISNULL(HasDiabetes, 0) = 1 THEN 'ASM, DIA'
				ELSE
					CASE
						WHEN ISNULL(HasAsthma, 0) = 1 THEN 'ASM'
						WHEN ISNULL(HasDiabetes, 0) = 1 THEN 'DIA'
						ELSE ''
					END
			END AS [ASM/DIA]
			,'' AS [Multiple Measures Due]
			,CASE
				WHEN ISNULL(d.HomePhone, '') = '' THEN d.CellPhone
				ELSE d.HomePhone
			END AS [Phone Number]
		FROM [dbo].[Final_HEDIS_Member_FULL] g
			INNER JOIN [dbo].[MDGroup] m ON g.PCP_TIN = m.GroupName AND m.[CustID_Import] = CustID
			--INNER JOIN [dbo].[Link_MDGroupNPI] n ON g.PCP_NPI = n.NPI  and m.ID = n.MDGroupID
			INNER JOIN [dbo].[LookupNPI] l ON g.PCP_NPI = l.NPI
			LEFT JOIN dbo.MainPersonalDetails d ON g.MVDID = d.ICENUMBER
		WHERE CustID = @CustID AND
			  MonthID = @MonthID AND
			  [TestID] = @TestID AND
			  m.ID = @PCP_GroupID AND
			  LOB = (CASE
						WHEN (@LOB = 'ALL') THEN LOB
						--WHEN (@LOB = 'STAR') THEN 'M'
						--WHEN (@LOB = 'CHIP') THEN 'C'
						ELSE @LOB
					END)
		ORDER BY [Provider Name], [Member Name]
	END

	--CASE-4: ExcelType = 3 - Member per NPI'
	IF (@ExcelType = 3)
	BEGIN
		SELECT
			@TestName AS [Test Name]
			,CASE
				WHEN [Provider Organization Name (Legal Business Name)] != '' THEN [Provider Organization Name (Legal Business Name)]
				ELSE dbo.fullName([Provider Last Name (Legal Name)], [Provider First Name],'')
			END AS [Provider Name]
			,LOB
			,g.MemberID AS [Member ID]
			,dbo.fullName(g.MemberLastName, g.MemberFirstName,'') AS [Member Name]
			,g.IsTestDue AS [Completed]
			,dbo.Get_HEDISMeasureNote(@Abbreviation, MVDID) as [Visit Detail]
			,'' AS [Measure Due By]
			,CASE
				WHEN ISNULL(HasAsthma, 0) = 1 AND ISNULL(HasDiabetes, 0) = 1 THEN 'ASM, DIA'
				ELSE
					CASE
						WHEN ISNULL(HasAsthma, 0) = 1 THEN 'ASM'
						WHEN ISNULL(HasDiabetes, 0) = 1 THEN 'DIA'
						ELSE ''
					END
			END AS [ASM/DIA]
			,'' AS [Multiple Measures Due]
			,CASE
				WHEN ISNULL(d.HomePhone, '') = '' THEN d.CellPhone
				ELSE d.HomePhone
			END AS [Phone Number]
		FROM [dbo].[Final_HEDIS_Member_FULL] g
			INNER JOIN [dbo].[MDGroup] m ON g.PCP_TIN = m.GroupName AND m.[CustID_Import] = CustID
			--INNER JOIN [dbo].[Link_MDGroupNPI] n ON g.PCP_NPI = n.NPI
			INNER JOIN [dbo].[LookupNPI] l ON g.PCP_NPI = l.NPI
			LEFT JOIN dbo.MainPersonalDetails d ON g.MVDID = d.ICENUMBER
		WHERE CustID = @CustID AND
			  MonthID = @MonthID AND
			  [TestID] = @TestID AND
			  m.ID = @PCP_GroupID AND
			  g.PCP_NPI = LTRIM(RTRIM(@PCP_NPI)) AND
			  LOB = (CASE
						WHEN (@LOB = 'ALL') THEN LOB
						--WHEN (@LOB = 'STAR') THEN 'M'
						--WHEN (@LOB = 'CHIP') THEN 'C'
						ELSE @LOB
					  END)
		ORDER BY [Member Name]
	END
END